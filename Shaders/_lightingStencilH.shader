
Shader "Custom/_lightingStencilH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		_MainTex ("Main texture", 2D) = "white" {}
		[Header(Normal)]
		_NormalMap ("Normal Map", 2D) = "white" {}
		[KeywordEnum(Off,On)] _UseNormal("Use Normal Map", Float) = 0
		//0 Diffuse
		[Header(Diffuse)]
		_Diffuse ("Diffuse", Range(0,3)) = 1
		[KeywordEnum(Off, Vert, Frag)] _Lighting("Lighting Mode", Float) = 0
		//1 Specular
		[Header(Specular)]
		_SpecularMap ("Specular Map", 2D) = "black" {}
		_SpecularFactor ("Specular Factor", Range(0,1)) = 1
		_SpecularPower ("Specular Power", Float) = 100
		//2 Ambient
		[Header(Ambient)]
		[Toggle] _AmbientMode ("Ambient Light", Float) = 0
		_AmbientFactor ("Ambient Factor", Range(0,1)) = 1
	}

	Subshader
	{
        Tags 
        { 
			//0 Diffuse Check if we still have Transparent
			//NB: Queue Opaque/Transparent change the queue in FrameDebug
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Geometry"
        }
		

		Pass
		{
			Stencil
			{
				Ref 1
				Comp notequal
				Pass keep
			}
			//0 Diffuse
			Tags{"LightMode" = "UniversalForward"}

			//0 Diffuse Check if we still have ZWrite Off and Blending. Comment them
			// ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma shader_feature _USENORMAL_ON _USENORMAL_OFF
			//0 Diffuse
			#pragma shader_feature _LIGHTING_OFF _LIGHTING_VERT _LIGHTING_FRAG
			//2 Ambient
			//Defined by the toggle button
			#pragma shader_feature _AMBIENTMODE_OFF _AMBIENTMODE_ON

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Lighting.hlsl" 
			//0 Diffuse
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			//0 Diffuse
			uniform float _Diffuse;
			//1 Specular
			uniform sampler2D _SpecularMap;
			uniform float _SpecularFactor;
			uniform float _SpecularPower;
			//2 Ambient
			#if _AMBIENTMODE_ON
				uniform float _AmbientFactor;
			#endif

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normal : NORMAL;
				#if _USENORMAL_ON
					float4 tangent : TANGENT;
				#endif
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normalWorld : TEXCOORD1;
				#if _USENORMAL_ON
					float4 tangentWorld : TEXCOORD2;
					float3 binormalWorld : TEXCOORD3;
					float4 normalTexCoord: TEXCOORD4;
				#endif
				//0 Diffuse
				#if _LIGHTING_VERT
					float4 surfaceColor : COLOR0;
				#endif
				//1 Specular
				#if _LIGHTING_FRAG
					float4 posWorld : TEXCOORD5;
					//2 Ambient
					#if _AMBIENTMODE_ON
						float3 ambientColor : COLOR1;
					#endif
				#endif
			};

			//These methods are inside Lighting.HLSL:
			//	- normalFromColor
			//	- 0 DiffuseLambert
			//	- 1 SpecularBlinnPhong

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				o.normalWorld	= float4(TransformObjectToWorldNormal(v.normal.xyz), v.normal.w);
				#if _USENORMAL_ON
					o.tangentWorld = float4(normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz)),v.tangent.w);
					o.binormalWorld	= float3(normalize(cross(o.normalWorld.xyz,  o.tangentWorld.xyz) * v.tangent.w));
					o.binormalWorld *=	unity_WorldTransformParams.w;
					o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);
				#endif

				//0 Diffuse We need ambientColor here to not duplicate the calculation for VERT/FRAG LIGHTING
				half3 ambientColor = half3(0,0,0);

				//2 Ambient
				#if _AMBIENTMODE_ON
					ambientColor = _AmbientFactor * half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
				#endif
				//0 Diffuse
				#if _LIGHTING_VERT
					half4 albedoColor;
					half3 specularColor, diffuseColor;
					specularColor = diffuseColor = half3(0,0,0);
					albedoColor = half4(1,1,1,1);

					Light light = GetMainLight();
					float3 lightDir = normalize(light.direction.xyz);
					float3 lightColor = light.color;
					float attenuation = 1;
					
					//4 Adding USENORMAL_ON also on vertex lighting
					#if _USENORMAL_ON
						half4 normalColor = tex2Dlod(_NormalMap, float4(o.normalTexCoord.xy,0,0));
						float3 TSNormal = normalFromColor(normalColor);
						float3x3 TBNWorld = float3x3 (o.tangentWorld.xyz, o.binormalWorld.xyz, o.normalWorld.xyz);
						o.normalWorld.xyz = normalize(mul(TSNormal, TBNWorld));
					#endif

					diffuseColor = DiffuseLambert(	o.normalWorld,
													lightDir,
													lightColor,
													_Diffuse,
													attenuation);

					//3 Albedo
					albedoColor = tex2Dlod(_MainTex, float4(o.texcoord.xy, 0,0));

					//1 Specular
					float4 vPosWorld = mul(unity_ObjectToWorld, v.vertex);
					float3 V = normalize(_WorldSpaceCameraPos.xyz - vPosWorld);					
					float3 specularMapColor = tex2Dlod(_SpecularMap, float4(o.texcoord.xy, 0, 0));
					specularColor = SpecularBlinnPhong(	o.normalWorld,
																lightDir,
																V,
																specularMapColor.xyz,
																_SpecularFactor,
																attenuation,
																_SpecularPower);

					o.surfaceColor = float4(diffuseColor * albedoColor.rgb * _Color.rgb + specularColor + ambientColor, albedoColor.a * _Color.a);
				//1 Specular
				#elif _LIGHTING_FRAG
					//NB: If o.posWorld is not calculated here, SceneView shows a correct result, gameView doesn't (o.posWorld is missing)
					o.posWorld = mul(unity_ObjectToWorld, v.vertex);
					//2 Ambient
					#if _AMBIENTMODE_ON
						o.ambientColor = ambientColor;
					#endif
				#endif


				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				//0 Diffuse finalColor, normalWorldAtPixel are global vars now
				half4 finalColor;
				float3 normalWorldAtPixel;
				
				#if _USENORMAL_ON
					half4 normalColor = tex2D(_NormalMap, i.normalTexCoord);
					float3 TSNormal = normalFromColor(normalColor);
					float3x3 TBNWorld = float3x3 (i.tangentWorld.xyz, i.binormalWorld.xyz, i.normalWorld.xyz);
					normalWorldAtPixel = normalize(mul(TSNormal, TBNWorld));
					//0 Diffuse finalColor is returned at the end
					//finalColor = float4(normalWorldAtPixel, 1);
					//return finalColor;
				#else
					//0 Diffuse normalWorldAtPixel should be initialized also in this step
					normalWorldAtPixel = i.normalWorld.xyz;
					//0 Diffuse If Lighting is off, finalcolor  is returned at the end
					//finalColor = float4(i.normalWorld.xyz, 1);
				#endif

				//0 Diffuse
				#if _LIGHTING_FRAG
					half4 albedoColor;
					half3 specularColor, diffuseColor, ambientColor;
					specularColor = diffuseColor = ambientColor = half3(0,0,0);
					albedoColor = half4(1,1,1,1);

					Light light = GetMainLight();
					float3 lightDir = normalize(light.direction.xyz);
					float3 lightColor = light.color;
					float attenuation = 1;
					
					//NB: normal is normalWorldAtPixel now
					diffuseColor = DiffuseLambert(	normalWorldAtPixel,
															lightDir,
															lightColor,
															_Diffuse,
															attenuation);

					//3 Albedo
					albedoColor = tex2D(_MainTex, i.texcoord);

					//1 Specular
					float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
					float3 specularMapColor = tex2Dlod(_SpecularMap, float4(i.texcoord.xy, 0, 0));
					specularColor = SpecularBlinnPhong(	normalWorldAtPixel,
																lightDir,
																V,
																specularMapColor.xyz,
																_SpecularFactor,
																attenuation,
																_SpecularPower);

					//2 Ambient
					#if _AMBIENTMODE_ON
						ambientColor = i.ambientColor;
					#endif

					//0 Diffuse with all contributors (initialized even if not present)
					finalColor = float4(diffuseColor * albedoColor.rgb * _Color.rgb + specularColor + ambientColor, albedoColor.a * _Color.a);
				#elif _LIGHTING_VERT
					finalColor = i.surfaceColor;
				#else
					finalColor = float4(normalWorldAtPixel,1);
				#endif

				return finalColor;
			}

			ENDHLSL
		}
		
		Pass
		{
			Stencil
			{
				Ref 1
				Comp equal
				Pass keep
			}
			//0 Diffuse
			Tags{"LightMode" = "UniversalForward"}

			//0 Diffuse Check if we still have ZWrite Off and Blending. Comment them
			// ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma shader_feature _USENORMAL_ON _USENORMAL_OFF
			//0 Diffuse
			#pragma shader_feature _LIGHTING_OFF _LIGHTING_VERT _LIGHTING_FRAG
			//2 Ambient
			//Defined by the toggle button
			#pragma shader_feature _AMBIENTMODE_OFF _AMBIENTMODE_ON

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Lighting.hlsl" 
			//0 Diffuse
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			//0 Diffuse
			uniform float _Diffuse;
			//1 Specular
			uniform sampler2D _SpecularMap;
			uniform float _SpecularFactor;
			uniform float _SpecularPower;
			//2 Ambient
			#if _AMBIENTMODE_ON
				uniform float _AmbientFactor;
			#endif

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normal : NORMAL;
				#if _USENORMAL_ON
					float4 tangent : TANGENT;
				#endif
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normalWorld : TEXCOORD1;
				#if _USENORMAL_ON
					float4 tangentWorld : TEXCOORD2;
					float3 binormalWorld : TEXCOORD3;
					float4 normalTexCoord: TEXCOORD4;
				#endif
				//0 Diffuse
				#if _LIGHTING_VERT
					float4 surfaceColor : COLOR0;
				#endif
				//1 Specular
				#if _LIGHTING_FRAG
					float4 posWorld : TEXCOORD5;
					//2 Ambient
					#if _AMBIENTMODE_ON
						float3 ambientColor : COLOR1;
					#endif
				#endif
			};

			//These methods are inside Lighting.HLSL:
			//	- normalFromColor
			//	- 0 DiffuseLambert
			//	- 1 SpecularBlinnPhong

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				o.normalWorld	= float4(TransformObjectToWorldNormal(v.normal.xyz), v.normal.w);
				#if _USENORMAL_ON
					o.tangentWorld = float4(normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz)),v.tangent.w);
					o.binormalWorld	= float3(normalize(cross(o.normalWorld.xyz,  o.tangentWorld.xyz) * v.tangent.w));
					o.binormalWorld *=	unity_WorldTransformParams.w;
					o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);
				#endif

				//0 Diffuse We need ambientColor here to not duplicate the calculation for VERT/FRAG LIGHTING
				half3 ambientColor = half3(0,0,0);

				//2 Ambient
				#if _AMBIENTMODE_ON
					ambientColor = _AmbientFactor * half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
				#endif
				//0 Diffuse
				#if _LIGHTING_VERT
					half4 albedoColor;
					half3 specularColor, diffuseColor;
					specularColor = diffuseColor = half3(0,0,0);
					albedoColor = half4(1,1,1,1);

					Light light = GetMainLight();
					float3 lightDir = normalize(light.direction.xyz);
					float3 lightColor = light.color;
					float attenuation = 1;
					
					//4 Adding USENORMAL_ON also on vertex lighting
					#if _USENORMAL_ON
						half4 normalColor = tex2Dlod(_NormalMap, float4(o.normalTexCoord.xy,0,0));
						float3 TSNormal = normalFromColor(normalColor);
						float3x3 TBNWorld = float3x3 (o.tangentWorld.xyz, o.binormalWorld.xyz, o.normalWorld.xyz);
						o.normalWorld.xyz = normalize(mul(TSNormal, TBNWorld));
					#endif

					diffuseColor = DiffuseLambert(	o.normalWorld,
													lightDir,
													lightColor,
													_Diffuse,
													attenuation);

					//3 Albedo
					albedoColor = tex2Dlod(_MainTex, float4(o.texcoord.xy, 0,0));

					//1 Specular
					float4 vPosWorld = mul(unity_ObjectToWorld, v.vertex);
					float3 V = normalize(_WorldSpaceCameraPos.xyz - vPosWorld);					
					float3 specularMapColor = tex2Dlod(_SpecularMap, float4(o.texcoord.xy, 0, 0));
					specularColor = SpecularBlinnPhong(	o.normalWorld,
																lightDir,
																V,
																specularMapColor.xyz,
																_SpecularFactor,
																attenuation,
																_SpecularPower);

					o.surfaceColor = float4(diffuseColor * albedoColor.rgb * _Color.rgb + specularColor + ambientColor, albedoColor.a * _Color.a);
				//1 Specular
				#elif _LIGHTING_FRAG
					//NB: If o.posWorld is not calculated here, SceneView shows a correct result, gameView doesn't (o.posWorld is missing)
					o.posWorld = mul(unity_ObjectToWorld, v.vertex);
					//2 Ambient
					#if _AMBIENTMODE_ON
						o.ambientColor = ambientColor;
					#endif
				#endif


				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				//0 Diffuse finalColor, normalWorldAtPixel are global vars now
				half4 finalColor;
				float3 normalWorldAtPixel;
				
				#if _USENORMAL_ON
					half4 normalColor = tex2D(_NormalMap, i.normalTexCoord);
					float3 TSNormal = normalFromColor(normalColor);
					float3x3 TBNWorld = float3x3 (i.tangentWorld.xyz, i.binormalWorld.xyz, i.normalWorld.xyz);
					normalWorldAtPixel = normalize(mul(TSNormal, TBNWorld));
					//0 Diffuse finalColor is returned at the end
					//finalColor = float4(normalWorldAtPixel, 1);
					//return finalColor;
				#else
					//0 Diffuse normalWorldAtPixel should be initialized also in this step
					normalWorldAtPixel = i.normalWorld.xyz;
					//0 Diffuse If Lighting is off, finalcolor  is returned at the end
					//finalColor = float4(i.normalWorld.xyz, 1);
				#endif

				//0 Diffuse
				#if _LIGHTING_FRAG
					half4 albedoColor;
					half3 specularColor, diffuseColor, ambientColor;
					specularColor = diffuseColor = ambientColor = half3(0,0,0);
					albedoColor = half4(1,1,1,1);

					Light light = GetMainLight();
					float3 lightDir = normalize(light.direction.xyz);
					float3 lightColor = light.color;
					float attenuation = 1;
					
					//NB: normal is normalWorldAtPixel now
					diffuseColor = DiffuseLambert(	normalWorldAtPixel,
															lightDir,
															lightColor,
															_Diffuse,
															attenuation);

					//3 Albedo
					albedoColor = tex2D(_MainTex, i.texcoord);

					//1 Specular
					float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
					float3 specularMapColor = tex2Dlod(_SpecularMap, float4(i.texcoord.xy, 0, 0));
					specularColor = SpecularBlinnPhong(	normalWorldAtPixel,
																lightDir,
																V,
																specularMapColor.xyz,
																_SpecularFactor,
																attenuation,
																_SpecularPower);

					//2 Ambient
					#if _AMBIENTMODE_ON
						ambientColor = i.ambientColor;
					#endif

					//0 Diffuse with all contributors (initialized even if not present)
					finalColor = float4(diffuseColor * albedoColor.rgb * _Color.rgb + specularColor + ambientColor, 0.3);
				#elif _LIGHTING_VERT
					finalColor = i.surfaceColor;
				#else
					finalColor = float4(normalWorldAtPixel,1);
				#endif

				return finalColor;
			}

			ENDHLSL
		}
	}
}

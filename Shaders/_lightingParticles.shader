// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_lightingParticles"
{
	Properties
	{
		_MainTexture ("Main texture", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "white" {}
		[KeywordEnum(Off,On)] _UseNormal("Use Normal Map", Float) = 0
		_Diffuse ("Diffuse", Range(0,1)) = 1
		[KeywordEnum(Off, Vert, Frag)] _Lighting("Lighting Mode", Float) = 0
		_SpecularMap ("Specular Map", 2D) = "black" {}
		_SpecularFactor ("Specular Factor", Range(0,1)) = 1
		_SpecularPower ("Specular Power", Float) = 100
		[Toggle] _AmbientMode ("Ambient Light", Float) = 0
		_AmbientFactor ("Ambient Factor", Range(0,1)) = 1

		//3
		_BurnTolerance("Burn Tolerance", Range(0,100)) = 20
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType" = "Transparent"}
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "CGLighting.cginc"
			#include "UnityCG.cginc"
			#pragma shader_feature _USENORMAL_OFF _USENORMAL_ON 
			#pragma shader_feature _LIGHTING_OFF _LIGHTING_VERT _LIGHTING_FRAG
			#pragma shader_feature _AMBIENTMODE_OFF _AMBIENTMODE_ON
			
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;

			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;

			uniform float _Diffuse;
			uniform float4 _LightColor0; 

			uniform sampler2D _SpecularMap;
			uniform float _SpecularFactor;
			uniform float _SpecularPower;
			
			//3
			uniform float _BurnTolerance;

			#if _AMBIENTMODE_ON
				uniform float _AmbientFactor;
			#endif
			
			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				
				#if _USENORMAL_ON
					float4 tangent : TANGENT;
				#endif

				//1
				fixed4 color : COLOR;
				//5
	            float4 customData : TEXCOORD1; //custom data vertex stream
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normalWorld : TEXCOORD1;
				float4 posWorld	: TEXCOORD5;

				#if _USENORMAL_ON
					float4 tangentWorld : TEXCOORD2;
					float3 binormalWorld : TEXCOORD3;
					float4 normalTexCoord: TEXCOORD4;
				#endif
				#if _LIGHTING_VERT
					float4 surfaceColor : COLOR0;
				#endif

				//1
				fixed4 vColor : COLOR1;

				//5
	            float4 customData : TEXCOORD6; //custom data vertex stream
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o; UNITY_INITIALIZE_OUTPUT(vertexOutput, o); // d3d11 requires initialization
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);

				o.normalWorld	= float4(UnityObjectToWorldNormal(v.normal.xyz), v.normal.w);

				#if _USENORMAL_ON
					o.tangentWorld	= float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
					o.binormalWorld	= float3(normalize(cross(o.normalWorld.xyz,  o.tangentWorld.xyz) * v.tangent.w));
					o.binormalWorld *=	unity_WorldTransformParams.w;
					o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);
				#endif

				#if _LIGHTING_VERT
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					float3 lightColor = _LightColor0.xyz;
					float attenuation = 1;
					
					float3 diffuseColor = DiffuseLambert(	o.normalWorld,
															lightDir,
															lightColor,
															_Diffuse,
															attenuation);

					float3 vWorldPos = mul(unity_ObjectToWorld, v.vertex);
					float3 V = normalize(_WorldSpaceCameraPos.xyz - vWorldPos);
					
					float3 specularMapColor = tex2Dlod(_SpecularMap, float4(o.texcoord.xy, 0, 0));
					float3 specularColor = SpecularBlinnPhong(	o.normalWorld,
																lightDir,
																V,
																specularMapColor.xyz,
																_SpecularFactor,
																attenuation,
																_SpecularPower);
					
					float3 mainTexCol = tex2Dlod(_MainTexture, float4(o.texcoord.xy, 0,0));
					
					o.surfaceColor = float4(mainTexCol * _MainColor * diffuseColor + specularColor,1);
					
					//1
					o.surfaceColor *= v.color;

					#if _AMBIENTMODE_ON
						float3 ambientColor = _AmbientFactor * UNITY_LIGHTMODEL_AMBIENT;
						o.surfaceColor = float4(o.surfaceColor.rgb + ambientColor, 1);
					#endif

				#endif

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);

				//1
				o.vColor = v.color;
				//5
				o.customData = v.customData;

				return o;
			}
			half4 frag(vertexOutput i): COLOR
			{
				half4 albedoColor = tex2D(_MainTexture, i.texcoord);


				#if _USENORMAL_ON
					float3 normalWorldAtPixel = WorldNormalFromNormalMap(_NormalMap,i.normalTexCoord.xy,i.tangentWorld.xyz,i.binormalWorld.xyz,i.normalWorld.xyz);
				#else
					float3 normalWorldAtPixel = i.normalWorld.xyz;
				#endif
				
				#if _LIGHTING_FRAG
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					float3 lightColor = _LightColor0.xyz;
					float attenuation = 1;
					float3 diffuseColor = DiffuseLambert(	normalWorldAtPixel,
															lightDir,
															lightColor,
															_Diffuse,
															attenuation);

					float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					float3 specularMapColor = tex2Dlod(_SpecularMap, float4(i.texcoord.xy, 0, 0));
					float3 specularColor = SpecularBlinnPhong(	normalWorldAtPixel,
																lightDir,
																V,
																specularMapColor.xyz,
																_SpecularFactor,
																attenuation,
																_SpecularPower);
					//2
					float finalAlpha = albedoColor.a;
					finalAlpha *= i.vColor.a;

					//6
					//Now particles at the end are fully transparent
					finalAlpha -= i.customData.x;

					//4
					//Returns x saturated to the range [0,1] as follows:
					// 1) Returns 0 if x is less than 0; else
					// 2) Returns 1 if x is greater than 1; else
					// 3) Returns x otherwise.
					// For vectors, the returned vector contains the saturated result of each element of the vector x saturated to [0,1].
					finalAlpha = saturate (finalAlpha * _BurnTolerance);

					//7
					float4 emissive;
					emissive.rgb = lerp (i.customData.yzw, float3 (0,0,0), finalAlpha);

					//8
					clip (finalAlpha);

					#if _AMBIENTMODE_ON
						float3 ambientColor = _AmbientFactor * UNITY_LIGHTMODEL_AMBIENT;
						//1 - add i.vColor *
						float4 finalColor = float4(albedoColor * diffuseColor + specularColor + ambientColor, finalAlpha);
						
						//7 add emissive
						finalColor.rgb += emissive.rgb;
						return  i.vColor * finalColor;
					#else
						//1 - add i.vColor *
						float4 finalColor = float4(albedoColor * diffuseColor + specularColor, finalAlpha);
						//7 add emissive
						finalColor.rgb += emissive.rgb;
						return  i.vColor * finalColor;
					#endif

				#elif _LIGHTING_VERT
					return i.surfaceColor;
				#else
					return float4(normalWorldAtPixel,1);
				#endif

			}

			ENDCG
		}

		
	}
}

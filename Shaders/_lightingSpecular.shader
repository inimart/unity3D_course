// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_lightingSpecular"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "white" {}
		[KeywordEnum(Off,On)] _UseNormal("Use Normal Map", Float) = 0
		_Diffuse ("Diffuse", Range(0,1)) = 1
		[KeywordEnum(Off, Vert, Frag)] _Lighting("Lighting Mode", Float) = 0
		//1
		_SpecularMap ("Specular Map", 2D) = "black" {}
		_SpecularFactor ("Specular Factor", Range(0,1)) = 1
		_SpecularPower ("Specular Power", Float) = 100
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType" = "Transparent"}
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "CGLighting.cginc"
			#pragma shader_feature _USENORMAL_OFF _USENORMAL_ON 
			#pragma shader_feature _LIGHTING_OFF _LIGHTING_VERT _LIGHTING_FRAG
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;

			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;

			uniform float _Diffuse;
			uniform float4 _LightColor0; 

			//1
			uniform sampler2D _SpecularMap;
			uniform float _SpecularFactor;
			uniform float _SpecularPower;
			
			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float4 texcoord : TEXCOORD0;

				#if _USENORMAL_ON
					float4 tangent : TANGENT;
				#endif
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normalWorld : TEXCOORD1;
				//8
				#if _LIGHTING_FRAG
					float4 posWorld	: TEXCOORD5;
				#endif

				#if _USENORMAL_ON
					float4 tangentWorld : TEXCOORD2;
					//binormal is a float3 because cross product is defined only for 3 or 7-dimensional vectors
					float3 binormalWorld : TEXCOORD3;
					float4 normalTexCoord: TEXCOORD4;
				#endif
				#if _LIGHTING_VERT
					float4 surfaceColor : COLOR0;
				#endif
			};

			/*
			float3 DiffuseLambert(float3 normalVal, float3 lightDir, float3 lightColor, float diffuseFactor, float attenuation)
			{
				return lightColor * diffuseFactor * attenuation * max(0, dot(normalVal,lightDir));
			}

			//3
			float3 SpecularBlinnPhong(float3 N, float3 L, float3 V, float3 specularColor, float specularFactor, float attenuation, float specularPower)
			{
				//specularColor is readed from SpecularMap
				//specularFactor & specularPower are material properties
				//V is View in world space
				float3 H = normalize(L+V);
				return specularColor * specularFactor * attenuation * pow(max(0, dot(N,H)), specularPower);
			}
			*/

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
					//For directional lights, _WorldSpaceLightPos0.xyz is the direction of the light
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					float3 lightColor = _LightColor0.xyz;
					float attenuation = 1;
					
					//2
					float3 diffuseColor = DiffuseLambert(	o.normalWorld,
															lightDir,
															lightColor,
															_Diffuse,
															attenuation);
					//4
					float3 vWorldPos = mul(unity_ObjectToWorld, v.vertex);
					float3 V = normalize(_WorldSpaceCameraPos.xyz - vWorldPos);
					
					//5
					//Since we are sampling a texture in the VS, we need to specify the Mipmap level using Tex2Dlod
					float3 specularMapColor = tex2Dlod(_SpecularMap, float4(o.texcoord.xy, 0, 0));
					//3
					float3 specularColor = SpecularBlinnPhong(	o.normalWorld,
																lightDir,
																V,
																specularMapColor.xyz,
																_SpecularFactor,
																attenuation,
																_SpecularPower);
					//2
					//o.surfaceColor = float4(diffuseColor, 1);
					//6
					o.surfaceColor = float4(diffuseColor+specularColor, 1);
				#endif

				//8
				#if _LIGHTING_FRAG
					o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				#endif

				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				//For now we don't need albedo texture color
				//half4 texColor = tex2D(_MainTexture, i.texcoord);
				//half4 finalColor = _MainColor * texColor;

				#if _USENORMAL_ON
					float3 normalWorldAtPixel = WorldNormalFromNormalMap(_NormalMap,i.normalTexCoord.xy,i.tangentWorld.xyz,i.binormalWorld.xyz,i.normalWorld.xyz);
				#else
					float3 normalWorldAtPixel = i.normalWorld.xyz;
				#endif

				#if _LIGHTING_FRAG
					//For directional lights, _WorldSpaceLightPos0.xyz is the direction of the light
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					float3 lightColor = _LightColor0.xyz;
					float attenuation = 1;
					//7
					float3 diffuseColor = DiffuseLambert(	normalWorldAtPixel,
															lightDir,
															lightColor,
															_Diffuse,
															attenuation);

					//8
					//float3 vWorldPos = mul(unity_ObjectToWorld, i.pos);
					//float3 V = normalize(_WorldSpaceCameraPos.xyz - vWorldPos);
					float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					
					//6
					float3 specularMapColor = tex2Dlod(_SpecularMap, float4(i.texcoord.xy, 0, 0));
					float3 specularColor = SpecularBlinnPhong(	normalWorldAtPixel,
																lightDir,
																V,
																specularMapColor.xyz,
																_SpecularFactor,
																attenuation,
																_SpecularPower);
					//7
					return float4(diffuseColor + specularColor, 1);

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

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_lightingAmbientFlag"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
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

		_Frequency ("Frequency", float) = 1
		_Amplitude ("Amplitude", float) = 1
		_Speed ("Speed", float) = 1
		_StartFrom ("Start from", Range(0,1)) = 0
		_SmoothingNormal ("Smoothing Normal", Range(0,1)) = 0
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType" = "Transparent"}
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma target 4.0
			#pragma vertex vert
			#pragma fragment frag
			#include "CGLighting.cginc"
			#include "UnityCG.cginc"
			#pragma shader_feature _USENORMAL_OFF _USENORMAL_ON 
			#pragma shader_feature _LIGHTING_OFF _LIGHTING_VERT _LIGHTING_FRAG
			#pragma shader_feature _AMBIENTMODE_OFF _AMBIENTMODE_ON
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;

			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;

			uniform float _Diffuse;
			uniform float4 _LightColor0; 

			uniform sampler2D _SpecularMap;
			uniform float _SpecularFactor;
			uniform float _SpecularPower;

			uniform float _Amplitude;
			uniform float _Frequency;
			uniform float _Speed;
			uniform float _StartFrom;
			uniform float _SmoothingNormal;

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
			};

			float4 flagMovement(float4 vIn, float2 uv, out float3 n)
			{
				vIn.y = vIn.y + (sin( (uv.x - (_Time.y*_Speed))*_Frequency)) * (_Amplitude * smoothstep(_StartFrom, 1, uv.x));
				float height1 =  (sin( (uv.x - (_Time.y*_Speed))*_Frequency)) * (_Amplitude * smoothstep(_StartFrom, 1, uv.x));
				float height2 =  (sin( (uv.x*2 - (2*_Time.y*_Speed))*_Frequency*2)) * (_Amplitude * smoothstep(_StartFrom, 1, uv.x) * 0.5);
				vIn.y += (height1 + height2);

				//Add two fake vertices
				float3 vIn1 = vIn + float3(0.05,0,0);
				float3 vIn2 = vIn + float3(0,0,0.05);
				vIn1.y += (height1 + height2);
				vIn2.y += (height1 + height2);
				vIn1.y -= (vIn1.y - vIn.y) * _SmoothingNormal;
				vIn2.y -= (vIn2.y - vIn.y) * _SmoothingNormal;
				n = normalize(cross(vIn2-vIn, vIn1-vIn));

				return vIn;
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				UNITY_INITIALIZE_OUTPUT(vertexOutput, o); // d3d11 requires initialization
				v.vertex = flagMovement(v.vertex, v.texcoord, v.normal.xyz);
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
					//o.surfaceColor = float4(diffuseColor+specularColor, 1);

					//4
					#if _AMBIENTMODE_ON
						float3 ambientColor = _AmbientFactor * UNITY_LIGHTMODEL_AMBIENT;
						o.surfaceColor = float4(o.surfaceColor.rgb + ambientColor, 1);
					#endif

				#endif

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);

				return o;
			}
			half4 frag(vertexOutput i): COLOR
			{
				//6
				half4 albedoColor = tex2D(_MainTexture, i.texcoord);
				albedoColor = _MainColor * albedoColor;

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

					//5
					#if _AMBIENTMODE_ON
						float3 ambientColor = _AmbientFactor * UNITY_LIGHTMODEL_AMBIENT;
						//return float4(diffuseColor + specularColor + ambientColor, 1);
						
						//6
						return float4(albedoColor * diffuseColor + specularColor + ambientColor, 1);
					#else
						//return float4(diffuseColor + specularColor, 1);
						
						//6
						return float4(albedoColor * diffuseColor + specularColor, albedoColor.a);
					#endif

				#elif _LIGHTING_VERT
					return i.surfaceColor;
				#else
					return float4(normalWorldAtPixel,albedoColor.a);
				#endif
			}

			ENDCG
		}

		
	}
}

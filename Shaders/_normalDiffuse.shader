
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_normalDiffuse"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "white" {}
		//1
		_Diffuse ("Diffuse", Range(0,1)) = 1
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "true"}
		Pass
		{
			//0
			Tags{"LightMode" = "ForwardBase"}

			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			//1
			uniform float _Diffuse;
			uniform float4 _LightColor0; //_LightColor0 is a built-in Unity variable. Since it is defined in UnityLightingcommon.cginc, we have to declare it as a uniform 

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normal : NORMAL;
				float4 tangent : TANGENT;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;

				float4 texcoord : TEXCOORD0;
				float4 normalWorld : TEXCOORD1;
				float4 tangentWorld : TEXCOORD2;
				float3 binormalWorld : TEXCOORD3;
				float4 normalTexCoord: TEXCOORD4;
			};


			float3 DiffuseLambert(float3 normalVal, float3 lightDir, float3 lightColor, float diffuseFactor, float attenuation)
			{
				return lightColor * diffuseFactor * attenuation * max(0, dot(normalVal,lightDir));
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);
				o.normalWorld	= float4(UnityObjectToWorldNormal(v.normal.xyz), v.normal.w);
				o.tangentWorld	= float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				o.binormalWorld		= float3(normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w));
				o.binormalWorld *=	unity_WorldTransformParams.w;
				o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);

				return o;
			}

			float3 normalFromColor(float4 color)
			{
				#if defined(UNITY_NO_DXT5nm)
					return color.xyz * 2 - 1;
				#else
					float3 normalDecompressed;
					normalDecompressed = float3 (	color.a * 2 - 1,
													color.g * 2 - 1,
													0.0);
					normalDecompressed.z = sqrt(1 - dot(normalDecompressed.xy, normalDecompressed.xy));
					return normalDecompressed;
				#endif
			}

			half4 frag(vertexOutput i): COLOR
			{
				half4 normalColor = tex2D(_NormalMap, i.normalTexCoord);

				float3 TSNormal = normalFromColor(normalColor);

				float3x3 TBNWorld = float3x3(	i.tangentWorld.x, i.binormalWorld.x, i.normalWorld.x,
												i.tangentWorld.y, i.binormalWorld.y, i.normalWorld.y,
												i.tangentWorld.z, i.binormalWorld.z, i.normalWorld.z);
				float3 normalWorldAtPixel = normalize(mul(TBNWorld, TSNormal));

				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 lightColor = _LightColor0.xyz;
				float attenuation = 1;
				//return float4(lightColor,1);
				float4 finalColor = float4(DiffuseLambert(normalWorldAtPixel, lightDir, lightColor, _Diffuse, attenuation), 1);
				half4 texColor = tex2D(_MainTexture, i.texcoord) * _MainColor;
				finalColor *= texColor;

				return finalColor;
			}

			ENDCG
		}
	}
}

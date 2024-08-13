﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_normalMulti"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "white" {}
		//1
		[KeywordEnum(Off,On)] _UseNormal("Use Normal Map", Float) = 0
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "true"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			//2
			#pragma shader_feature _USENORMAL_ON _USENORMAL_OFF
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normal : NORMAL;
				//3
				#if _USENORMAL_ON
					float4 tangent : TANGENT;
				#endif
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normalWorld : TEXCOORD1;

				//3
				#if _USENORMAL_ON
					float4 tangentWorld : TEXCOORD2;
					//binormal is a float3 because cross product is defined only for 3 or 7-dimensional vectors
					float3 binormalWorld : TEXCOORD3;
					float4 normalTexCoord: TEXCOORD4;
				#endif
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);

				//o.normalWorld = float4(normalize(mul(normalize(v.normal.xyz), (float3x3)unity_WorldToObject)),v.normal.w);
				o.normalWorld	= float4(UnityObjectToWorldNormal(v.normal.xyz), v.normal.w);

				//3
				#if _USENORMAL_ON
					o.tangentWorld	= float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
					o.binormalWorld	= float3(normalize(cross(o.normalWorld.xyz,  o.tangentWorld.xyz) * v.tangent.w));
					o.binormalWorld *=	unity_WorldTransformParams.w;
					o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);
				#endif

				return o;
			}

			float3 normalFromColor(float4 color)
			{
				#if defined(UNITY_NO_DXT5nm)
					return color.xyz * 2 - 1;
				// W/o RGB => xyz
				// With DXT Compression, RGB => AG => xy
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
				//For now we don't need albedo texture color
				//half4 texColor = tex2D(_MainTexture, i.texcoord);
				//half4 finalColor = _MainColor * texColor;

				//3
				#if _USENORMAL_ON
					half4 normalColor = tex2D(_NormalMap, i.normalTexCoord);
					//This is a TangentSpaceNormal read from the NormalMap texture
					float3 TSNormal = normalFromColor(normalColor);

					//Calculate TBN matrix based on values passed from VS
					float3x3 TBNWorld = float3x3 (i.tangentWorld.xyz, i.binormalWorld.xyz, i.normalWorld.xyz);
					float3 normalWorldAtPixel = normalize(mul(TSNormal, TBNWorld));
					half4 finalColor = float4(normalWorldAtPixel, 1);
					return finalColor;
				#else
				//If we don't use NormalMap, all we have to do is return the interpolated normalWorld value
					return float4(i.normalWorld.xyz, 1);
				#endif
			}

			ENDCG
		}
	}
}

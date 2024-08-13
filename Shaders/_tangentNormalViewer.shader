// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TEST/normal"
{
	Properties
	{
		 _MainColor("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "white" {}
	}
	Subshader
	{
		Tags {"RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector" = "False"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			
			half4 _MainColor;
			sampler2D _MainTexture;
			float4 _MainTexture_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;

			struct vertexInput
			{
				float4 vertex: POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct vertexOutput
			{
				float4 pos: SV_POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normalWorld : TEXCOORD1;
				float4 tangentWorld : TEXCOORD2;
				float3 binormalWorld : TEXCOORD3;
				float4 normalTexCoord : TEXCOORD4;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);
				
				o.normalWorld	= float4(UnityObjectToWorldNormal(v.normal.xyz), v.normal.w);
				o.tangentWorld	= float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				o.binormalWorld	= float3(normalize(cross(o.normalWorld.xyz,  o.tangentWorld.xyz) * v.tangent.w));
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

			half4 frag(vertexOutput o):COLOR
			{
				//half4 texColor = tex2D(_MainTexture, o.texcoord);
				half4 normalColor = tex2D(_NormalMap, o.normalTexCoord);
				float3 TSNormal = normalFromColor(normalColor);

				/*
				float3x3 TBNWorld = float3x3 (	o.tangentWorld.xyz,
												o.binormalWorld.xyz,
												o.normalWorld.xyz);
				*/
				float3x3 TBNWorld = float3x3(	o.tangentWorld.x, o.binormalWorld.x, o.normalWorld.x,
												o.tangentWorld.y, o.binormalWorld.y, o.normalWorld.y,
												o.tangentWorld.z, o.binormalWorld.z, o.normalWorld.z);
				//float3 normalWorldAtPixel = normalize(mul(TSNormal,TBNWorld));
				float3 normalWorldAtPixel = normalize(mul(TBNWorld, TSNormal));
				half4 finalColor = float4(normalWorldAtPixel, 1);

				//half4 finalColor = _MainColor * texColor;
				//half4 finalColor;
				//finalColor = half4(TSNormal,1);
				//finalColor = half4(TSNormal.rrr,1);
				//finalColor = half4(TSNormal.ggg,1);
				//finalColor = half4(TSNormal.bbb,1);
				
				return finalColor;
			}

			ENDCG
		}
	}
}

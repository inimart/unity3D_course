
Shader "Custom/_normalH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		_MainTex ("Main texture", 2D) = "white" {}
		//1
		_NormalMap ("Normal Map", 2D) = "white" {}
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent"
        }

		Pass
		{
			ZWrite Off

			//0
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			//1
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				//1
				float4 normal : NORMAL;
				float4 tangent : TANGENT;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				//1
				float4 normalWorld : TEXCOORD1;
				float4 tangentWorld : TEXCOORD2;
				//binormal is a float3 because cross product is defined only for 3 or 7-dimensional vectors
				float3 binormalWorld : TEXCOORD3;
				float4 normalTexCoord: TEXCOORD4;
			};

			//3.8
			float3 normalFromColor(float4 color)
			{
				//5
				//UNITY_NO_DXT5nm is set when compiling shader for platform that do not support DXT5NM, meaning that normal maps will be encoded in RGB instead
				#if defined(UNITY_NO_DXT5nm)
					//4
					return color.xyz * 2 - 1;
				//5
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

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				//2
				//to multiply a normal and a matrix A we need the transpose inverse of A
				//we don't have transpose inverse of unity_ObjectToWorld, but we have the inverse: unity_WorldToObject
				//if the inverse of A is known, we can obtain the same result of mul(matrix_inverse_transpose_of_A, normal)
				//using mul(normal, matrix_inverse_of_A);
				//o.normalWorld = float4(normalize(mul(normalize(v.normal.xyz), (float3x3)unity_WorldToObject)),v.normal.w);
				//to Simplify:
				o.normalWorld	= float4(TransformObjectToWorldNormal(v.normal.xyz), v.normal.w);
				//2
				//to multiply a direction and a matrix A we simply do 
				//float4 transformed_direction = float4(mul(mymatrix, direction.xyz), 0.0);
				o.tangentWorld = float4(normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz)),v.tangent.w);
				//to Simplify (BIRP, CG Only):
				//o.tangentWorld	= float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				//2
				//binormal is a float3 because cross product is defined only for 3 or 7-dimensional vectors
				//we multiply it by v.tangent.w
				o.binormalWorld		= float3(normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w));
				o.binormalWorld *=	unity_WorldTransformParams.w;
				//2
				o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);

				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
								//For now we don't need albedo texture color
				//half4 texColor = tex2D(_MainTexture, i.texcoord);
				//half4 finalColor = _MainColor * texColor;

				//3
				half4 normalColor = tex2D(_NormalMap, i.normalTexCoord);

				//3.8
				//This is a TangentSpaceNormal read from the NormalMap texture
				float3 TSNormal = normalFromColor(normalColor);

				//6
				/*
				//Calculate Transpose TBN matrix based on values passed from VS
				//We calculate TransposeTBNMatrix for convenience
				float3x3 TBNWorld = float3x3 (	i.tangentWorld.xyz,
												i.binormalWorld.xyz,
												i.normalWorld.xyz);
				//TBNWorld is the TBN Transpose, hence instead of mul(M,v) we have to use mul(v,M)
				float3 normalWorldAtPixel = normalize(mul(TSNormal, TBNWorld));
				*/
				//--6

				//6.5
				//Calculate TBN matrix based on values passed from VS
				float3x3 TBNWorld = float3x3(	i.tangentWorld.x, i.binormalWorld.x, i.normalWorld.x,
												i.tangentWorld.y, i.binormalWorld.y, i.normalWorld.y,
												i.tangentWorld.z, i.binormalWorld.z, i.normalWorld.z);
				//TBNWorld is the TBN, hence we can perform mul(M,v)
				float3 normalWorldAtPixel = normalize(mul(TBNWorld, TSNormal));
				//--6.5

				half4 finalColor = float4(normalWorldAtPixel, 1);

				//2.5 - debug normal in worldspace
				//finalColor = half4(i.normalWorld);
				
				//3.5
				// R not used: filled with 1, here it is why normalColor is Red dominant
				// G: Y
				// B not used. It may contain the same content of G channel
				// A: X
				//finalColor = i.normalWorld; //This is the correct normal from the mesh in WSpace!
				//finalColor = normalColor;
				//finalColor = half4(normalColor.rrr,1);
				//finalColor = half4(normalColor.ggg,1);
				//finalColor = half4(normalColor.bbb,1);
				//finalColor = half4(normalColor.aaa,1);
				//--3.5

				return finalColor;
			}

			ENDHLSL
		}
	}
}

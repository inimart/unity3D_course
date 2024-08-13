
Shader "Custom/_normalDiffuseH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		_MainTex ("Main texture", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "white" {}
		//1
		_Diffuse ("Diffuse", Range(0,1)) = 1
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent"
        }

		Pass
		{
			Tags{"LightMode" = "UniversalForward"}

			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			//1
			uniform float _Diffuse;

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

			float3 DiffuseLambert(float3 normalVal, float3 lightDir, float3 lightColor, float diffuseFactor, float attenuation)
			{
				return lightColor * diffuseFactor * attenuation * max(0, dot(normalVal,lightDir));
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				o.normalWorld	= float4(TransformObjectToWorldNormal(v.normal.xyz), v.normal.w);
				o.tangentWorld = float4(normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz)),v.tangent.w);
				o.binormalWorld		= float3(normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w));
				o.binormalWorld *=	unity_WorldTransformParams.w;
				o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);

				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				half4 normalColor = tex2D(_NormalMap, i.normalTexCoord);
				float3 TSNormal = normalFromColor(normalColor);
				float3x3 TBNWorld = float3x3(	i.tangentWorld.x, i.binormalWorld.x, i.normalWorld.x,
												i.tangentWorld.y, i.binormalWorld.y, i.normalWorld.y,
												i.tangentWorld.z, i.binormalWorld.z, i.normalWorld.z);
				float3 normalWorldAtPixel = normalize(mul(TBNWorld, TSNormal));

				//2
				Light light = GetMainLight();
				float3 lightDir = normalize(light.direction.xyz);
				float3 lightColor = light.color;
				float attenuation = 1;
				float4 finalColor = float4(DiffuseLambert(normalWorldAtPixel, lightDir, lightColor, _Diffuse, attenuation), 1);
				half4 texColor = tex2D(_MainTex, i.texcoord) * _Color;
				finalColor *= texColor;

				return finalColor;
			}

			ENDHLSL
		}
	}
}

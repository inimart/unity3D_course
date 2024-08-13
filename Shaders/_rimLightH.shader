
Shader "Custom/_rimLightH"
{
	Properties
	{
		//0 - Remove diffuse, specular, albedo, ambient parameters
		[Header(Normal)]
		_NormalMap ("Normal Map", 2D) = "white" {}
		[KeywordEnum(Off,On)] _UseNormal("Use Normal Map", Float) = 0
		//1
		_RimColor ("Rim color", Color) = (1,1,1,1)
		_RimBorder ("Rim border", Range(0,5)) = 1
		_RimCutOff ("Rim cutOff", Range(0,1)) = 0
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent"
        }

		HLSLINCLUDE
            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
		ENDHLSL
		
		Pass
		{
			//We want to write Zvalues on ZBuffer, but nothing in the framebuffer
			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			struct vertexInput
			{
				float4 vertex : POSITION;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				return fixed4(0,0,0,0);
			}
			ENDHLSL
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma shader_feature _USENORMAL_ON _USENORMAL_OFF
			#include "Lighting.hlsl"

			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			//1
			uniform half4 _RimColor;
			uniform float _RimBorder;
			uniform float _RimCutOff;

			
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
				float4 posWorld : TEXCOORD5;
			};

			float4 rimLight(float3 normalVal, float3 viewDir, float border, float3 rimColor)
			{
				float dotResult = 1-max(0,(dot(normalize(normalVal),normalize(viewDir))));
				dotResult = pow(dotResult, _RimBorder);
				dotResult = dotResult>_RimCutOff?dotResult:0;
				return float4(rimColor * dotResult, dotResult);
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);

				o.normalWorld	= float4(TransformObjectToWorldNormal(v.normal.xyz), v.normal.w);
				#if _USENORMAL_ON
					o.tangentWorld = float4(normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz)),v.tangent.w);
					o.binormalWorld	= float3(normalize(cross(o.normalWorld.xyz,  o.tangentWorld.xyz) * v.tangent.w));
					o.binormalWorld *=	unity_WorldTransformParams.w;
					o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);
				#endif

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				#if _AMBIENTMODE_ON
					o.ambientColor = ambientColor;
				#endif


				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				half4 finalColor;
				float3 normalWorldAtPixel;
				
				#if _USENORMAL_ON
					half4 normalColor = tex2D(_NormalMap, i.normalTexCoord);
					float3 TSNormal = normalFromColor(normalColor);
					float3x3 TBNWorld = float3x3 (i.tangentWorld.xyz, i.binormalWorld.xyz, i.normalWorld.xyz);
					normalWorldAtPixel = normalize(mul(TSNormal, TBNWorld));
				#else
					normalWorldAtPixel = i.normalWorld.xyz;
				#endif

				float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float4 rimLightColor = rimLight(normalWorldAtPixel,
												V,
												_RimBorder,
												_RimColor.rgb);

				finalColor = rimLightColor;
				return finalColor;
			}

			ENDHLSL
		}
	}
}

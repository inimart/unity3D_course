// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_rimLight_XRayMasked"
{
	Properties
	{
		_RimColor ("Rim color", Color) = (1,0,0,1)
		_RimBorder ("Rim border", Range(0,5)) =	1
		_RimCutOff ("Rim cutOff", Range(0,1)) = .5
	}
	Subshader
	{
		Tags{"XRay" = "true" "Queue" = "Geometry+2" "IgnoreProjector" = "true" "RenderType" = "Opaque"}
		
		Stencil
		{
			Ref 0
			Comp NotEqual
			Pass keep
		}
		Pass
		{
			Blend One One
			BlendOp Add
			ZWrite Off
			ZTest Always
			
			CGPROGRAM
			#pragma target 4.0
			#pragma vertex vert
			#pragma fragment frag
			#include "CGLighting.cginc"
			#include "UnityCG.cginc"

			uniform half4 _RimColor;
			uniform float _RimBorder;
			uniform float _RimCutOff;
			
			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normalWorld : TEXCOORD1;
				float4 posWorld	: TEXCOORD5;
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
				UNITY_INITIALIZE_OUTPUT(vertexOutput, o); // d3d11 requires initialization
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normalWorld	= float4(UnityObjectToWorldNormal(v.normal.xyz), v.normal.w);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);

				return o;
			}

			

			half4 frag(vertexOutput i): COLOR
			{
				float3 normalWorldAtPixel = i.normalWorld.xyz;
				float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float4 rimLightColor = rimLight(	normalWorldAtPixel,
														V,
														_RimBorder,
														_RimColor.rgb);
				//return float4(1,1,1,1);
				return float4(rimLightColor);
			}

			ENDCG
		}
		
	}
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_transparentShader"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		[Enum(UnityEngine.Rendering.BlendMode)] _Blend ("Blend mode", Float) = 1
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Blend op", Float) = 1
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent"}
		Pass
		{
		
			//Blend One Zero SrcAlpha OneMinusSrcAlpha SrcColor DstColor DestAlpha
			//BlendOp Min Max Add Sub

			//BlendOp Add	//1 - Additive
			//Blend One One //1 - Additive
			//BlendOp [_BlendOp]	//1 - Additive with Enum
			//Blend [_Blend] [_Blend] //1 - Additive with Enum
			//Blend SrcAlpha OneMinusSrcAlpha //2 - normal (alpha blending)
			//Blend DstColor Zero //3 - multiply
			
			//4 multiply also alpha channel
			BlendOp Add,Add
			Blend DstColor Zero,DstAlpha Zero
			ZWrite Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform half4 _Color;

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
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			half4 frag(vertexOutput i): COLOR
			{
				//return half4(1,0,0,1);
				return _Color;
			}

			ENDCG
		}
	}
}

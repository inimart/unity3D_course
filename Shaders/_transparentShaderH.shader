
Shader "Custom/_transparentShaderH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		//7
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode", Float) = 1
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Blend op", Float) = 1

	}

	Subshader
	{
        Tags 
        { 
			//1 Rendertype Transparent
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent"
        }

		Pass
		{
			//2
			ZWrite Off

			//3 First try with additive
			Blend One One
			BlendOp Add

			//4 Then multiply
			// Blend DstColor Zero
			// BlendOp Add

			//5 Then normal alpha blending
			// Blend SrcAlpha OneMinusSrcAlpha
			// BlendOp Add

			//5.1
			//What we write in 5 is valid also in the alpha channel (see this using a RTarget image). It is the same as:
			//Blend DstColor Zero, DstAlpha Zero
			//BlendOp Add, Add
			//What if we want to have an Add in the alpha channel and maintain a Multiply in the color channel? Use //6 

			//6 Then try to multiply alpha (Visible only in RT image, because ColorBuffer doesn't have alpha!)
			//Blend DstColor Zero, One One
			//BlendOp Add, Add
			
			//8 Use properties enums
			//BlendOp [_BlendOp]	//1 - Additive with Enum
			//Blend [_BlendSrc] [_BlendDst] //1 - Additive with Enum

			//Blend One Zero SrcAlpha OneMinusSrcAlpha SrcColor DstColor DestAlpha
			//BlendOp Min Max Add Sub

			//BlendOp Add	//1 - Additive
			//Blend One One //1 - Additive
			//BlendOp [_BlendOp]	//1 - Additive with Enum
			//Blend [_Blend] [_Blend] //1 - Additive with Enum
			//Blend SrcAlpha OneMinusSrcAlpha //2 - normal (alpha blending)
			//Blend DstColor Zero //3 - multiply

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
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
				o.pos = TransformObjectToHClip(v.vertex);
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				return _Color;
			}

			ENDHLSL
		}
	}
}

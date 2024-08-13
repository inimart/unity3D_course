Shader "Custom/_positionalColorTextureH"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
	}
	Subshader
	{
        Tags { "RenderPipeline"="UniversalRenderPipeline" }

		Pass
		{
			Cull Off

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			half4 _Color;

			struct vertexInput
			{
				float4 vertex : POSITION;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				//0
				float4 textureScreenPos : TEXCOORD0;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				//0
				o.textureScreenPos = ComputeScreenPos(o.pos);

				return o;
			}
			fixed4 frag(vertexOutput o): SV_Target
			{
				//0
				o.textureScreenPos.xy /= o.textureScreenPos.w;
				return half4(o.textureScreenPos.x, o.textureScreenPos.y, 0, 1);
			}

			ENDHLSL
		}
	}
}

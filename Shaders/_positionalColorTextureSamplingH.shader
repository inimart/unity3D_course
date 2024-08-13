Shader "Custom/_positionalColorTextureSamplingH"
{
	Properties
	{
		//0
		_MainTex ("Main texture", 2D) = "white" {}
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

			uniform sampler2D _MainTex;

			struct vertexInput
			{
				float4 vertex : POSITION;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 textureScreenPos : TEXCOORD0;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.textureScreenPos = ComputeScreenPos(o.pos);

				return o;
			}
			half4 frag(vertexOutput o): SV_Target
			{
				return tex2Dproj(_MainTex, o.textureScreenPos);
			}

			ENDHLSL
		}
	}
}

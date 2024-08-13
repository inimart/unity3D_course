
Shader "Custom/_alphaToMask"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Geometry"
        }
		AlphaToMask On

		Pass
		{
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

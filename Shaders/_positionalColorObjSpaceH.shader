Shader "Custom/_positionalColorObjSpaceH"
{
	Properties
	{
		_LeftColor ("LeftColor", Color) = (1,1,1,1)
		_RightColor ("RightColor", Color) = (1,1,1,1)
		//1
		_minX ("minX", Float) = 0
		_maxX ("maxX", Float) = 0
	}
	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline"
        }

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			half4 _LeftColor;
			half4 _RightColor;
			//1.5
			float _minX;
			float _maxX;

			struct vertexInput
			{
				float4 vertex : POSITION;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				//2
				float xRange: DEPTH0;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.xRange = smoothstep(_minX, _maxX, v.vertex.x);
				return o;
			}
			fixed4 frag(vertexOutput o): SV_Target
			{
				//3
				return o.xRange*_LeftColor + (1-o.xRange)*_RightColor;
			}

			ENDHLSL
		}
	}
}

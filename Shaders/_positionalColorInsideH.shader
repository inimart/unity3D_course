Shader "Custom/_positionalColorInsideH"
{
	Properties
	{
		//0
		_OutColor ("OutColor", Color) = (1,1,1,1)
		_IntColor ("InColor", Color) = (1,0,0,1)
	}
	Subshader
	{
        Tags { "RenderPipeline"="UniversalRenderPipeline" }

		Pass
		{

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			half4 _OutColor;
			half4 _IntColor;
			struct vertexInput
			{
				float4 vertex : POSITION;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float inFrontOf : DEPTH0;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				//o.inFrontOf will be 1 or 0
				o.inFrontOf = (o.pos.z/o.pos.w > 0);
				//its z its going to stay at its value of z or it's going to become 0
				o.pos.z *= o.inFrontOf;
				return o;
			}
			fixed4 frag(vertexOutput o): SV_Target
			{
				if(o.inFrontOf > 0)
					return _OutColor;
				return _IntColor;
			}

			ENDHLSL
		}
	}
}

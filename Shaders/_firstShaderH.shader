// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_firstShaderH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
	}
	Subshader
	{
		//3
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry"  
        }

		Pass
		{
			//1
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			//2
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
                //o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//4
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

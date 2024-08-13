// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_positionalColorScreenH"
{
	Properties
	{
	//1
		_LeftColor ("LeftColor", Color) = (1,1,1,1)
		_RightColor ("RightColor", Color) = (1,1,1,1)
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

			//2
			half4 _LeftColor;
			half4 _RightColor;

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
			fixed4 frag(vertexOutput o): SV_Target
			{
				//3
				//This is to have uniform results both in sceneView and in GameView
				float y = o.pos.y;
				if(_ProjectionParams.x < 0)
					y = _ScreenParams.y-y;

				if(o.pos.x < _ScreenParams.x/3.0)
					return half4(_LeftColor.r, _LeftColor.g * (y/_ScreenParams.y), _LeftColor.b, 1);
				else if(o.pos.x < (_ScreenParams.x/3)*2)
					return half4(1,y/_ScreenParams.y,0.5,1);
				else 
					return half4(_RightColor.r, _RightColor.g * (y/_ScreenParams.y), _RightColor.b, 1);
				return _RightColor;
			}

			ENDHLSL
		}
	}
}

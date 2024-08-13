
Shader "Custom/_nearClipPlaneAlphaH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		//0
		_NearTreshold ("NearT", Float) = 1
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent"
        }

		Pass
		{
			ZWrite On

			//0
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			uniform half4 _Color;
			uniform float _NearTreshold;

			struct vertexInput
			{
				float4 vertex : POSITION;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				//0
				float3 view : TEXCOORD0;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				//0
				float4 wPos = mul(unity_ObjectToWorld, v.vertex);
				o.view = wPos.xyz - _WorldSpaceCameraPos;

				return o;
			}
			half4 frag(vertexOutput i): SV_Target
			{
				float a;
				//0
				a = smoothstep(_ProjectionParams.y, _NearTreshold, i.view.z);
				return half4(_Color.rgb, a);
			}

			ENDHLSL
		}
	}
}

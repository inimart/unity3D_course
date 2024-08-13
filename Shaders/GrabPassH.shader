// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/GrabPassH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
	}
	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue"="Transparent" "RenderType"="Transparent"  
        }
		
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			uniform half4 _Color;
			uniform sampler2D _CameraOpaqueTexture;

			struct vertexInput
			{
				float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
                float4 texcoord : TEXCOORD0;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord = v.texcoord;
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				return tex2D(_CameraOpaqueTexture, i.texcoord);
			}

			ENDHLSL
		}
	}
}

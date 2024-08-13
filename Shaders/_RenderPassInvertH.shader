
Shader "Custom/_RenderPassInvertH"
{
	Properties
	{
		_MainTex ("Main texture", 2D) = "white" {}
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Opaque"
        }

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset

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
				o.texcoord.xy = v.texcoord.xy;
				return o;
			}
			half4 frag(vertexOutput i): SV_Target
			{
				half4 texColor = tex2D(_MainTex, i.texcoord);
				return half4(1-texColor);
			}

			ENDHLSL
		}
	}
}

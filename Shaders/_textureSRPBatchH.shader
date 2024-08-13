
Shader "Custom/_textureSRPBatchH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		_MainTex ("Main texture", 2D) = "white" {}
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent"
        }

		Pass
		{
			ZWrite Off

			//0
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			uniform sampler2D _MainTex;
			//CBUFFER_START(UnityPerMaterial)
				uniform half4 _Color;
				uniform float4 _MainTex_ST; //used for Tiling and offset
				float _MipMap;
			//CBUFFER_END

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
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				half4 texColor = tex2D(_MainTex, i.texcoord);
				
				half4 finalColor = _Color * texColor;
				return finalColor;
			}

			ENDHLSL
		}
	}
}

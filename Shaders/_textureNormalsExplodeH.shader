
Shader "Custom/_textureNormalsExplodeH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		_MainTex ("Main texture", 2D) = "white" {}
		_Amplitude ("Amplitude", float) = 1
		_StartFade ("Start Fade", Range(1,5)) = 1
		_EndFade ("End Fade", Range(1,5)) = 1.5
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

			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			uniform float _Amplitude;
			uniform float _StartFade;
			uniform float _EndFade;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normal : NORMAL;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
			};

			float4 normalMovement(float4 vIn, float4 vNormal, float2 uv)
			{
				vIn += (_Amplitude * vNormal);
				return vIn;
			}


			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				v.vertex = normalMovement(v.vertex, v.normal, v.texcoord);
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				half4 texColor = tex2D(_MainTex, i.texcoord);
				half4 finalColor = _Color * texColor;
				float fadeAmount;
				if(_Amplitude > _StartFade)
					fadeAmount = max(0, 1-(_Amplitude - _StartFade) / (_EndFade - _StartFade));
				else 
					fadeAmount = 1;
				finalColor.a = fadeAmount;

				return finalColor;
			}

			ENDHLSL
		}
	}
}

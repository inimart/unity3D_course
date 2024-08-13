// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureNormalsExplode"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		_Amplitude ("Amplitude", Range(1,5)) = 1
		_StartFade ("Start Fade", Range(1,5)) = 1
		_EndFade ("End Fade", Range(1,5)) = 1.5
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "true"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			uniform float _Amplitude;
			uniform float _StartFade;
			uniform float _EndFade;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
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
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				half4 texColor = tex2D(_MainTexture, i.texcoord);
				half4 finalColor = _MainColor * texColor;
				float fadeAmount;
				if(_Amplitude > _StartFade)
					fadeAmount = max(0, 1-(_Amplitude - _StartFade) / (_EndFade - _StartFade));
				else 
					fadeAmount = 1;
				finalColor.a = fadeAmount;

				return finalColor;
			}

			ENDCG
		}
	}
}

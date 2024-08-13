// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureCircleFadeAnimated"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}

		_Center("Center", Float) = 0.5
		_Radius("Radius", Float) = 0.3
		_Fade("Fade", Float) = 0.1
		//
		_FadeSpeed("FadeSpeed", Float) = 1
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "true"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			uniform float _Radius;
			uniform float _Center;
			uniform float _Fade;
			uniform float _FadeSpeed;

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

			float drawCircleAnimated (float2 uv, float2 c, float r){
				float dFromCenterSq = pow(uv.y-c.y, 2) + pow(uv.x-c.x, 2);
				float rSq = pow(r, 2);
				if(dFromCenterSq < rSq){
					float alpha = smoothstep(rSq, rSq-pow(_Fade,2), dFromCenterSq);
					//
					float fadeTime = abs(sin(_Time.w*_FadeSpeed));
					return alpha*fadeTime;
				}
				return 0;
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				half4 texColor = tex2D(_MainTexture, i.texcoord);
				half4 finalColor = _MainColor;
				finalColor.a = drawCircleAnimated(i.texcoord, _Center, _Radius);
				return finalColor;
			}

			ENDCG
		}
	}
}

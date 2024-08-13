// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureCircleBorderFade"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}

		_Center("Center", Float) = 0.5
		_Radius("Radius", Range(0,1)) = 0.3
		_Fade("Fade", Range(0,1)) = 0.1
		_Border("Border", Range(0,0.5)) = 0.1
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
			uniform float _Border;

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

			float drawCircle (float2 uv, float2 c, float r){
				float dFromCenterSq = pow(uv.y-c.y, 2) + pow(uv.x-c.x, 2);
				float rSq = pow(r, 2);
				float borderSq = pow(_Border, 2)/2;
				float maxBorder = rSq+borderSq;
				float minBorder = rSq-borderSq;
				if(	dFromCenterSq < maxBorder &&
					dFromCenterSq > minBorder){
					if(dFromCenterSq > rSq)
						return smoothstep(maxBorder, maxBorder-_Fade, dFromCenterSq);
					else
						return smoothstep(minBorder, minBorder+_Fade, dFromCenterSq);
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
				finalColor.a = drawCircle(i.texcoord, _Center, _Radius);
				return finalColor;
			}

			ENDCG
		}
	}
}

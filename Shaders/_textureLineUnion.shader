// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureLineUnion"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		[Toggle] _Union("Union (true) or Intersection (false) Line", Int) = 1
		_Start("Line Start", Float) = 0.5
		_Width("Line Width", Float) = 0.1
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
			uniform float _Start;
			uniform float _Width;
			uniform int _Union;

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

			float drawLine(float2 uv, float start, float end)
			{
				if(_Union == 1){
					if(	(uv.x > start && uv.x < end) ||
						(uv.y > start && uv.y < end) ){
							return 1;
					}
				}
				else{
					if(	(uv.x > start && uv.x < end) &&
						(uv.y > start && uv.y < end) ){
							return 1;
					}
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
				finalColor.a = drawLine(i.texcoord, _Start, _Start+_Width);
				return finalColor;
			}

			ENDCG
		}
	}
}

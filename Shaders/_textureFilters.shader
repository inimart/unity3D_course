// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureFilters"
{
	Properties
	{
		_Texture ("Texture", 2D) = "white" {}
		_Frequency ("Frequency", Float) = 1
		_Phase ("Phase", Float) = 1
		_Amplitude ("Amplitude", Float) = 1
		[KeywordEnum(0_AGradient, 1_Sin, 2_YSimmetry, 3_FlipY, 4_Pixelate, 5_Scan)] _Fx ("Fx", Float) = 0
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
			
			uniform sampler2D _Texture;
			uniform float4 _Texture_ST;
			uniform float _Frequency;
			uniform float _Phase;
			uniform float _Amplitude;
			uniform float _Fx;

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
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = v.texcoord.xy;
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				float finalAlpha = 1;
				if(_Fx == 0)
					finalAlpha = i.texcoord.x;
				else if(_Fx == 1)
					i.texcoord.x += sin(i.texcoord.y*_Frequency + _Phase) * _Amplitude;
				else if(_Fx == 2){
					if(i.texcoord.x > 0.5)
						i.texcoord.x = 1-i.texcoord.x;
				}
				else if(_Fx == 3)
					i.texcoord.x = 1-i.texcoord.x ;
				else if(_Fx == 4){
					float pixels = _Frequency;
					i.texcoord.xy = round(i.texcoord.xy*pixels) / pixels;
				}
				else if(_Fx == 5){
					float rows = _Frequency;
					float offset = _Amplitude;
					if(fmod(round((i.texcoord.y)*rows+.5),2) == 0)
						offset = -offset;
					i.texcoord.x += offset;
				}
				half4 colorTexture = tex2D(_Texture, i.texcoord);
				//To avoid "one smooth line" artifact between scan lines, either not use MipMaps, or force the sampling of the mipmap 0
				//half4 colorTexture = tex2Dlod(_Texture, float4(i.texcoord.xyz,0));

				half4 finalColor = float4(colorTexture.rgb, finalAlpha);
				return finalColor;
			}

			ENDCG
		}
	}
}

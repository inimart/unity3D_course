// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureFlag"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		//3
		_Frequency ("Frequency", float) = 1
		_Amplitude ("Amplitude", float) = 1
		_Speed ("Speed", float) = 1
		//4
		_StartFrom ("Start from", Range(0,1)) = 0
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
			//3
			uniform float _Amplitude;
			uniform float _Frequency;
			uniform float _Speed;
			//4
			uniform float _StartFrom;

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
			
			//0
			float4 flagMovement(float4 vIn, float2 uv)
			{
				//1
				//vIn.y = vIn.y + sin(uv.x*10);
				//2
				//vIn.y = vIn.y + sin(uv.x-_Time.y);
				//3
				//vIn.y = vIn.y + (sin( (uv.x - (_Time.y*_Speed))*_Frequency))*_Amplitude;
				//3.5
				//vIn.y = vIn.y + (sin( (uv.x - (_Time.y*_Speed))*_Frequency)) * (_Amplitude * uv.x);
				vIn.y = vIn.y + (sin( (uv.x - (_Time.y*_Speed))*_Frequency)) * (_Amplitude * smoothstep(_StartFrom, 1, uv.x));
				//4 - Sum of two sin waves
				float height1 =  (sin( (uv.x - (_Time.y*_Speed))*_Frequency)) * (_Amplitude * smoothstep(_StartFrom, 1, uv.x));
				float height2 =  (sin( (uv.x*2 - (2*_Time.y*_Speed))*_Frequency*2)) * (_Amplitude * smoothstep(_StartFrom, 1, uv.x) * 0.5);
				vIn.y = vIn.y + height1 + height2;

				return vIn;
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				//1
				v.vertex = flagMovement(v.vertex, v.texcoord);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				half4 texColor = tex2D(_MainTexture, i.texcoord);
				half4 finalColor = _MainColor * texColor;
				return finalColor;
			}

			ENDCG
		}
	}
}

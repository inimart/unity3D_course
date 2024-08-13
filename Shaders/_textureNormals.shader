// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureNormals"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		_Frequency ("Frequency", float) = 1
		_Amplitude ("Amplitude", float) = 1
		_Speed ("Speed", float) = 1
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
			uniform float _Amplitude;
			uniform float _Frequency;
			uniform float _Speed;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				//0
				float4 normal : NORMAL;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			float4 normalMovement(float4 vIn, float4 vNormal, float2 uv)
			{
				//1
				//vIn.x += (_Amplitude * vNormal.x);
				//2
				//vIn.y += (_Amplitude * vNormal.y);
				//3
				//vIn.z += (_Amplitude * vNormal.z);
				//4
				//vIn += (_Amplitude * vNormal);
				//5
				//vIn.x += sin(vNormal.x);
				//6
				//vIn.x += sin(vNormal.x - _Time.y);
				//7
				//vIn.x += sin(vNormal.x - _Time.y)*(_Amplitude*vNormal.x);
				//8
				vIn += (sin( (vNormal - (_Time.w*_Speed))*_Frequency )) * (_Amplitude * vNormal);
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
				return finalColor;
			}

			ENDCG
		}
	}
}

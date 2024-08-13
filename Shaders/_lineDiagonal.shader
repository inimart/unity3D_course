// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_lineDiagonal"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_Width("Line Width", Range(0,1)) = 0.02
		_LineType("Line Type", Range(0,10)) = 0
		_val0("val0", Range(0,2)) = 0
		_val1("val1", Range(0,2)) = 0
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform half4 _MainColor;
			uniform float _Width;
			uniform int _LineType;
			uniform float _val0;
			uniform float _val1;

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

			float drawDiagonal(float2 uv, float w)
			{
				return smoothstep(w, 0.0, abs(uv.y-uv.x));
			}
			float drawExp(float2 uv, float w, float v)
			{
				return 	smoothstep(v-w, v, uv.y) - smoothstep(v, v+w, uv.y);
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = v.texcoord.xy;
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				half4 finalColor = _MainColor;
				if(_LineType == 0.0)
					finalColor.a = (drawDiagonal(i.texcoord.xy, _Width));
				else if(_LineType == 1.0)
					finalColor.a = (drawExp(i.texcoord.xy, _Width, pow(i.texcoord.x, _val0)));
				else if(_LineType == 2.0)
					finalColor.a = (drawExp(i.texcoord.xy, _Width, step(_val0, i.texcoord.x)));
				else 
					finalColor.a = (drawExp(i.texcoord.xy, _Width, smoothstep(_val0, _val1, i.texcoord.x)));

				return finalColor;
			}

			ENDCG
		}
	}
}

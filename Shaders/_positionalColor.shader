// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_positionalColor"
{
	Properties
	{
		_LeftColor ("LeftColor", Color) = (1,1,1,1)
		_RightColor ("RightColor", Color) = (1,1,1,1)
	}
	Subshader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			half4 _LeftColor;
			half4 _RightColor;

			struct vertexInput
			{
				float4 vertex: POSITION;
			};

			struct vertexOutput
			{
				float4 pos: SV_POSITION;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			half4 frag(vertexOutput o):SV_Target
			{
				if(o.pos.x < _ScreenParams.x/3.0)
					return half4(_LeftColor.r, _LeftColor.g * (o.pos.y/_ScreenParams.y), _LeftColor.b, 1);
				else if(o.pos.x < (_ScreenParams.x/3)*2)
					return half4(1,o.pos.y/_ScreenParams.y,0.5,1);
				else 
					return half4(_RightColor.r, _RightColor.g * (o.pos.y/_ScreenParams.y), _RightColor.b, 1);
				return _RightColor;
			}

			ENDCG
		}
	}
}

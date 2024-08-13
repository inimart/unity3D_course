// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_positionalColor_obj"
{
	Properties
	{
		_LeftColor ("LeftColor", Color) = (1,1,1,1)
		_RightColor ("RightColor", Color) = (1,1,1,1)
		_minX ("minX", Float) = 0
		_maxX ("maxX", Float) = 0
	}
	Subshader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0

			half4 _LeftColor;
			half4 _RightColor;
			float _minX;
			float _maxX;

			struct vertexInput
			{
				float4 vertex: POSITION;
			};

			struct vertexOutput
			{
				float4 pos: SV_POSITION;
				float4 xRange: DEPTH0;
			};

			vertexOutput vert(vertexInput v, uint vid : SV_VertexID)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.xRange = smoothstep(_minX, _maxX, v.vertex.x);
				return o;
			}

			half4 frag(vertexOutput o):SV_Target
			{
				return o.xRange*_LeftColor + (1-o.xRange)*_RightColor;
			}

			ENDCG
		}
	}
}

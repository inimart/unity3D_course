// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TEST/objPos"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
	}
	Subshader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			half4 _Color;

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
				//UnityObjectToClipPos(*)
				o.pos = v.vertex;
				//o.pos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			half4 frag(vertexOutput o):COLOR
			{
				//return half4(1,0,0,1);
				return _Color;
			}

			ENDCG
		}
	}
}

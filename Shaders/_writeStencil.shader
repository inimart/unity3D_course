// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_writeStencil"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
	}
	Subshader
	{
		//1
		Tags {"Queue"="Geometry-1"}

		//2
		Stencil
		{
			Ref 1
			Comp always
			Pass replace
			//if the StencilTest is not passed, Subshader is not executed
		}

		//3
		ColorMask 0
		//4
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform half4 _Color;

			struct vertexInput
			{
				float4 vertex : POSITION;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			half4 frag(vertexOutput i): COLOR
			{
				return _Color;
			}

			ENDCG
		}
	}
}

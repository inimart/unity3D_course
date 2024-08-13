// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_firstShader"
{
	//1
	Properties
	{
		//Var name ("label", data type) = default value
		_Color ("Main color", Color) = (1,1,1,1)
	}
	//2
	Subshader
	{
		Pass
		{
			CGPROGRAM
			//4
			#pragma vertex vert
			#pragma fragment frag
			//4.5
			#pragma target 3.0
			//6
			uniform half4 _Color;

			//3
			struct vertexInput
			{
				//dataType varName : SemanticLabel
				float4 vertex : POSITION;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
			};

			//5
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
                //o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			half4 frag(vertexOutput i): SV_Target
			{
				//5
				//return half4(1,0,0,1);

				//6
				return _Color;
			}

			ENDCG
		}
	}
}

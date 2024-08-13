// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_firstShaderTags"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
	}
	Subshader
	{
		//1
		//Tags{"Queue" = "Geometry"}
		//2
		Tags{"Queue" = "Geometry" "IgnoreProjector" = "False"}
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0			
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
				//return half4(1,0,0,1);
				return _Color;
			}

			ENDCG
		}
	}
}

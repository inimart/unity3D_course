// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_ZTest"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
	}
	Subshader
	{
		Tags{"Queue" = "Geometry" "RenderType" = "Opaque"}
		Pass
		{
			//ZWrite On | Off //On is default
			//ZTest Less | Greater | LEqual | GEqual | Equal | NotEqual | Always //LEqual is default
			ZTest LEqual
			ZWrite On
			//ColorMask RGBA

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform half4 _MainColor;

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
				return _MainColor;
				//return half4(0,_MainColor.g,_MainColor.b,1);
			}

			ENDCG
		}
	}
}

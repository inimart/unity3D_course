// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_RenderTypeOpaque"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
	}
	Subshader
	{
		Tags{"Queue" = "Geometry" "RenderType" = "Opaque" "CustomTag"="CustomTagValue_1"}
		Pass
		{

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
			}

			ENDCG
		}
	}
}

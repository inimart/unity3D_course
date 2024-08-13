// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_RenderTypeFx"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
	}
	Subshader
	{
		Tags{"Queue" = "Geometry"  "RenderType" = "Opaque" "CustomTag"="CustomTagValue_1"}
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
				float4 finalColor = float4(1,0,0, 1);
				return finalColor;
			}

			ENDCG
		}
	}
	Subshader
	{
		Tags{"Queue" = "Transparent"  "RenderType" = "Transparent" "CustomTag"="CustomTagValue_2"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

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
				float4 finalColor = float4(_MainColor.r * sin(_Time.w), _MainColor.g, _MainColor.b, 0.5);
				return finalColor;
			}

			ENDCG
		}
	}
}

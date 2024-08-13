// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_grabScreen"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "true"}

		//1
		GrabPass { "_BackgroundTexture" }
		//4 - in this way the grabbed texture is provided in _GrabTexture, and is written for each mesh
		//GrabPass {}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			//2
			uniform sampler2D _BackgroundTexture;
			//4
			//sampler2D _GrabTexture;

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

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				//NB: This filp on y coords is not always present. Why?
				//DIRECTX Y coord are inverted or not?
				//i.texcoord.y = 1-i.texcoord.y;
				
				//2
				half4 texColor = tex2D(_BackgroundTexture, i.texcoord);
				//4
				//half4 texColor = tex2D(_GrabTexture, i.texcoord);
				//3 - change output color to see the final fx
				//texColor.rgb = float3(1,1,1)-texColor.rgb;
				half4 finalColor = _MainColor * texColor;
				return finalColor;
			}

			ENDCG
		}
	}
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureFade"
{
	Properties
	{
		_TextureA ("TextureA", 2D) = "white" {}
		_TextureB ("TextureB", 2D) = "white" {}
		_FadeAB ("Fade AB", Range(0,1)) = 0
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "true"}
		
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform sampler2D _TextureA;
			uniform float4 _TextureA_ST;
			uniform sampler2D _TextureB;
			uniform float4 _TextureB_ST;
			uniform float _FadeAB;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoordA : TEXCOORD0;
				float4 texcoordB : TEXCOORD1;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoordA : TEXCOORD0;
				float4 texcoordB : TEXCOORD1;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoordA.xy = (v.texcoordA.xy * _TextureA_ST.xy + _TextureA_ST.zw);
				o.texcoordB.xy = (v.texcoordB.xy * _TextureB_ST.xy + _TextureB_ST.zw);
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				half4 colorTextureA = tex2D(_TextureA, i.texcoordA);
				half4 colorTextureB = tex2D(_TextureB, i.texcoordB);
				half4 finalColor = colorTextureA*(1-_FadeAB) + colorTextureB*(_FadeAB);
				return finalColor;
			}

			ENDCG
		}
	}
}

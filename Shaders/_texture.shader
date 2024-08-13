// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_texture"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		//1
		_MainTexture ("Main texture", 2D) = "white" {}
		//5
		_MipMap ("MipMapIndex", Range(0,5)) = 0

	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "true"}
		Pass
		{
			//0
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform half4 _MainColor;
			//2
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST; //used for Tiling and offset
			//5
			float _MipMap;


			struct vertexInput
			{
				float4 vertex : POSITION;
				//3
				float4 texcoord : TEXCOORD0;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				//3
				float4 texcoord : TEXCOORD0;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//4
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				//4
				//half4 texColor = tex2D(_MainTexture, i.texcoord);
				
				//5
				//i.texcoord.z is used for 3D Textures
				//i.texcoord.w is used for MipmapSelection
				half4 texColor = tex2Dlod(_MainTexture, float4(i.texcoord.xyz,_MipMap));
				
				half4 finalColor = _MainColor * texColor;
				return finalColor;
			}

			ENDCG
		}
	}
}

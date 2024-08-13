// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureTransparent"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		[Header(Blend State)]
		//Doesn't need to make this uniform. We'll use them in Subshader or Pass Shaderlab section
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcCol ("SrcFactorCol", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstCol ("DstFactorCol", Float) = 1
		[Enum(UnityEngine.Rendering.BlendOp)]	_OpCol	("OpCol", Float) = 1
		//[Enum(UnityEngine.Rendering.BlendMode)] _SrcA	("SrcFactorA", Float) = 1
		//[Enum(UnityEngine.Rendering.BlendMode)] _DstA	("DstFactorA", Float) = 1
		//[Enum(UnityEngine.Rendering.BlendOp)]	_OpA	("OpA", Float) = 1
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "true"}
		Pass
		{
			//1 - Additive
			//Blend One One
			//BlendOp Add
			//2 - normal (alpha blending)
			//Blend SrcAlpha OneMinusSrcAlpha
			//3 - multiply
			//Blend DstColor Zero
			Blend [_SrcCol][_DstCol]//,[_SrcA][_DstA]
			BlendOp [_OpCol]//,[_OpA]

			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;

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
				//return half4(1,0,0,1);
				half4 texColor = tex2D(_MainTexture, i.texcoord);
				half4 finalColor = _MainColor * texColor;
				//finalColor.r = 1;
				return finalColor;
			}

			ENDCG
		}
	}
}

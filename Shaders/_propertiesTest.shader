// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_propertiesTest"
{
	Properties{
		_Color("Example Color", Color) = (1,1,1,1)
		_Range("Example Range", Range(0,1)) = 0.5
		_Tex2D("Example Texture2D", 2D) = "white" {}
		_Tex3D("Example Texture3D", 3D) = "white" {}
		_Cube("Example CubeMap", CUBE) = "" {}
		_Float("Example Float", Float) = 0.5
		_Vector("Example Vector", Vector) = (1,2,3,4)
	}

	Subshader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma only_renderers ps4   

			uniform sampler2D _Tex2D;
			uniform sampler3D _Tex3D;
			uniform samplerCUBE _Cube;

			struct vertexInput
			{
			};
			struct vertexOutput
			{
			};

			vertexOutput vert(vertexInput v)
			{
			}

			half4 frag(vertexOutput i): COLOR
			{
			}

			ENDCG
		}
	}

	Subshader
	{
		Pass
		{
		//...
		}
	}

	Fallback "fallbackShader"
}

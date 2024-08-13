
Shader "Custom/_textureFadeH"
{
	Properties
	{
		//0
		_TextureA ("TextureA", 2D) = "white" {}
		_TextureB ("TextureB", 2D) = "white" {}
		_FadeAB ("Fade AB", Range(0,1)) = 0
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent"
        }

		Pass
		{
			ZWrite Off

			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			//BlendOp Add	//1 - Additive
			//Blend One One //1 - Additive
			//Blend SrcAlpha OneMinusSrcAlpha //2 - normal (alpha blending)
			//Blend DstColor Zero //3 - multiply

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			//1
			uniform sampler2D _TextureA;
			uniform float4 _TextureA_ST;
			uniform sampler2D _TextureB;
			uniform float4 _TextureB_ST;
			uniform float _FadeAB;

			struct vertexInput
			{
				float4 vertex : POSITION;
				//2
				float4 texcoordA : TEXCOORD0;
				float4 texcoordB : TEXCOORD1;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				//3
				float4 texcoordA : TEXCOORD0;
				float4 texcoordB : TEXCOORD1;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				//4
				o.texcoordA.xy = (v.texcoordA.xy * _TextureA_ST.xy + _TextureA_ST.zw);
				o.texcoordB.xy = (v.texcoordB.xy * _TextureB_ST.xy + _TextureB_ST.zw);
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				//5
				half4 colorTextureA = tex2D(_TextureA, i.texcoordA);
				half4 colorTextureB = tex2D(_TextureB, i.texcoordB);
				half4 finalColor = colorTextureA*(1-_FadeAB) + colorTextureB*(_FadeAB);
				return finalColor;
			}

			ENDHLSL
		}
	}
}


Shader "Custom/_textureH"
{
	Properties
	{
		//[MainColor] //By default, Unity considers a color with the property name name _Color as the main color
		_Color ("Main color", Color) = (1,1,1,1)
		//1
		//[NoScaleOffset]
		//[Normal]
		//[MainTexture] //By default, Unity considers a texture with the property name _MainTex as the main texture
		_MainTex ("Main texture", 2D) = "white" {}
		//5
		_MipMap ("MipMapIndex", Range(0,5)) = 0
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

			//0
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

			uniform half4 _Color;
			//2
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
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
				//6
				float4 vTexCol : COLOR;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				//4
				//o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				o.texcoord.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
				//6 - Vertex texture sampling
				o.vTexCol = tex2Dlod(_MainTex, float4(o.texcoord.xyz, 0));
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				//4
				//half4 texColor = tex2D(_MainTex, i.texcoord);
				
				//5
				//i.texcoord.z is used for 3D Textures
				//i.texcoord.w is used for MipmapSelection
				half4 texColor = tex2Dlod(_MainTex, float4(i.texcoord.xyz,_MipMap));

				//6 - Vertex texture sampling
				texColor = i.vTexCol;

				//4
				half4 finalColor = _Color * texColor;
				return finalColor;
			}

			ENDHLSL
		}
	}
}


Shader "Custom/_textureRotationH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		_MainTex ("Main texture", 2D) = "white" {}
		//0 Texture rotation
		_AlfaDegrees ("Alpha rot degrees", Range(0,360)) = 0
		_RotCenterX ("Rot center X", Range(0,1)) = 0.5
		_RotCenterY ("Rot center Y", Range(0,1)) = 0.5
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
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			
			//1 Texture rotation
			uniform float _AlfaDegrees;
			uniform float _RotCenterX;
			uniform float _RotCenterY;

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
				o.pos = TransformObjectToHClip(v.vertex);

				//2
				//From degrees to rad
				//radians(x) = x * PI / 180;
				float rad		= radians(_AlfaDegrees);
				//To build rotation matrix, we need cos(alfa) and sin(alfa)
				float cosAlfa = cos(rad);
				float sinAlfa = sin(rad);
				//Build the rotation matrix
				float2x2 rotM = float2x2(cosAlfa, -sinAlfa, sinAlfa, cosAlfa);
				//To rotate (x,y) around (a,b) point, we need to subtract (a,b)
				//	from (x,y), rotate, and then add (a,b) again.
				v.texcoord.xy -= float2(_RotCenterX, _RotCenterY);
				v.texcoord.xy = mul(rotM, v.texcoord.xy);
				v.texcoord.xy += float2(_RotCenterX, _RotCenterY);
				//Finally, we can take into account tiling and scaling				
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				half4 texColor = tex2D(_MainTex, i.texcoord);
				
				half4 finalColor = _Color * texColor;
				return finalColor;
			}

			ENDHLSL
		}
	}
}

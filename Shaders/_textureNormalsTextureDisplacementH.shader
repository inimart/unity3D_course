
Shader "Custom/_textureNormalsTextureDisplacementH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		_MainTex ("Main texture", 2D) = "white" {}
		//0
		_DispColor ("Displacement color", Color) = (1,1,1,1)
		_DispTex ("Displacement texture", 2D) = "white" {}
		_Amplitude ("Amplitude", float) = 1
		_Speed ("Speed", float) = 1
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Opaque"
        }

		Pass
		{
			//0
			ZWrite On

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			//0
			uniform half4 _DispColor;
			uniform sampler2D _DispTex;
			uniform float _Amplitude;
			uniform float _Speed;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normal : NORMAL;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float disp : DEPTH0;
				float4 texcoord : TEXCOORD0;
			};

			float4 normalMovement(float4 vIn, float4 vNormal, float2 uv)
			{
				vIn += (_Amplitude * vNormal);
				return vIn;
			}


			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				float4 wPos = mul(unity_ObjectToWorld, v.vertex);
				//wPos.y changes a lot, we need to divide this value for a factor (here 20)
				half4 dispAmount = tex2Dlod(_DispTex, float4(wPos.x, wPos.y/20.0 + _Time.y * _Speed, 0, 0));
				v.vertex.xyz += _Amplitude * v.normal * dispAmount.r;
				//If you want that the displacement color is always the same 
				//o.disp = dispAmount.r;
				//If you want that the color is more evident if we have more displacement
				o.disp = dispAmount.r * _Amplitude;
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				half4 texColor = tex2D(_MainTex, i.texcoord);
				half4 finalColor = _Color * texColor + i.disp*_DispColor;

				return finalColor;
			}

			ENDHLSL
		}
	}
}

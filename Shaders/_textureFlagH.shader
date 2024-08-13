
Shader "Custom/_textureFlagH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		_MainTex ("Main texture", 2D) = "white" {}
		//3
		_Frequency ("Frequency", float) = 1
		_Amplitude ("Amplitude", float) = 1
		_Speed ("Speed", float) = 1
		//4
		_StartFrom ("Start from", Range(0,1)) = 0
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

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			//3
			uniform float _Amplitude;
			uniform float _Frequency;
			uniform float _Speed;
			//4
			uniform float _StartFrom;

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

			//0
			float4 flagMovement(float4 vIn, float2 uv)
			{
				//1
				//vIn.y = vIn.y + sin(uv.x*10);
				//2
				//vIn.y = vIn.y + sin(uv.x-_Time.y);
				//3
				//vIn.y = vIn.y + (sin( (uv.x - (_Time.y*_Speed))*_Frequency))*_Amplitude;
				//3.5
				//vIn.y = vIn.y + (sin( (uv.x - (_Time.y*_Speed))*_Frequency)) * (_Amplitude * uv.x);
				vIn.y = vIn.y + (sin( (uv.x - (_Time.y*_Speed))*_Frequency)) * (_Amplitude * smoothstep(_StartFrom, 1, uv.x));
				//4 - Sum of two sin waves
				float height1 =  (sin( (uv.x - (_Time.y*_Speed))*_Frequency)) * (_Amplitude * smoothstep(_StartFrom, 1, uv.x));
				float height2 =  (sin( (uv.x*2 - (2*_Time.y*_Speed))*_Frequency*2)) * (_Amplitude * smoothstep(_StartFrom, 1, uv.x) * 0.5);
				vIn.y = vIn.y + height1 + height2;

				//New - Using Clamp instead of smoothstep, for a linear decrease:
				//vIn.y = vIn.y + (sin( (uv.x - (_Time.y*_Speed))*_Frequency)) * (_Amplitude * clamp((uv.x-_StartFrom)/(1-_StartFrom), 0, 1));
				//If you want also to simulate No wind condition (add _HeightOffset, _LengthOffset):
				//vIn.z = vIn.z + smoothstep(_StartFrom, 1, uv.x) * _HeightOffset;
				//vIn.x = vIn.x + smoothstep(_StartFrom, 1, uv.x) * _LengthOffset;


				return vIn;
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				//1
				//v.vertex is in obj Space
				v.vertex = flagMovement(v.vertex, v.texcoord);
				o.pos = TransformObjectToHClip(v.vertex);
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

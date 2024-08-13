Shader "Custom/_heatDistortion"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)

		//3
		_Distortion("Distort", float) = 1.0
        _Speed("Speed", Float) = 1 
		_NoiseTex("Noise", 2D) = "white" {}

		//4
		_NoiseMask("NoiseMask", 2D) = "white" {}
	}
	Subshader
	{
		//1 Ensure it is rendered after the opaque objects
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType" = "Transparent"}
		//2
		GrabPass {"_BackgroundTexture"}

		Pass
		{
			//0 - Only if you need to render the effect on top of everything
			//ZTest Always

			//1
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"

			uniform half4 _Color;
			//2
			uniform sampler2D _BackgroundTexture;
			//3
			uniform float _Distortion;
			uniform float _Speed;
			uniform sampler2D _NoiseTex;
			//4
			uniform sampler2D _NoiseMask;

			struct vertexInput
			{
				float4 vertex : POSITION;
				//2 TEXCOORD2 because we'll need 2 texture before
				float4 grabPos: TEXCOORD2;
				//3 noise texture
                float4 noiseTexcoord : TEXCOORD0;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				//2
				float4 grabPos: TEXCOORD2;
				//3
                float4 noiseTexcoord : TEXCOORD0;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//2
				o.grabPos = ComputeGrabScreenPos(o.pos);

				//3
				float noise = tex2Dlod(_NoiseTex, float4(v.noiseTexcoord.xy, 0, 0)).r;
				float noiseMask = tex2Dlod(_NoiseMask, float4(v.noiseTexcoord.xy, 0, 0)).r;
				o.grabPos.x += cos(noise * _Time.x * _Speed) * _Distortion * noiseMask;
				o.grabPos.y += sin(noise * _Time.x * _Speed) * _Distortion * noiseMask;

				return o;
			}
			half4 frag(vertexOutput i): SV_Target
			{
				//2
				float4 grabColor = tex2Dproj(_BackgroundTexture, i.grabPos); 
				return float4(grabColor.rgb, _Color.a);
			}

			ENDCG
		}
	}
}

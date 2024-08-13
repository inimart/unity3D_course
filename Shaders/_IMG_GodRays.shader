// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/IMG_Godrays" {
	Properties {
		[NoScaleOffset] _MainTex ("Base (RGB)", 2D) = "white" {}
		_Intensity ("_Intensity", Float) = 1
		_Gamma ("_Gamma", Float) = 2
		_BlurStart ("_BlurStart", Float) = 0
		_BlurWidth ("_BlurWidth", Float) = 0.5
		_CenterX ("_CenterX", Float) = .5
		_CenterY ("_CenterY", Float) = .5
	}

	SubShader {
		Pass {
			Tags { "LightMode" = "Always" }
			ZTest Always Cull Off ZWrite Off Fog { Mode off }

			CGPROGRAM
			#pragma vertex vert_img
            #pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float _Intensity;
			uniform float _Gamma;
			uniform float _BlurStart;
			uniform float _BlurWidth;
			uniform float _CenterX, _CenterY;

			// v2f_img vert(appdata_img v) {
			// 	v2f_img o;
			// 	o.pos = UnityObjectToClipPos(v.vertex);
			// 	#ifdef UNITY_HALF_TEXEL_OFFSET
			// 		v.texcoord.y += _MainTex_TexelSize.y;
			// 	#endif
			// 	#if SHADER_API_D3D9
			// 		if (_MainTex_TexelSize.y < 0)
			// 			v.texcoord.y = 1.0 - v.texcoord.y;
			// 	#endif
			// 	o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.texcoord);
			// 	return o;
			// }

			fixed4 frag (v2f_img i) : COLOR {
				half4 blurred = 0;
				half2 center = float2(_CenterX, _CenterY);
				i.uv -= center;
				for(int j = 0; j < 32; j++) {
					float scale = _BlurStart + _BlurWidth * ((float)j / 31);
					blurred += tex2D(_MainTex, i.uv * scale + center);
				}
				blurred /= 32;
				blurred.rgb = pow(blurred.rgb, _Gamma);
				blurred.rgb *= _Intensity;
				blurred.rgb = saturate(blurred.rgb);
				fixed4 screen = tex2D(_MainTex, i.uv + center);
				half3 col = screen.rgb + (blurred.a) * blurred.rgb;
				half alpha = max(screen.a, blurred.a);
				return half4(col, alpha);
			}
			ENDCG
		}
	}

	Fallback off
}
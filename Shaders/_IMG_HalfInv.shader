Shader "Custom/ImageFx/HalfInv" {
	Properties {
		//0
		//NB: _MainTex must have this variable name. _MainTexture wont work!
		//	_MainTex_ST is not provided. We can use the attribute [NoScaleOffset] to not display offset tiling in the material inspector 
		[NoScaleOffset] _MainTex ("Base (RGB)", 2D) = "white" {}
		_Treshold ("Treshold", Range(0,1)) = 0.5
	}
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"
		
			//0 NB: _MainTex must have this variable name. _MainTexture wont work!
			uniform sampler2D _MainTex;
			uniform float _Treshold;
			
			fixed4 frag (v2f_img i) : COLOR
			{
				fixed4 base = tex2D(_MainTex, i.uv);
				if(i.uv.x > _Treshold)
					return fixed4(base.r, base.g, base.b, base.a);
				else
					return fixed4(1-base.r, 1-base.g, 1-base.b, base.a);
			}
			ENDCG
		}
	}
}
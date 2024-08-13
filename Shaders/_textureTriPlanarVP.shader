Shader "Custom/_textureTriPlanarVP" 
{
	Properties 
	{
		_TexturePlaneX ("TexturePlaneX", 2D)  = "white" {}
		_TexturePlaneY ("TexturePlaneY", 2D)  = "white" {}
		_TexturePlaneZ ("TexturePlaneZ", 2D)  = "white" {}
		_TintX ("TintX", Color) = (1,1,1,1)
		_TintY ("TintY", Color) = (1,1,1,1)
		_TintZ ("TintZ", Color) = (1,1,1,1)
		_ScaleX ("ScaleX",float) = 1
		_ScaleY ("ScaleY",float) = 1
		_ScaleZ ("ScaleZ",float) = 1
		_TriplanarBlendSharpness ("Blend Sharpness",float) = 1
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform sampler2D _TexturePlaneX;
			uniform sampler2D _TexturePlaneY;
			uniform sampler2D _TexturePlaneZ;
			uniform half4 _TintX;
			uniform half4 _TintY;
			uniform half4 _TintZ;
			uniform float _ScaleX;
			uniform float _ScaleY;
			uniform float _ScaleZ;
			uniform float _TriplanarBlendSharpness;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				//1
				float4 normal : NORMAL;
				float4 tangent : TANGENT;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;

				float4 worldPos : TEXCOORD0;
				float4 normalWorld : TEXCOORD1;
			}; 

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos =  mul(unity_ObjectToWorld, v.vertex);
				o.normalWorld = float4(UnityObjectToWorldNormal(v.normal),v.normal.w);

				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				half4 finalColor;
				// Find our UVs for each axis based on world position of the fragment.
				half2 yUV = i.worldPos.xz / _ScaleX;
				half2 xUV = i.worldPos.zy / _ScaleY;
				half2 zUV = i.worldPos.xy / _ScaleZ;
				// Now do texture samples from our diffuse map with each of the 3 UV set's we've just made.
				half3 yDiff = tex2D (_TexturePlaneY, yUV);
				half3 xDiff = tex2D (_TexturePlaneX, xUV);
				half3 zDiff = tex2D (_TexturePlaneZ, zUV);
				// Get the absolute value of the world normal.
				// Put the blend weights to the power of BlendSharpness, the higher the value, 
				// the sharper the transition between the planar maps will be.
				half3 blendWeights = pow (abs(i.normalWorld), _TriplanarBlendSharpness);
				// Divide our blend mask by the sum of it's components, this will make x+y+z=1
				// NB: We don't want a normalization (magnitude == 1), we want a SUM of 1!
				blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);
				// Finally, blend together all three samples based on the blend mask.
				finalColor = float4((_TintX * xDiff * blendWeights.x) + (_TintY * yDiff * blendWeights.y) + (_TintZ * zDiff * blendWeights.z),1);
				//finalColor = i.normalWorld;
				return finalColor;
			}
			ENDCG
		}
	}
}
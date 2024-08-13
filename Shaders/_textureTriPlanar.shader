Shader "Custom/_textureTriPlanar" 
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
		LOD 200

		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Lambert

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

		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
		}; 

		void surf (Input IN, inout SurfaceOutput o) 
		{
			// Find our UVs for each axis based on world position of the fragment.
			half2 yUV = IN.worldPos.xz / _ScaleX;
			half2 xUV = IN.worldPos.zy / _ScaleY;
			half2 zUV = IN.worldPos.xy / _ScaleZ;
			// Now do texture samples from our diffuse map with each of the 3 UV set's we've just made.
			half3 yDiff = tex2D (_TexturePlaneX, yUV);
			half3 xDiff = tex2D (_TexturePlaneY, xUV);
			half3 zDiff = tex2D (_TexturePlaneZ, zUV);
			// Get the absolute value of the world normal.
			// Put the blend weights to the power of BlendSharpness, the higher the value, 
            // the sharper the transition between the planar maps will be.
			half3 blendWeights = pow (abs(IN.worldNormal), _TriplanarBlendSharpness);
			// Divide our blend mask by the sum of it's components, this will make x+y+z=1
			blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);
			// Finally, blend together all three samples based on the blend mask.
			o.Albedo = (_TintY * yDiff * blendWeights.x) + (_TintY * yDiff * blendWeights.y) + (_TintZ * zDiff * blendWeights.z);
		}
		ENDCG
	}
}
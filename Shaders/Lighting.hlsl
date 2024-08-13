#ifndef LIGHTING
#define LIGHTING
float3 normalFromColor(float4 color)
{
    #if defined(UNITY_NO_DXT5nm)
        return color.xyz * 2 - 1;
    #else
        float3 normalDecompressed;
        normalDecompressed = float3 (	color.a * 2 - 1,
                                        color.g * 2 - 1,
                                        0.0);
        normalDecompressed.z = sqrt(1 - dot(normalDecompressed.xy, normalDecompressed.xy));
        return normalDecompressed;
    #endif
}

//0 Diffuse
float3 DiffuseLambert(float3 normalVal, float3 lightDir, float3 lightColor, float diffuseFactor, float attenuation)
{
    return lightColor * diffuseFactor * attenuation * max(0, dot(normalVal,lightDir));
}

//1 Specular
float3 SpecularBlinnPhong(float3 N, float3 L, float3 V, float3 specularColor, float specularFactor, float attenuation, float specularPower)
{
	//specularColor is readed from SpecularMap
	//specularFactor & specularPower are material properties
	//V is View in world space
	float3 H = normalize(L+V);
	return specularColor * specularFactor * attenuation * pow(max(0, dot(N,H)), specularPower);
}
#endif

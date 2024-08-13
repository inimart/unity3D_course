
Shader "Custom/_lightingGlassH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		_MainTex ("Main texture", 2D) = "white" {}
		[Header(Normal)]
		//0
		[Normal]
		_NormalMap ("Normal Map", 2D) = "white" {}
		//0 - Remove Use Normalmap - we need to use it!
		[Header(Diffuse)]
		_Diffuse ("Diffuse", Range(0,3)) = 1
		//0 - Remove Lighting mode - only fragment!
		[Header(Specular)]
		_SpecularMap ("Specular Map", 2D) = "black" {}
		_SpecularFactor ("Specular Factor", Range(0,1)) = 1
		_SpecularPower ("Specular Power", Float) = 100
		[Header(Ambient)]
		//0 - Remove ambient
		_AmbientFactor ("Ambient Factor", Range(0,1)) = 1
		//0
		_Distortion ("Distortion", Range(0,1)) = 0.5
	}

	Subshader
	{
        Tags 
        { 
        	//1 - Now we are transparent: we don't want a loop of opaque objects inside _CameraOpaqueTexture
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent"
        }

		Pass
		{
			Tags{"LightMode" = "UniversalForward"}

			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Lighting.hlsl" 
			//0 Diffuse
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			uniform float _Diffuse;
			uniform sampler2D _SpecularMap;
			uniform float _SpecularFactor;
			uniform float _SpecularPower;
			uniform float _AmbientFactor;

			//1
			uniform float _Distortion;
			uniform sampler2D _CameraOpaqueTexture; //This is activated in Camera/Rendering/OpaqueTexture: On in the inspector

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normal : NORMAL;
				float4 tangent : TANGENT;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normalWorld : TEXCOORD1;
				float4 tangentWorld : TEXCOORD2;
				float3 binormalWorld : TEXCOORD3;
				float4 normalTexCoord: TEXCOORD4;
				float4 posWorld : TEXCOORD5;
				float3 ambientColor : COLOR1;
				//2
				float4 texcoordGrab	: TEXCOORD6;				
				
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				//3
				//ComputeScreenPos() will not divide input's xy by w because this method expect you sample the texture in fragment shader using tex2Dproj(float4)
				o.texcoordGrab = ComputeScreenPos(o.pos);

				o.normalWorld	= float4(TransformObjectToWorldNormal(v.normal.xyz), v.normal.w);
				o.tangentWorld = float4(normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz)),v.tangent.w);
				o.binormalWorld	= float3(normalize(cross(o.normalWorld.xyz,  o.tangentWorld.xyz) * v.tangent.w));
				o.binormalWorld *=	unity_WorldTransformParams.w;
				o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);

				half3 ambientColor = _AmbientFactor * half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.ambientColor = ambientColor;

				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				half4 finalColor;
				float3 normalWorldAtPixel;
				
				half4 normalColor = tex2D(_NormalMap, i.normalTexCoord);
				float3 TSNormal = normalFromColor(normalColor);
				float3x3 TBNWorld = float3x3 (i.tangentWorld.xyz, i.binormalWorld.xyz, i.normalWorld.xyz);
				normalWorldAtPixel = normalize(mul(TSNormal, TBNWorld));

				//4
				//We can’t use WorldSpaceNormals, because they change according to glass orientation!
				//We need a Normal in a Space that remains the same independently from glass orientation. What about TangentSpaceNormal?
				float2 distortion = TSNormal.rg * _Distortion;
				i.texcoordGrab.xy += distortion;

				half4 albedoColor;
				half3 specularColor, diffuseColor, ambientColor;
				specularColor = diffuseColor = ambientColor = half3(0,0,0);
				albedoColor = half4(1,1,1,1);

				Light light = GetMainLight();
				float3 lightDir = normalize(light.direction.xyz);
				float3 lightColor = light.color;
				float attenuation = 1;
				
				diffuseColor = DiffuseLambert(	normalWorldAtPixel,
														lightDir,
														lightColor,
														_Diffuse,
														attenuation);

				albedoColor = tex2D(_MainTex, i.texcoord);

				//5
				//ComputeScreenPos() in vert shader will just transform input from clip coordinate vertex position [-w,w] into [0,w]
				//tex2DProj() will transform [0,w] into [0,1], which is a valid texture sampling value
				half4 grabColor = tex2Dproj(_CameraOpaqueTexture, i.texcoordGrab);
				albedoColor *= grabColor;

				float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
				float3 specularMapColor = tex2Dlod(_SpecularMap, float4(i.texcoord.xy, 0, 0));
				specularColor = SpecularBlinnPhong(	normalWorldAtPixel,
															lightDir,
															V,
															specularMapColor.xyz,
															_SpecularFactor,
															attenuation,
															_SpecularPower);

				ambientColor = i.ambientColor;
				finalColor = float4(diffuseColor * albedoColor.rgb * _Color.rgb + specularColor + ambientColor, albedoColor.a * _Color.a);

				return finalColor;
			}

			ENDHLSL
		}
	}
}

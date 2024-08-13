// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/depthCam"
{
    Properties
    {
        _MainTex("Main Color", 2D) = "white" {}
		[KeywordEnum(RawImg, CamDepth, CamDepthNormals, CamMotionVectors)] _RenderOutput("RenderOutput", Float) = 0

	}
    SubShader
    {
        Tags { "RenderType"="Opaque" }
 
        Pass
        {
 
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature _RENDEROUTPUT_RAWIMG _RENDEROUTPUT_CAMDEPTH _RENDEROUTPUT_CAMDEPTHNORMALS _RENDEROUTPUT_CAMMOTIONVECTORS
            #include "UnityCG.cginc"
			
            uniform sampler2D _CameraDepthTexture; //the depth texture
            uniform sampler2D _CameraDepthNormalsTexture ; //the depth-normals texture
            uniform sampler2D _CameraMotionVectorsTexture ; //the depth texture
            uniform sampler2D _MainTex; //the depth texture
 
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 texcoord : TEXCOORD0;
            };
 
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
 
                return o;
            }
 
            fixed4 frag(v2f i) : SV_Target
            {
				half4 finalColor;
				#if _RENDEROUTPUT_RAWIMG
				finalColor = tex2D(_MainTex, i.texcoord);
				#endif

				#if _RENDEROUTPUT_CAMDEPTH
                //Grab the depth value from the depth texture
                //-Linear01Depth restricts this value to [0, 1]
				float depth = Linear01Depth (tex2D(_CameraDepthTexture, i.texcoord).r);
				finalColor = float4(depth.rrr, 1);
				#endif

				#if _RENDEROUTPUT_CAMMOTIONVECTORS
				//MotionVectors
                //-saturate clamps the result to [0,1] range
                finalColor = abs(tex2D(_CameraMotionVectorsTexture, i.texcoord));
				finalColor = float4(saturate(finalColor.rgb*50),1);
                #endif

				#if _RENDEROUTPUT_CAMDEPTHNORMALS
				//DepthNormals
				float depthValue;
				float3 normalValues;
                //-DecodeDepthNormal takes 8 bit per channel RGBA texture and extracts
                //  the 16 bit float depth and view space normal (with a reconstructed Z)
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.texcoord), depthValue, normalValues);
                //If we want to isolate the normal from the depth-normals
                finalColor.rgb = normalValues.rgb;
                //If we want to isolate the depth from the depth-normals
				//finalColor.rgb = depthValue.rrr;
				#endif

				return finalColor;
            }
 
            ENDCG
        }
    }
}
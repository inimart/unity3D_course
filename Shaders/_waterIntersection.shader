Shader "Custom/_waterIntersection"
{
    Properties
    {
        _RegularColor("Main Color", Color) = (1, 1, 1, .5) //Color when not intersecting
        _HighlightColor("Highlight Color", Color) = (1, 1, 1, .5) //Color when intersecting
        _HighlightThresholdMax("Highlight Threshold Max", Float) = 1 //Max difference for intersections
        //1
        _FoamRamp("Foam Ramp", 2D) = "white" {}
		[KeywordEnum(Single, Multi)] _FoamMode("Foam Mode", Float) = 0
		[KeywordEnum(Linear, Treshold, Ramp)] _FoamGradient("Foam gradient", Float) = 0
        //2
        _Speed("Speed", Float) = 1 
        _Amplitude("Amplitude", Float) = 1 
        _NoiseTex("Noise", 2D) = "white" {}

        //3
        _Near("Near", Float) = 0 
        _FoamWidth("Foam width", Float) = 0 
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent"  }
        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            //1
            #pragma shader_feature _FOAMMODE_SINGLE _FOAMMODE_MULTI
            #pragma shader_feature _FOAMGRADIENT_LINEAR _FOAMGRADIENT_TRESHOLD _FOAMGRADIENT_RAMP

            uniform sampler2D _CameraDepthTexture; //Depth Texture
            uniform float4 _RegularColor;
            uniform float4 _HighlightColor;
            uniform float _HighlightThresholdMax;

            //1
            uniform sampler2D _FoamRamp;
            
            //2
            uniform float _Speed;
            uniform float _Amplitude;
            uniform sampler2D _NoiseTex;

            uniform float _Near;
            uniform float _FoamWidth;

            //0 We need this structure instead of app_data
            struct vIn
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 noiseTexcoord : TEXCOORD1;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                
                //1 Since TEXCOORD0 is for _FoamRamp and we'll need also a Noise texture, use TEXCOORD2 for this
                float4 projPos : TEXCOORD2; //Screen position of pos
                //2
                float4 noiseTexcoord : TEXCOORD1; //TEXCOORD0 is for _FoamRamp, but we don't use texcoord because we'll use diff,0.5 as u,v coords in fragment
            };
            
            //0
            //appdata_base -> vIn
            v2f vert(vIn v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //2
                float noiseColor = tex2Dlod(_NoiseTex, float4(v.noiseTexcoord.xy, 0, 0));
                o.pos.y += sin(_Time * _Speed * noiseColor) * _Amplitude;
                o.pos.x += cos(_Time * _Speed * noiseColor)* _Amplitude;

                o.projPos = ComputeScreenPos(o.pos);

                return o;
            }
            
            half4 frag(v2f i) : COLOR
            {
                float4 finalColor = _RegularColor;
                
                float dFromCam = i.projPos.w;
                float4 currprojPos = i.projPos;
                float sceneZ = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, currprojPos)).r;
                float diff;

                #if _FOAMMODE_SINGLE
                    diff = saturate((abs(dFromCam - sceneZ)) / _HighlightThresholdMax);
                #elif _FOAMMODE_MULTI
                
                    currprojPos.xy = i.projPos.xy+float2(0,_Near);
                    float sceneZT = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, currprojPos)).r;
                    currprojPos.xy = i.projPos.xy-float2(0,_Near);
                    float sceneZB = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, currprojPos)).r;
                    currprojPos.xy = i.projPos.xy-float2(_Near,0);
                    float sceneZL = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, currprojPos)).r;
                    currprojPos.xy = i.projPos.xy+float2(_Near,0);
                    float sceneZR = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, currprojPos)).r;
                    float minZ = min(sceneZR, min(sceneZL, min(sceneZB, min(sceneZ, sceneZT))));
                    //float minZ = (sceneZR + sceneZL + sceneZB + sceneZ + sceneZT) / 5.0;
                    diff = saturate((abs(dFromCam - minZ)) / _HighlightThresholdMax);
                #endif

                #if _FOAMGRADIENT_TRESHOLD 
                    diff = diff > (_FoamWidth) ? 1 : 0;
                #endif
                
                finalColor = lerp(_HighlightColor, _RegularColor, diff);

                #if _FOAMGRADIENT_RAMP 
                    float4 rampColor = float4(tex2D(_FoamRamp, float2(1-diff, 0.5)).rgb, 1.0);
                    finalColor = rampColor;
                #endif

                return finalColor;
            }
            
            ENDCG
        }
        
    }
    FallBack "Diffuse"
}
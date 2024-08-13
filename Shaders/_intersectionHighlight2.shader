//NB: Works in Playmode
Shader "Custom/_intersectionHighlight2"
{
    Properties
    {
        //1
        _RegularColor("Main Color", Color) = (1, 1, 1, .5) //Color when not intersecting
        _HighlightColor("Highlight Color", Color) = (1, 1, 1, .5) //Color when intersecting
        _HighlightThresholdMax("Highlight Threshold Max", Float) = 1 //Max difference for intersections
    }
    SubShader
    {
        //0
        Tags { "Queue" = "Transparent" "RenderType"="Transparent"  }
 
        Pass
        {
            //0
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull front
 
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            //1.5
            //-remove sampler unifrom but not _CameraDepthTexture
            uniform sampler2D _CameraDepthTexture; //Depth Texture

            //1
            uniform float4 _RegularColor;
            uniform float4 _HighlightColor;
            uniform float _HighlightThresholdMax;
 
            struct v2f
            {
                float4 pos : SV_POSITION;

                //2
                //Remove original texture: we wont use albedo
                float4 projPos : TEXCOORD1; //Screen position of pos
            };
 
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //2
                //Remove texcoord albedo calculations
                o.projPos = ComputeScreenPos(o.pos);

                return o;
            }
 
            half4 frag(v2f i) : COLOR
            {
                float4 finalColor = _RegularColor;
                
                //3
                //Get the depth from the camera sampling from the depth buffer for this point
                // depth is not stored linear mode (more precision is for nearest objects)
                //float sceneZ = LinearEyeDepth (tex2Dproj(_CameraDepthTexture,
                //                                         UNITY_PROJ_COORD(i.projPos)).r);
                float sceneZ = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, i.projPos)).r;
 
                //4
				//Actual distance to the camera. i.projPos.w is the depth in view space
                float dFromCam = i.projPos.w;

                //5 -->
                //If the two are similar, then there is an object intersecting with our object
                //diff will be [0,1] if abs(dFromCam - sceneZ) is <= _HighlightThresholdMax
				float diff = saturate((abs(dFromCam - sceneZ)) / _HighlightThresholdMax);
                finalColor = lerp(_HighlightColor, _RegularColor, diff);

                return finalColor;
            }
 
            ENDCG
        }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back
 
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            uniform sampler2D _CameraDepthTexture; //Depth Texture
            uniform float4 _RegularColor;
            uniform float4 _HighlightColor;
            uniform float _HighlightThresholdMax;
 
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 projPos : TEXCOORD1; //Screen position of pos
            };
 
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.projPos = ComputeScreenPos(o.pos);

                return o;
            }
 
            half4 frag(v2f i) : COLOR
            {
                float4 finalColor = _RegularColor;
                float sceneZ = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, i.projPos)).r;
                float dFromCam = i.projPos.w;
				float diff = saturate((abs(dFromCam - sceneZ)) / _HighlightThresholdMax);
                finalColor = lerp(_HighlightColor, _RegularColor, diff);

                return finalColor;
            }
 
            ENDCG
        }
    }
    FallBack "Diffuse"
}
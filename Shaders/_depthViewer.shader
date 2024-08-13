//NB: Works in Playmode
Shader "Custom/_depthViewer"
{
    Properties
    {
		[KeywordEnum(CamDepthTextureRaw, Linear01, EyeLinear, ScreenPos_w)] _DepthSource ("DepthSource", Float) = 0
        _DebugDiv("DebugDiv", Range(0,500)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            uniform sampler2D _CameraDepthTexture; //Depth Texture
            uniform float _DebugDiv;
            uniform float _DepthSource;
 
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
                float4 finalColor;
                float CamDepthTextureRawVal = tex2Dproj(_CameraDepthTexture, i.projPos).r;
                float Linear01Val = Linear01Depth(CamDepthTextureRawVal);
                float EyeLinearVal = LinearEyeDepth(CamDepthTextureRawVal);
                float4 ScreenPos_wVal = i.projPos.w;

                if(_DepthSource == 0)
                    finalColor = float4(CamDepthTextureRawVal.rrr/_DebugDiv,1); //_DebugDiv = .01
                else if(_DepthSource == 1)
                    finalColor = float4(Linear01Val.rrr/_DebugDiv,1);           //_DebugDiv = 1
                else if(_DepthSource == 2)
                    finalColor = float4(EyeLinearVal.rrr/_DebugDiv,1);          //_DebugDiv = far
                else if(_DepthSource == 3)
                    //Actual distance to the camera. i.projPos.w is the depth in view space,
                    //  the same value of EyeLinearVal
                    finalColor = float4(ScreenPos_wVal.rrr/_DebugDiv,1);        //_DebugDiv = far
                
                return finalColor;
            }
 
            ENDCG
        }
    }
    FallBack "VertexLit"
}
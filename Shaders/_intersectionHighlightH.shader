//NB: Works in Playmode
Shader "Custom/_intersectionHighlightH"
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
        Tags 
        {  "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent" }
 
        //0 - Blending and ZWrite is the same for every pass: we move these lines in SubShader scope
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        //Everything in the shader is the same code for every pass, the only difference is cull back/front
        HLSLINCLUDE
        #pragma target 3.0
        #pragma vertex vert
        #pragma fragment frag

        #include "HLSLSupport.cginc" 
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        //0.5
        uniform sampler2D _CameraDepthTexture; //Depth Texture

        //1
        uniform float4 _RegularColor;
        uniform float4 _HighlightColor;
        uniform float _HighlightThresholdMax;

        struct vertexInput
		{
			float4 vertex : POSITION;
		};
        struct v2f
        {
            float4 pos : SV_POSITION;

            //2
            //Remove original texture: we wont use albedo
            float4 projPos : TEXCOORD0; //Screen position of pos
        };

        v2f vert(vertexInput v)
        {
            v2f o;
            o.pos = TransformObjectToHClip(v.vertex);
            //2
            //Remove texcoord albedo calculations
            o.projPos = ComputeScreenPos(o.pos);

            return o;
        }

        half4 frag(v2f i) : SV_Target
        {
            float4 finalColor;
            
            //3
            //Get the depth from the camera sampling from the depth buffer for this point
            // depth is not stored linear mode (more precision is for nearest objects)
            //_ZBufferParams is needed when we use LinearEyeDepth in URP:
            //  Used to linearize Z buffer values. x is (1-far/near), y is (far/near), z is (x/far) and w is (y/far).
            float sceneZ = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, i.projPos).r, _ZBufferParams);

            //4
			//Actual distance to the camera. i.projPos.w is the depth in view space
            float dFromCam = i.projPos.w;

            //5
            //If the two values are similar, then there is an object intersecting with our object
            //- diff will be [0,1] if abs(dFromCam - sceneZ) is <= _HighlightThresholdMax
            //- saturate() Clamps the result of a single or double precision floating point arithmetic operation to [0,1] range
			float diff = saturate(abs(dFromCam - sceneZ) / _HighlightThresholdMax);
            finalColor = lerp(_HighlightColor, _RegularColor, diff);

            return finalColor;
        }
        ENDHLSL
        
        Pass
        {
            Cull front
            
            //We still need the code snippet HLSLPROGRAM/ENDHLSL
            HLSLPROGRAM
            //inside here there will be HLSLINCLUDE content
            ENDHLSL
        }
        
        Pass
        {
            Cull Back
 
            //We still need the code snippet HLSLPROGRAM/ENDHLSL
            HLSLPROGRAM
            //inside here there will be HLSLINCLUDE content
            ENDHLSL
        }
    }

    //Fallback "Diffuse" doesn't exist in URP, so it will result in an error
    FallBack "Lit"
}
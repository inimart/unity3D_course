
Shader "Custom/_textureOutlineH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		_MainTex ("Main texture", 2D) = "white" {}
		//1
		_OutlineColor ("Outline color", Color) = (1,1,1,1)
		_OutlineBorder ("Outline border", Range(0,1)) = 0.1
		_OutlineColor2 ("Outline color 2", Color) = (1,1,1,1)
		_OutlineBorder2 ("Outline border 2", Range(0,1)) = 0.1
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Opaque"
        }
		
		//0 This code is equal for every pass: HLSLINCLUDE block allows us to not include the code every time  
		HLSLINCLUDE
            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			//1
			uniform half4 _OutlineColor;
			uniform float _OutlineBorder;
			uniform half4 _OutlineColor2;
			uniform float _OutlineBorder2;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texcoord : TEXCOORD0;
			};
		ENDHLSL
		
		//Draw the first outline
		Pass
		{
			//4
			ZWrite Off
			Cull Front

			HLSLPROGRAM
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;

				//2
				float4x4 scaleM = float4x4(	1.0+_OutlineBorder, 0,0,0,
											0, 1.0+_OutlineBorder,0,0,
											0,0, 1.0+_OutlineBorder,0,
											0,0,0,1.0);
				float4 scaledObjPos = mul(scaleM, v.vertex);
				o.pos = TransformObjectToHClip(scaledObjPos);

				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				//3
				return _OutlineColor;
			}

			ENDHLSL
		}
		
		//Draw the second outline
		Pass
		{
			ZWrite Off
			Cull Front

			HLSLPROGRAM
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;

				float4x4 scaleM = float4x4(	1.0+_OutlineBorder2, 0,0,0,
											0, 1.0+_OutlineBorder2,0,0,
											0,0, 1.0+_OutlineBorder2,0,
											0,0,0,1.0);
				float4 scaledObjPos = mul(scaleM, v.vertex);
				o.pos = TransformObjectToHClip(scaledObjPos);

				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				return _OutlineColor2;
			}

			ENDHLSL
		}
		
		//Draw the objects: this last pass is the _textureStart.shader
		Pass
		{
			//0 Check that there is no ZWrite Off, no Cull
			 
			HLSLPROGRAM
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);

				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				half4 texColor = tex2D(_MainTex, i.texcoord);
				
				half4 finalColor = _Color * texColor;
				return finalColor;
			}

			ENDHLSL
		}
	}
}

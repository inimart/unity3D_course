
Shader "Custom/_textureLineCircleH"
{
	Properties
	{
		_Color ("Main color", Color) = (1,1,1,1)
		[KeywordEnum(0_Line, 1_LinePattern, 2_Circle, 3_CircleFade, 4_CircleBorderFade, 5_Diagonal)] _Fx ("Fx", Float) = 0
		//0_Line
		[Header(Line)]
		[Toggle] _HLine("Horizontal Line", Int) = 1
		_Start("Line Start", Float) = 0.5
		_Width("Line Width", Float) = 0.1
		//1_LinePattern
		[Header(LinePattern)]
		_PatternStripes("Pattern stripes", Range(2,20)) = 1
		//2_Circle
		[Header(Circle)]
		_Center("Center", Float) = 0.5
		_Radius("Radius", Float) = 0.3
		//3_CircleFade
		[Header(CircleFade)]
		_Fade("Fade", Float) = 0.1
		//4_CircleFade
		[Header(CircleBorderFade)]
		_Border("Border", Range(0,0.5)) = 0.1
		//5_Diagonal
		[Header(Diagonal)]
		[IntRange] _LineType("Line Type", Range(0,3)) = 0
		_val0("val0", Range(0,2)) = 0
		_val1("val1", Range(0,2)) = 0
	}

	Subshader
	{
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" "Queue" = "Transparent"
        }

		Pass
		{
			ZWrite Off

			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST; //used for Tiling and offset
			uniform float _Fx;

			//0_Line
			uniform int _HLine;
			uniform float _Start;
			uniform float _Width;
			//1_LinePattern
			uniform float _PatternStripes;
			//2_Circle
			uniform float _Radius;
			uniform float _Center;
			//3_CircleFade
			uniform float _Fade;
			//4_CircleBorderFade
			uniform float _Border;
			//5_Diagonal
			uniform int _LineType;
			uniform float _val0;
			uniform float _val1;


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

			//0_Line
			float drawLine(float2 uv, float start, float end)
			{
				//--
				//if(uv.x > start && uv.x < end)
				//	return 1;
				//return 0;
				//--3
				//--
				//Cancel //
				if(_HLine == 0 && uv.x > start && uv.x < end)
					return 1;
				else if(_HLine == 1 && uv.y > start && uv.y < end)
					return 1;
				return 0;
				//--6
			}
			
			//1_LinePattern
			float drawLinePattern(float2 uv, float patternW)
			{
				uv *= round(_PatternStripes*2);

				if(_HLine == 0 && fmod(round(uv.x+0.5), 2.0) == 0)
					return 1;
				else if(_HLine == 1 && fmod(round(uv.y+0.5), 2.0) == 0)
					return 1;
				return 0;
			}

			//2_Circle
			float drawCircle (float2 uv, float2 c, float r){
				float dFromCenterSq = pow(uv.y-c.y, 2) + pow(uv.x-c.x, 2);
				float rSq = pow(r, 2);
				if(dFromCenterSq < rSq)
					return 1;
				return 0;
			}

			//3_CircleFade
			float drawCircleFade (float2 uv, float2 c, float r){
				float dFromCenterSq = pow(uv.y-c.y, 2) + pow(uv.x-c.x, 2);
				float rSq = pow(r, 2);
				if(dFromCenterSq < rSq){
					//If we want to have a sharper smooth edge, we use pow()
					//float alpha = smoothstep(rSq, rSq-pow(_Fade,2), dFromCenterSq);
					float alpha = smoothstep(rSq,rSq-_Fade, dFromCenterSq);
					return alpha;
				}
				return 0;
			}

			//4_CircleBorderFade
			float drawCircleBorderFade (float2 uv, float2 c, float r){
				float dFromCenterSq = pow(uv.y-c.y, 2) + pow(uv.x-c.x, 2);
				float rSq = pow(r, 2);
				float borderSq = pow(_Border, 2)/2;
				float maxBorder = rSq+borderSq;
				float minBorder = rSq-borderSq;
				if(	dFromCenterSq < maxBorder &&
					dFromCenterSq > minBorder){
					if(dFromCenterSq > rSq)
						return smoothstep(maxBorder, maxBorder-_Fade, dFromCenterSq);
					else
						return smoothstep(minBorder, minBorder+_Fade, dFromCenterSq);
				}
				return 0;
			}

			//5_Diagonal
			float drawDiagonal(float2 uv, float w)
			{
				return smoothstep(w, 0.0, abs(uv.y-uv.x));
			}
			float drawExp(float2 uv, float w, float v)
			{
				return 	smoothstep(v-w, v, uv.y) - smoothstep(v, v+w, uv.y);
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.texcoord.xy = v.texcoord.xy;
				return o;
			}
			fixed4 frag(vertexOutput i): SV_Target
			{
				half4 finalColor = _Color;

				if(_Fx == 0){
					finalColor.a = drawLine(i.texcoord.xy, _Start, _Start+_Width);
				}
				else if(_Fx == 1){
					finalColor.a = drawLinePattern(i.texcoord.xy, _PatternStripes);
				}
				else if(_Fx == 2){
					finalColor.a = drawCircle(i.texcoord, float2(_Center,_Center), _Radius);
				}
				else if(_Fx == 3){
					finalColor.a = drawCircleFade(i.texcoord, _Center, _Radius);
				}
				else if(_Fx == 4){
					finalColor.a = drawCircleBorderFade(i.texcoord, _Center, _Radius);
				}
				else if(_Fx == 5){
					if(_LineType == 0.0)
						//Draw a simple diagonal line
						finalColor.a = (drawDiagonal(i.texcoord.xy, _Width));
					else if(_LineType == 1.0)
						//Draw Exp fx: change val0 from [0,2]
						finalColor.a = (drawExp(i.texcoord.xy, _Width, pow(i.texcoord.x, _val0)));
					else if(_LineType == 2.0)
						//Draw Step fx: Change val0 from [0,1]
						finalColor.a = (drawExp(i.texcoord.xy, _Width, step(_val0, i.texcoord.x)));
					else 
						//Draw SmoothStep fx:
						//	Change val0 from [0,0.5], val1 from [0.5,2]
						finalColor.a = (drawExp(i.texcoord.xy, _Width, smoothstep(_val0, _val1, i.texcoord.x)));
				}
				return finalColor;
			}

			ENDHLSL
		}
	}
}

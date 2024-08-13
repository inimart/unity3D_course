// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_elementsEnd"
{
	Properties
	{
		[KeywordEnum(stroke, circle, fill, rect, flip, tri, rotate, temperance, branch, theHangedMan, theEmperor, theTower, merge, theSummit, theStone, theMountain, theShadow, opposite, theOak, ripples)] _Element ("Element", Float) = 0
	}
	Subshader
	{
		Tags{"Queue" = "Geometry" "RenderType" = "Opaque"}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform float _Element;
			static const float PI = 3.141592;

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

			float stroke(float x, float s, float w)
			{
				float d = step(s,x+w*0.5) - step(s,x-w*0.5);
				return d;
			}

			float circle(float2 st)
			{
				//length(st-0.5) is 0 at the center, 0.5 at the border: we'll stroke a circle at half the quad
				//length(st-float2(0.5,0.5))
				return length(st-0.5)*2.0;
			}

			float fill(float x, float size)
			{
				return 1 - step(size, x);
			}

			float rect(float2 st, float2 s)
			{
				st = st*2-1; //the same as circle(): (st-0.5)*2.0;
				return max(abs(st.x/s.x), abs(st.y/s.y));
			}

			float flip(float v, float pct)
			{
				return lerp(v, 1.0-v, pct);
			}

			float tri(float2 st)
			{
				st = (st*2-1)*2;
				return max(	abs(st.x) * 0.866025 +
							st.y * 0.5, -st.y * 0.5);
			}

			float2 rot(float2 st, float a)
			{
				float2x2 rotM = float2x2(cos(a),-sin(a), sin(a), cos(a));
				st -= float2(0.5, 0.5);
				st = mul(rotM, st);
				st += float2(0.5, 0.5);
				return st;
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = v.texcoord.xy;
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				float result = 0;
				float2 st = i.texcoord.xy;

				if(_Element == 0){
					result = stroke(st.x, 0.5, 0.15);
				}
				else if (_Element == 1){
					//result = circle(st);
					result = stroke(circle(st), 0.5, 0.05);
				}
				else if (_Element == 2){
					result += fill(circle(st), 0.65);
					float2 offset = float2(0.1,0.05);
					//If we subtract offset, we are translating the circle center towards top-right corner 
					result -= fill(circle(st-offset), 0.5);
				}
				else if (_Element == 3){
					float sdf = rect(st, float2(1,1));
					result += stroke(sdf, 0.5, 0.125);
				}
				else if (_Element == 4){
					float2 offset = float2(0.1,0.1);
					float r = rect(st+offset, float2(1,1));
					float r2 = rect(st-offset, float2(1,1));
					result += flip(fill(r, 0.5), fill(r2, 0.5));
				}
				else if (_Element == 5){
					result += fill(tri(st), 0.5);
				}
				else if (_Element == 6){
					float2 offset = float2(0,0.1);
					result += fill(tri(st),.5);
					st+=offset;
					st = rot(st, radians(180));
					result += fill(tri(st),.5);
				}
				else if (_Element == 7){
					float2 offset = cos(st.y*PI)*0.15;
					result += stroke(st.x,0.28+offset,0.1);
					result += stroke(st.x,0.5+offset,0.1);
					result += stroke(st.x,0.72+offset,0.1);
				}
				else if (_Element == 8){
					float2 sdf = 0.5+(st.x-st.y)*0.5;
					result += stroke(sdf,0.5,0.1);
				}
				else if (_Element == 9){
					float2 sdf = 0.5+(st.x-st.y)*0.5;
					result += stroke(sdf,0.5,0.1);
					float2 sdf_inv = (st.x+st.y)*0.5;
					result += stroke(sdf_inv,0.5,0.1);
				}
				else if (_Element == 10){
					float sdf = rect(st, float2(1,1));
					result += stroke(sdf, 0.5, 0.125);
					result += fill(sdf, 0.1);
				}
				else if (_Element == 11){//12
					float sdf = rect(st, float2(0.5,1));
					float diag = (st.x+st.y)*0.5;
					result += flip(fill(sdf,0.6), stroke(diag,0.5,0.01));
				}
				else if (_Element == 12){//13
					float2 offset = float2(0.15,0.0);
					float left = circle(st+offset);
					float right = circle(st-offset);
					result += flip(stroke(left, 0.5, 0.05), fill(right,0.525));
				}
				else if (_Element == 13){//16
					float csdf = circle(st-float2(0,0.1));
					float tsdf = tri(st+float2(0,0.1));
					result += stroke(csdf, 0.45, 0.1);
					result *= step(0.55, tsdf);
					result += fill(tsdf, 0.45);
				}
				else if (_Element == 14){//20
					st = rot(st, radians(45));
					result += fill(rect(st,float2(1,1)), 0.4);
					result *= 1.0-stroke(st.x,0.5,0.02);
					result *= 1.0-stroke(st.y,0.5,0.02);
				}
				else if (_Element == 15){//21
					st = rot(st, radians(-45));
					float off = 0.12;
					float2 s = float2(1,1);
					result += fill(rect(st+off,s),0.2);
					result += fill(rect(st-off,s),0.2);
					float r = rect(st,s);
					result *= step(0.33, r);
					result += fill(r, 0.3);

				}
				else if (_Element == 16){//22
					st = rot(float2(st.x,1-st.y),radians(-45));
					float2 s = float2(1,1);
					result += fill(rect(st-0.025, s),0.4);
					result += fill(rect(st+0.025, s),0.4);
					result *= step(0.38,rect(st+0.025, s));
				}
				else if (_Element == 17){//23
					st = rot(st,radians(45));
					float2 s = float2(1,1);
					float o = 0.05;
					result += flip(fill(rect(st-o,s),0.4),fill(rect(st+o,s),0.4));
				}
				else if (_Element == 18){//24
					st = rot(st,radians(-45));
					float r1 = rect(st, float2(1.0, 1.0));
					float r2 = rect(st+0.15, float2(1.0, 1.0));
					result += stroke(r1,0.5,0.05);
					result *= step(0.325,r2);
					result += stroke(r2, 0.325, 0.05) * fill(r1, 0.525);
					result += stroke(r2,0.2,0.05);
				}
				else if (_Element == 19){//25
					st = rot(st,radians(45))-0.08;
					for(int i=0; i<4; i++){
						float r = rect(st, float2(1.0,1.0));
						result += stroke(r,0.19,0.04);
						st += 0.05;
					}
				}

				half4 finalColor = float4(result.xxx,1);

				return finalColor;
			}

			ENDCG
		}
	}
}

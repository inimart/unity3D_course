// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_elements"
{
	Properties
	{
		[KeywordEnum(stroke, circle, fill, rect, flip, tri, rotate)] _Element ("Element", Float) = 0
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
				//return clamp(d,0,1);
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
				//step(size, x) return 0 inside the shape, we want the opposit, so 1-(size, x)
				return 1 - step(size, x);
			}

			float rect(float2 st, float2 s)
			{
				//now st has [-1,1] range
				st = st*2-1;
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
					//result += sdf; //debug to view sdf gradient
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

				half4 finalColor = float4(result.xxx,1);

				return finalColor;
			}

			ENDCG
		}
	}
}

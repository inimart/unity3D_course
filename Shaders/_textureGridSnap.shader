// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureGridSnap"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {} //Before Unity 5, texture properties could have options inside the curly brace block
		_GridStep ("Grid step", Float) = 0.1
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "true"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			uniform float _GridStep;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			struct v2g
			{
				float4 wpos: SV_POSITION; //world space pos
				float4 texcoord : TEXCOORD0;
			};
			struct g2f
			{
				float4 pos: SV_POSITION; //proj space pos
				float3 norm : NORMAL;
				float4 texcoord : TEXCOORD0;
				float lightMul : TEXCOORD1;
			};

			v2g vert(vertexInput v)
			{
				v2g o;
				v.vertex = mul(unity_ObjectToWorld, v.vertex);
				v.vertex /= _GridStep;
				v.vertex = round(v.vertex);
				v.vertex *= _GridStep;

				o.wpos = v.vertex;
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);
				return o;
			}

			//Max number of vertices that comes into this
			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
			{
				float3 lightWPos = _WorldSpaceLightPos0;
				//wpos is in world space
				float3 v0 = IN[0].wpos.xyz;
				float3 v1 = IN[1].wpos.xyz;
				float3 v2 = IN[2].wpos.xyz;
				float3 wNormal = normalize(cross(v0-v1, v1-v2));
				
				float lightMul = dot(lightWPos, wNormal) + 1 / 2;
				
				g2f o;
				o.norm = wNormal;
				o.lightMul = lightMul;

				o.pos = mul(UNITY_MATRIX_VP, IN[0].wpos);
				o.texcoord = IN[0].texcoord;
				triStream.Append(o);

				o.pos = mul(UNITY_MATRIX_VP, IN[1].wpos);
				o.texcoord = IN[1].texcoord;
				triStream.Append(o);

				o.pos = mul(UNITY_MATRIX_VP, IN[2].wpos);
				o.texcoord = IN[2].texcoord;
				triStream.Append(o);
			}

			half4 frag(g2f i): COLOR
			{
				half4 texColor = tex2D(_MainTexture, i.texcoord);
				
				half4 finalColor = half4(_MainColor.rgb * texColor.rgb * i.lightMul, _MainColor.a);
				return finalColor;
			}

			ENDCG
		}
	}
}

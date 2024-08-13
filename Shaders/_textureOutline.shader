// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureOutline"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		//1
		_OutlineColor ("Outline color", Color) = (1,1,1,1)
		_OutlineBorder ("Outline border", Range(0.1,1)) = 0.1
	}
	Subshader
	{
		Tags{"Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "true"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add
			//3
			ZWrite Off
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			//1
			uniform half4 _OutlineColor;
			uniform float _OutlineBorder;

			struct vertexInput
			{
				float4 vertex : POSITION;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				
				//2
				float4x4 scaleM = float4x4(	1.0+_OutlineBorder, 0,0,0,
											0, 1.0+_OutlineBorder,0,0,
											0,0, 1.0+_OutlineBorder,0,
											0,0,0,1.0);
				float4 scaledObjPos = mul(scaleM, v.vertex);
				
				o.pos = UnityObjectToClipPos(scaledObjPos);
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				return _OutlineColor;
			}

			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;

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

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw);
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				half4 texColor = tex2D(_MainTexture, i.texcoord);
				half4 finalColor = _MainColor * texColor;
				return finalColor;
			}

			ENDCG
		}
	}
}

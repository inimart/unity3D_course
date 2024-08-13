// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_textureRotation"
{
	Properties
	{
		_MainColor ("Main color", Color) = (1,1,1,1)
		_MainTexture ("Main texture", 2D) = "white" {}
		//Texture rotation
		_AlfaDegrees ("Alpha rot degrees", Range(0,360)) = 0
		_RotCenterX ("Rot center X", Range(0,1)) = 0.5
		_RotCenterY ("Rot center Y", Range(0,1)) = 0.5
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
			
			uniform half4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			//Texture rotation
			uniform float _AlfaDegrees;
			uniform float _RotCenterX;
			uniform float _RotCenterY;

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

				//From degrees to rad
				//radians(x) = x * PI / 180;
				float rad		= radians(_AlfaDegrees);
				//To build rotation matrix, we need cos(alfa) and sin(alfa)
				float cosAlfa = cos(rad);
				float sinAlfa = sin(rad);
				//Build the rotation matrix
				float2x2 rotM = float2x2(cosAlfa, -sinAlfa, sinAlfa, cosAlfa);
				//To rotate (x,y) around (a,b) point, we need to subtract (a,b)
				//	from (x,y), rotate, and then add (a,b) again.
				v.texcoord.xy -= float2(_RotCenterX, _RotCenterY);
				v.texcoord.xy = mul(rotM, v.texcoord.xy);
				v.texcoord.xy += float2(_RotCenterX, _RotCenterY);
				//Finally, we can take into account tiling and scaling				
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

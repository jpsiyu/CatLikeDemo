// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Gray"{
	Properties{
		_MainTex("Main Tex", 2D) = "white" {}
	}

	SubShader{
		Pass{ //物体在一个Pass渲染一次，多个Pass就会渲染多次
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			sampler2D _MainTex;

			struct a2v{
				fixed4 position : POSITION;
				fixed4 texcoord : TEXCOORD0;
			};

			struct v2f{
				fixed4 pos : SV_POSITION;
				fixed4 texcoord : TEXCOORD0;
			};

			v2f MyVertexProgram(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.position);
				o.texcoord = v.texcoord;
				return o;
			}

			float4 MyFragmentProgram(v2f i) : SV_TARGET{
				fixed4 color = tex2D(_MainTex, i.texcoord);
				float grey = dot(color.rgb, fixed3(0.22, 0.707, 0.071));
				return float4(grey, grey, grey, color.a);
			}

			ENDCG
		}
	}
}
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/My First Shader"{
	Properties{
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
	}

	SubShader{
		Pass{ //物体在一个Pass渲染一次，多个Pass就会渲染多次
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct VertexData{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Interpolators{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			Interpolators MyVertexProgram(VertexData v){
				Interpolators i ;
				i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
				i.position = UnityObjectToClipPos(v.position);
				return i;
			}

			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				return tex2D(_MainTex, i.uv) * _Tint;
			}

			ENDCG
		}
	}
}
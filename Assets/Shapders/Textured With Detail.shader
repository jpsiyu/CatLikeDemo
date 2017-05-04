// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Textured With Detail"{
	Properties{
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
		_DetailTex("Detal Tex", 2D) = "gray" {}
	}

	SubShader{
		Pass{ //物体在一个Pass渲染一次，多个Pass就会渲染多次
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex, _DetailTex;
			float4 _MainTex_ST, _DetailTex_ST;

			struct VertexData{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Interpolators{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvDetail : TEXCOORD1;
			};

			Interpolators MyVertexProgram(VertexData v){
				Interpolators i ;
				i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
				i.uvDetail = v.uv * _DetailTex_ST.xy + _DetailTex_ST.zw;
				i.position = UnityObjectToClipPos(v.position);
				return i;
			}

			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				float4 color = tex2D(_MainTex, i.uv) * _Tint;
				color *= tex2D(_DetailTex, i.uvDetail * 10) * 2;
				return color;
			}

			ENDCG
		}
	}
}
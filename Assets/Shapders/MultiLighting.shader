Shader "Custom/MultiLighting" {
	Properties {
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
		_Smoothness("Smoothness", Range(0, 1)) = 0.5
		[Gamma]_Metallic("Metallic", Range(0, 1)) = 0
	}
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			#include "My Lighting.cginc"

			ENDCG
			
		}
		Pass{
			Tags{"LightMode" = "ForwardAdd"}
			//混合模式：新的颜色*1 + 旧的颜色*1
			//默认的混合模式为 Bend One Zero：新的颜色*1 + 旧的颜色*0； 即新颜色覆盖旧颜色
			Blend One One
			ZWrite Off

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#pragma multi_compile DIRECTIONAL POINT
			#include "My Lighting.cginc"

			ENDCG
		}
	}
	FallBack "Diffuse"
}

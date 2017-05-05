Shader "Custom/MultiLighting" {
	Properties {
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
		//凹凸贴图（并非法线贴图，凹凸贴图存储的值用于计算法线，法线贴图的值可以直接使用）
		//设置不显示缩放平移属性
		//[NoScaleOffset]_HeightMap("Heights", 2D) = "gray" {}
		[NoScaleOffset]_NormalMap("Normals", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1
		_Smoothness("Smoothness", Range(0, 1)) = 0.5
		[Gamma]_Metallic("Metallic", Range(0, 1)) = 0
		_DetailTex("Detail Tex", 2D) = "gray" {}
		[NoScaleOffset]_DetailNormalMap("Detail Normals", 2D) = "bump" {}
		_DetailBumpScale("Detail Bump Scale", Float) = 1

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

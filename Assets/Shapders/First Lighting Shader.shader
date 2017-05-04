// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/First Lighting Shader" {
	Properties {
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
		_Smoothness("Smoothness", Range(0, 1)) = 0.5
		[Gamma]_Metallic("Metallic", Range(0, 1)) = 0
	}
	SubShader {
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			#include "UnityPBSLighting.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Smoothness;
			float _Metallic;

			struct VertexData{
				float4 position : POSITION; //模型空间坐标
				float4 normal : NORMAL; // 顶点法线
				float2 uv : TEXCOORD0; // mesh uv
			};

			struct Interpolators{
				float4 position : SV_POSITION; //顶点屏幕空间位置
				float2 uv : TEXCOORD0; // 计算了缩放平移的uv
				float3 normal : TEXCOORD1; // 顶点法线
				float3 worldPos : TEXCOORD2; //顶点世界空间位置
			};

			Interpolators MyVertexProgram(VertexData v){
				Interpolators i; //定义输出结构
				//模型空间-屏幕空间
				i.position = UnityObjectToClipPos(v.position);
				//计算平移和位置的UV
				i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
				//法线转换至世界空间
				i.normal = UnityObjectToWorldNormal(v.normal);
				//必须进行归一化，法线的长度对计算有影响，更长的法线得到更亮的颜色
				i.normal = normalize(i.normal);
				i.worldPos = mul(unity_ObjectToWorld, v.position);
				return i;
			}

			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				i.normal = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 reflectDir = reflect(-lightDir, i.normal);
				float3 lightColor = _LightColor0.rgb;
				float3 halfDir = normalize(lightDir + viewDir);

				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
				float3 specularTint;
				float oneMinusReflectivity;
				albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);
				
				float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);
				float3 specular = specularTint.rgb * lightColor * pow( DotClamped(halfDir, i.normal), _Smoothness * 100);
				//return float4(diffuse + specular, 1);


				UnityLight light;
				light.color = lightColor;
				light.dir = lightDir;
				light.ndotl = DotClamped(i.normal, lightDir);

				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

				return UNITY_BRDF_PBS(
					albedo, specularTint,
					oneMinusReflectivity, _Smoothness,
					i.normal, viewDir,
					light, indirectLight
				);
			}


			ENDCG
		}
	}
	FallBack "Diffuse"
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

float4 _Tint;
sampler2D _MainTex, _DetailTex;
//sampler2D _HeightMap;
//float4 _HeightMap_TexelSize; //一像素的大小
sampler2D _NormalMap, _DetailNormalMap;
float _BumpScale, _DetailBumpScale;
float4 _MainTex_ST, _DetailTex_ST;
float _Metallic;
float _Smoothness;

struct VertexData {
	float4 position : POSITION;
	float3 normal : NORMAL;
	float4 uv : TEXCOORD0;
};

struct Interpolators {
	float4 position : SV_POSITION;
	float4 uv : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float3 worldPos : TEXCOORD2;
};

UnityLight CreateLight(Interpolators i){
	UnityLight light;
	#if defined(POINT)
		light.dir = normalize( _WorldSpaceLightPos0.xyz - i.worldPos);
	#else 
		light.dir = _WorldSpaceLightPos0.xyz;
	#endif
	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;

}

Interpolators MyVertexProgram (VertexData v) {
	Interpolators i;
	i.position = UnityObjectToClipPos(v.position);
	i.worldPos = mul(unity_ObjectToWorld, v.position);
	i.normal = UnityObjectToWorldNormal(v.normal);
	i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
	i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
	return i;
}


void InitializeFragmentNormal(inout Interpolators i){
	//将法线贴图的高度值（法线贴图的RGB值都是一样的，代表高度值)
	//float h = tex2D(_HeightMap, i.uv);
	//将法线题图的高度值作为该像素法线的高度
	//i.normal = float3(0, h, 0);

	//法线值设置为(1, 该位置斜率tan，0）
	
	//float u1 = tex2D(_HeightMap, i.uv - du);
	//float u2 = tex2D(_HeightMap, i.uv + du);
	//float3 tu = float3(1, u2 - u1, 0);

	//float2 dv = float2(_HeightMap_TexelSize.y * 0.5, 0);
	//float v1 = tex2D(_HeightMap, i.uv - dv);
	//float v2 = tex2D(_HeightMap, i.uv + dv);
	//float3 tv = float3(0, v2 - v1, 1);

	//法线贴图U坐标的斜率，V坐标的斜率，构成的平面的法线作为该像素的法线
	//左手定则获得的法线（顺时针），面朝外
	//i.normal = float3(u1 - u2, 1, v1 - v2);

	//i.normal.xy = tex2D(_NormalMap, i.uv).wy * 2 - 1;
	//i.normal.xy *= _BumpScale;
	//i.normal.z = sqrt(1 - saturate( dot(i.normal.xy, i.normal.xy)));

	float3 mainNormal = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);
	float3 detailNormal = UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv.zw), _DetailBumpScale);
	//i.normal = float3(mainNormal.xy / mainNormal.z + detailNormal.xy / detailNormal.z, 1);
	i.normal = BlendNormals(mainNormal, detailNormal);
	i.normal = i.normal.xzy;
	//法线归一化
	i.normal = normalize(i.normal);
}

float4 MyFragmentProgram (Interpolators i) : SV_TARGET {
	InitializeFragmentNormal(i);
	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

	//主纹理
	float3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Tint.rgb;
	//细节纹理
	albedo *= tex2D(_DetailTex, i.uv.zw) * unity_ColorSpaceDouble;

	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);

	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	return UNITY_BRDF_PBS(
		albedo, specularTint,
		oneMinusReflectivity, _Smoothness,
		i.normal, viewDir,
		CreateLight(i), indirectLight
	);
}

#endif
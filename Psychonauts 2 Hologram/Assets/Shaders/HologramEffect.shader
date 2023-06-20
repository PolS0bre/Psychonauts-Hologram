Shader "Custom/HologramEffect"
{
    Properties{
         _Color("Hologram Color", Color) = (1,1,1,1)
         _Transparency("Transparency", Range(0.0, 1.0)) = 0.5
    }
        SubShader{
            Tags {"Queue" = "Transparent" "RenderType" = "Transparent"}
            LOD 100

            Pass {
                Blend SrcAlpha OneMinusSrcAlpha
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                struct appdata {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };

                struct v2f {
                    float4 pos : SV_POSITION;
                    float3 worldNormal : TEXCOORD0;
                    float3 worldPos : TEXCOORD1;
                };

                float4 _Color;
                float _Transparency;

                v2f vert(appdata v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    return o;
                }

                float4 frag(v2f i) : COLOR {
                    float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                    float3 worldNormal = normalize(i.worldNormal);
                    float3 reflected = reflect(viewDir, worldNormal);
                    float rim = 1.0 - max(0, dot(-viewDir, reflected));

                    // Add the hologram color to the rim
                    float4 col = _Color;
                    col.rgb *= rim;

                    // Set alpha based on the rim value and transparency property
                    col.a = rim * _Transparency;

                    return col;
                }
                ENDCG
            }
    }
        FallBack "Diffuse"
}
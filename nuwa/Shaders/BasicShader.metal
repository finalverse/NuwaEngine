#include <metal_stdlib>
#include <simd/simd.h>
//#import "ShaderTypes.h"
#import "SharedShaders.metal"

using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float3 worldPosition;
    float3 normal;
    float2 texCoord;
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;
    float4 position = float4(in.position, 1.0);
    out.position = uniforms.viewProjectionMatrix * uniforms.modelMatrix * position;
    out.worldPosition = (uniforms.modelMatrix * position).xyz;
    out.normal = normalize((uniforms.modelMatrix * float4(in.normal, 0.0)).xyz);
    out.color = in.color;
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                              texture2d<float> colorMap [[texture(TextureIndexColor)]]) {
    constexpr sampler textureSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
    float3 baseColor = colorMap.sample(textureSampler, in.texCoord).rgb * in.color.rgb;
    float ambientStrength = 0.1;
    float3 ambient = ambientStrength * baseColor;
    return float4(ambient, 1.0);
}

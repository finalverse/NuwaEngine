//
//  MaterialShader.metal
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-09.
//

#include <metal_stdlib>
#include <simd/simd.h>
#import "ShaderTypes.h"

using namespace metal;

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
    float4 color [[attribute(VertexAttributeColor)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float3 worldPosition;
    float3 normal;
    float2 texCoord;
};

vertex VertexOut material_vertex(VertexIn in [[stage_in]],
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

fragment float4 material_fragment(VertexOut in [[stage_in]],
                                  constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                                  texture2d<float> texture [[texture(TextureIndexColor)]]) {
    constexpr sampler textureSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
    float4 textureColor = texture.sample(textureSampler, in.texCoord);
    return float4(textureColor.rgb * in.color.rgb, 1.0);
}
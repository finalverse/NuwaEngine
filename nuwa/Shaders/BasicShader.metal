//
//  BasicShader.metal
//  NuwaEngine
//
//  Handles simple transformation and texture sampling for basic rendering.
//
//  Updated to align with ShaderTypes.h.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "SharedShaders.metal"
using namespace metal;

// Vertex Shader: Transforms vertex attributes into world and clip space.
vertex VertexOut basicShader_vertex(VertexIn in [[stage_in]],
                                    constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPosition.xyz;
    out.position = uniforms.viewProjectionMatrix * worldPosition;
    out.color = in.color;
    out.texCoord = in.texCoord;
    return out;
}

// Fragment Shader: Samples the texture and applies ambient lighting.
fragment float4 basicShader_fragment(VertexOut in [[stage_in]],
                                     constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                                     texture2d<float> colorMap [[texture(TextureIndexColor)]]) {
    constexpr sampler textureSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
    float3 sampledColor = colorMap.sample(textureSampler, in.texCoord).rgb * in.color.rgb;
    return float4(sampledColor * 0.1, 1.0);  // Apply ambient light
}

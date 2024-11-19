//
//  BasicShader.metal
//  NuwaEngine
//
//  Handles simple transformation and texture sampling for basic rendering.
//
//  Updated to align with ShaderTypes.h and ShaderMaterial.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "SharedShaders.metal"
#import "ShaderTypes.h"
using namespace metal;

// Vertex Shader: Transforms vertex attributes into world and clip space.
vertex VertexOut basicShader_vertex(VertexIn in [[stage_in]],
                                    constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;

    // Transform position to world and clip space
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPosition.xyz;
    out.position = uniforms.viewProjectionMatrix * worldPosition;

    // Pass through attributes
    out.color = in.color;
    out.texCoord = in.texCoord;

    return out;
}

// Fragment Shader: Samples the texture and applies ambient lighting.
fragment float4 basicShader_fragment(VertexOut in [[stage_in]],
                                     constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                                     texture2d<float> colorMap [[texture(TextureIndexColor)]]) {
    constexpr sampler textureSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);

    // Sample base color texture
    float3 baseColor = uniforms.material.diffuseColor;
    float3 sampledColor = colorMap.sample(textureSampler, in.texCoord).rgb;

    // Combine sampled color with material properties
    float3 finalColor = sampledColor * baseColor;

    return float4(finalColor * 0.1, 1.0);  // Apply ambient light
}

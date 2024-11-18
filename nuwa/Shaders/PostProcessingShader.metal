//
//  PostProcessingShader.metal
//  NuwaEngine
//
//  Implements post-processing effects like bloom, tone mapping, and color grading.
//  Designed for full-screen quad rendering.
//
//  Fully compatible with ShaderTypes.h.
//
//  Created by Wenyan Qin on 2024-11-19.
//

#include <metal_stdlib>
#include <simd/simd.h>
#import "SharedShaders.metal"

using namespace metal;

/// Vertex output structure for the screen-space quad
struct QuadVertexOut {
    float4 position [[position]];  // Position of the quad vertex in clip space
    float2 texCoord;               // Texture coordinates for sampling
};

// Vertex Shader
//
// Pass-through vertex shader for rendering a screen-space quad.
//
// - Parameters:
//   - in: Vertex attributes from the CPU (`VertexIn` with position and texCoord only).
// - Returns: Screen-space quad vertex data for the fragment shader.
vertex QuadVertexOut postProcessing_vertex(VertexIn in [[stage_in]]) {
    QuadVertexOut out;
    out.position = float4(in.position.xy, 0.0, 1.0);
    out.texCoord = in.texCoord;
    return out;
}

// Fragment Shader
//
// Applies post-processing effects such as tone mapping and bloom.
//
// - Parameters:
//   - in: Vertex data from the vertex shader (`QuadVertexOut`).
//   - hdrTexture: High Dynamic Range texture from the rendering pass.
//   - uniforms: Material and transformation properties (unused in post-processing).
// - Returns: Processed color for each fragment.
fragment float4 postProcessing_fragment(QuadVertexOut in [[stage_in]],
                                        texture2d<float> hdrTexture [[texture(TextureIndexColor)]],
                                        sampler textureSampler) {
    // Sample HDR color
    float3 hdrColor = hdrTexture.sample(textureSampler, in.texCoord).rgb;

    // Apply tone mapping
    float exposure = 1.0; // Example exposure value
    float3 toneMapped = 1.0 - exp(-hdrColor * exposure);

    // Simple bloom (for demonstration)
    float bloomStrength = 0.3;
    float3 bloom = hdrColor * bloomStrength;

    // Combine tone-mapped color and bloom
    float3 finalColor = toneMapped + bloom;

    return float4(finalColor, 1.0);
}

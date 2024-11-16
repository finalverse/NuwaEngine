// ShadowShader.metal
// NuwaEngine
// Created by Wenyan Qin on 2024-11-09.

#include <metal_stdlib>
#include <simd/simd.h>
//#import "ShaderTypes.h"
#import "SharedShaders.metal"

using namespace metal;

// Output structure for vertex shader
struct VertexOut {
    float4 position [[position]];     // Position for rasterization
    float4 color;                     // Vertex color
    float3 worldPosition;             // Position in world space for lighting
    float3 normal;                    // Normal for lighting calculations
    float2 texCoord;                  // Texture coordinates
};

// Vertex function for shadow rendering
vertex VertexOut shadow_vertex(VertexIn in [[stage_in]],
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

// Fragment function for shadow rendering
fragment float4 shadow_fragment(VertexOut in [[stage_in]],
                                constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    return float4(0.0, 0.0, 0.0, 1.0); // Shadow color (black)
}

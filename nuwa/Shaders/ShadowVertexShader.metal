//
//  ShadowVertexShader.metal
//  NuwaEngine
//
//  Transforms geometry into the light's clip space for shadow mapping.
//  This is used in the shadow map generation pass.
//
//  Fully compatible with ShaderTypes.h.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "SharedShaders.metal"
using namespace metal;

// Vertex Shader
//
// Projects geometry into light clip space for shadow map generation.
//
// - Parameters:
//   - in: Vertex attributes from the CPU (`VertexIn`).
//   - lightMatrix: Transformation matrix from world space to light clip space.
// - Returns: Vertex position in the light's clip space.
vertex float4 shadow_vertex(VertexIn in [[stage_in]],
                            constant float4x4 &lightMatrix [[buffer(BufferIndexUniforms)]]) {
    return lightMatrix * float4(in.position, 1.0); // Transform to light's clip space
}

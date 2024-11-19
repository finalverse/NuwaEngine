//
//  DeferredShader.metal
//  NuwaEngine
//
//  Implements deferred rendering by separating geometry and lighting calculations.
//
//  Updated to align with ShaderTypes.h and ShaderMaterial.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "SharedShaders.metal"
#import "ShaderTypes.h"
using namespace metal;

// Vertex Shader: Outputs world-space geometry for lighting calculations.
vertex VertexOut deferred_vertex(VertexIn in [[stage_in]],
                                 constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;

    // Transform position to world space
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPosition.xyz;

    // Transform normals
    out.worldNormal = normalize((uniforms.modelMatrix * float4(in.normal, 0.0)).xyz);

    // Transform position to clip space
    out.position = uniforms.viewProjectionMatrix * worldPosition;

    // Pass through attributes
    out.texCoord = in.texCoord;
    out.color = in.color;

    return out;
}

// Fragment Shader: Passes interpolated attributes for later lighting passes.
fragment float4 deferred_fragment(VertexOut in [[stage_in]],
                                  constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    // Encode base material color
    return float4(uniforms.material.diffuseColor, 1.0);
}

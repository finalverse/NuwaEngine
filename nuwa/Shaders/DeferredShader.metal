//
//  DeferredShader.metal
//  NuwaEngine
//
//  Implements deferred rendering by separating geometry and lighting calculations.
//
//  Updated to align with ShaderTypes.h.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "SharedShaders.metal"
using namespace metal;

// Vertex Shader: Outputs world-space geometry for lighting calculations.
vertex VertexOut deferred_vertex(VertexIn in [[stage_in]],
                                 constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPosition.xyz;
    out.worldNormal = normalize((uniforms.modelMatrix * float4(in.normal, 0.0)).xyz);
    out.position = uniforms.viewProjectionMatrix * worldPosition;
    out.texCoord = in.texCoord;
    return out;
}

// Fragment Shader: Passes interpolated attributes for later lighting passes.
fragment float4 deferred_fragment(VertexOut in [[stage_in]],
                                  constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    return float4(in.color.rgb, 1.0); // Outputs the material's base color
}

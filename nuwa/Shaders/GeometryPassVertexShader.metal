//
//  GeometryPassVertexShader.metal
//  NuwaEngine
//
//  Handles the geometry pass of deferred rendering by transforming vertex attributes
//  into world and clip space for later lighting passes.
//
//  Updated to align with ShaderTypes.h and ShaderMaterial.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "SharedShaders.metal"
#import "ShaderTypes.h"
using namespace metal;

// Vertex Shader: Prepares geometry data for the lighting pass.
vertex VertexOut geometryPass_vertex(VertexIn in [[stage_in]],
                                     constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;

    // Transform position to world space
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPosition.xyz;

    // Transform normals and tangents
    out.worldNormal = normalize((uniforms.modelMatrix * float4(in.normal, 0.0)).xyz);
    out.worldTangent = normalize((uniforms.modelMatrix * float4(in.tangent, 0.0)).xyz);
    out.worldBitangent = normalize((uniforms.modelMatrix * float4(in.bitangent, 0.0)).xyz);

    // Transform position to clip space
    out.position = uniforms.viewProjectionMatrix * worldPosition;

    // Pass through attributes
    out.color = in.color;
    out.texCoord = in.texCoord;

    return out;
}

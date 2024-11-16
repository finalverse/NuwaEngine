//
//  MasterShader.metal
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-07.
//

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

// Ensure `MaterialProperties` is defined in this file or imported from ShaderTypes.h
struct MaterialProperties {
    float3 diffuseColor;
    float3 specularColor;
    float shininess;
    int hasTexture;
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;
    out.position = float4(in.position, 1.0); // Pass-through position
    out.color = float4(1.0, 0.0, 0.0, 1.0); // Solid red color for debugging
    out.worldPosition = in.position;
    out.normal = in.normal;
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return float4(1.0, 0.0, 0.0, 1.0); // Solid red color
}

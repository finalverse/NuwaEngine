//
//  BasicLightingShader.metal
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
using namespace metal;

// Vertex and fragment structures
struct VertexInput {
    float4 position [[attribute(VertexAttributePosition)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
};

struct VertexOutput {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
};

struct LightData {
    int type;
    float3 color;
    float intensity;
    float3 position;
    float padding1; // Alignment
    float3 direction;
    float padding2; // Alignment
};

// Vertex Shader
vertex VertexOutput phongVertexShader(VertexInput in [[stage_in]],
                                      constant float4x4 &modelMatrix [[buffer(BufferIndexUniforms)]]) {
    VertexOutput out;
    out.worldPosition = (modelMatrix * in.position).xyz;
    out.worldNormal = normalize((modelMatrix * float4(in.normal, 0.0)).xyz);
    out.position = modelMatrix * in.position;
    return out;
}

// Fragment Shader
fragment float4 phongFragmentShader(VertexOutput in [[stage_in]],
                                    constant LightData *lights [[buffer(BufferIndexLights)]],
                                    constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                                    constant int &lightCount

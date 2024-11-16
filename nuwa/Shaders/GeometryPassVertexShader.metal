//
//  GeometryPassVertexShader.metal
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
using namespace metal;

struct VertexInput {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
};

struct GeometryOutput {
    float4 position [[position]];
    float3 worldNormal;
    float3 worldPosition;
};

vertex GeometryOutput geometryPassVertexShader(VertexInput in [[stage_in]], constant float4x4 &modelMatrix [[buffer(0)]]) {
    GeometryOutput out;
    out.worldPosition = (modelMatrix * in.position).xyz;
    out.worldNormal = in.normal;
    out.position = modelMatrix * in.position;
    return out;
}

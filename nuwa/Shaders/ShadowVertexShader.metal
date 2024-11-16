//
//  ShadowVertexShader.metal
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
using namespace metal;

struct VertexInput {
    float4 position [[attribute(0)]];
};

struct VertexOutput {
    float4 position [[position]];
    float4 shadowPosition;
};

vertex VertexOutput shadowVertexShader(VertexInput in [[stage_in]], constant float4x4 &lightMatrix [[buffer(1)]]) {
    VertexOutput out;
    // Transform vertex position by light matrix for shadow mapping
    out.shadowPosition = lightMatrix * in.position;
    out.position = out.shadowPosition;
    return out;
}


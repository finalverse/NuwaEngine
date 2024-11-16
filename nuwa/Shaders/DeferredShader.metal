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

vertex VertexOut deferred_vertex(VertexIn in [[stage_in]],
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

fragment float4 deferred_fragment(VertexOut in [[stage_in]],
                                  constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    return float4(in.color.rgb, 1.0);
}

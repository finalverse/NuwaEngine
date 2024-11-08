//
//  MasterShader.metal
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-07.
//

#include <metal_stdlib>
#include <simd/simd.h>
#import "ShaderTypes.h"

using namespace metal;

struct VertexIn {
    float3 position [[attribute(VertexAttributePosition)]];
    float4 color [[attribute(VertexAttributeColor)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float3 worldPosition;
    float3 normal;
    float2 texCoord;
};

// Vertex function to be used in the render pipeline
vertex VertexOut vertex_main(VertexIn in [[stage_in]],
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

// Fragment function for handling both lighting and material shading
fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                              texture2d<float> colorMap [[texture(TextureIndexColor)]]) {
  //  constexpr sampler textureSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
  //  float4 colorSample = colorMap.sample(textureSampler, in.texCoord);
  //  return float4(colorSample.rgb * in.color.rgb, 1.0);
    
    // Define a basic lighting factor
    float lightingFactor = 0.8;

    // Apply vertex color with a lighting factor, ignoring the texture for now
    float3 color = in.color.rgb * lightingFactor;
    
    // Return final color, forcing alpha to 1.0
    return float4(color, 1.0);
    
}

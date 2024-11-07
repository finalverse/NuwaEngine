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

vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;
    float4 position = float4(in.position, 1.0);
    
    // Use viewProjectionMatrix and modelMatrix from Uniforms
    out.position = uniforms.viewProjectionMatrix * uniforms.modelMatrix * position;
    out.worldPosition = (uniforms.modelMatrix * position).xyz;
    out.normal = normalize((uniforms.modelMatrix * float4(in.normal, 0.0)).xyz);
    out.color = in.color;
    out.texCoord = in.texCoord;
    return out;
}

/*
 fragment float4 fragment_main(VertexOut in [[stage_in]],
     constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
     texture2d<half> colorMap [[texture(TextureIndexColor)]]) {
         constexpr sampler textureSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
         half4 colorSample = colorMap.sample(textureSampler, in.texCoord);
         float3 sampledColor = float3(colorSample.rgb);  // Convert `half3` to `float3`
 
     return float4(sampledColor * in.color.rgb, 1.0);
 }
*/

fragment float4 fragment_main(
                    VertexOut in [[stage_in]],
                    constant Uniforms &uniforms [[buffer(1)]],
                    constant SceneLight *lights [[buffer(2)]],
                    constant int &sceneLightCount [[buffer(3)]],
                    texture2d<float> texture [[texture(0)]]) {
    return float4(0.0, 1.0, 0.0, 1.0); // Bright red (1,0,0), green(0,1,0)
}


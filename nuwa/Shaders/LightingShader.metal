//
//  LightingShader.metal
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-09.
//

#include <metal_stdlib>
#include <simd/simd.h>
#import "ShaderTypes.h"

using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float3 worldPosition;
    float3 normal;
    float2 texCoord;
};

float3 applyLighting(VertexOut in,
                     constant SceneLight *lights [[buffer(BufferIndexLights)]],
                     int sceneLightCount,
                     constant Uniforms &uniforms) {
    float3 accumulatedColor = float3(0.0);
    for (int i = 0; i < sceneLightCount; i++) {
        SceneLight light = lights[i];
        float3 lightColor = light.color * light.intensity;

        if (light.type == LightTypeAmbient) {
            accumulatedColor += lightColor * uniforms.material.diffuseColor;
        } else if (light.type == LightTypeDirectional) {
            float3 lightDir = normalize(light.direction);
            float diffuseFactor = max(dot(in.normal, lightDir), 0.0);
            accumulatedColor += lightColor * uniforms.material.diffuseColor * diffuseFactor;
        }
    }
    return accumulatedColor;
}

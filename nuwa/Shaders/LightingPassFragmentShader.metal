//
//  LightingPassFragmentShader.metal
//  NuwaEngine
//
//  Performs lighting calculations during the lighting pass. Combines contributions
//  from multiple lights using Phong lighting (ambient, diffuse, specular).
//
//  Updated to align with ShaderTypes.h and ShaderMaterial.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "SharedShaders.metal"
#import "ShaderTypes.h"
using namespace metal;

// Helper Function: Computes lighting contributions using Phong lighting.
float3 applyLighting(VertexOut in,
                     constant LightData *lights [[buffer(BufferIndexLights)]],
                     constant int &sceneLightCount [[buffer(BufferIndexLightCount)]],
                     constant ShaderMaterial &material,
                     float3 cameraPosition) {
    float3 accumulatedColor = float3(0.0);

    for (int i = 0; i < sceneLightCount; i++) {
        LightData light = lights[i];
        float3 lightColor = light.color * light.intensity;

        // Ambient lighting
        if (light.type == LightTypeAmbient) {
            accumulatedColor += lightColor * material.diffuseColor;

        // Directional lighting
        } else if (light.type == LightTypeDirectional) {
            float3 lightDir = normalize(light.direction);
            float diffuseFactor = max(dot(in.worldNormal, lightDir), 0.0);
            accumulatedColor += lightColor * material.diffuseColor * diffuseFactor;

            // Specular lighting (Blinn-Phong)
            float3 viewDir = normalize(cameraPosition - in.worldPosition);
            float3 halfwayDir = normalize(lightDir + viewDir);
            float spec = pow(max(dot(in.worldNormal, halfwayDir), 0.0), material.shininess);
            accumulatedColor += lightColor * spec;
        }
    }
    return accumulatedColor;
}

// Fragment Shader: Combines light contributions.
fragment float4 lightingPass_fragment(VertexOut in [[stage_in]],
                                      constant LightData *lights [[buffer(BufferIndexLights)]],
                                      constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                                      constant int &sceneLightCount [[buffer(BufferIndexLightCount)]]) {
    float3 lighting = applyLighting(in, lights, sceneLightCount, uniforms.material, uniforms.cameraPosition);
    return float4(lighting, 1.0);
}

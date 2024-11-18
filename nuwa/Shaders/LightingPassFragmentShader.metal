//
//  LightingPassFragmentShader.metal
//  NuwaEngine
//
//  Performs lighting calculations during the lighting pass. Combines contributions
//  from multiple lights using Phong lighting (ambient, diffuse, specular).
//
//  Updated to align with ShaderTypes.h.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "SharedShaders.metal"
using namespace metal;

// Computes lighting contributions for a given fragment using Phong lighting.
float3 applyLighting(VertexOut in,
                     constant LightData *lights [[buffer(BufferIndexLights)]],
                     constant int &sceneLightCount [[buffer(BufferIndexLightCount)]],
                     constant Uniforms &uniforms) {
    float3 accumulatedColor = float3(0.0);

    for (int i = 0; i < sceneLightCount; i++) {
        LightData light = lights[i];
        float3 lightColor = light.color * light.intensity;

        // Ambient lighting
        if (light.type == LightTypeAmbient) {
            accumulatedColor += lightColor * uniforms.material.diffuseColor;

        // Directional lighting
        } else if (light.type == LightTypeDirectional) {
            float3 lightDir = normalize(light.direction);
            float diffuseFactor = max(dot(in.worldNormal, lightDir), 0.0);
            accumulatedColor += lightColor * uniforms.material.diffuseColor * diffuseFactor;

            // Specular lighting (Blinn-Phong)
            float3 viewDir = normalize(uniforms.cameraPosition - in.worldPosition);
            float3 halfwayDir = normalize(lightDir + viewDir);
            float spec = pow(max(dot(in.worldNormal, halfwayDir), 0.0), uniforms.material.shininess);
            accumulatedColor += lightColor * spec;
        }
    }
    return accumulatedColor;
}

// Fragment Shader
//
// Combines light contributions using `applyLighting` and returns the final fragment color.
//
// - Parameters:
//   - in: Geometry data for the fragment (`VertexOut`).
//   - lights: Buffer of light data.
//   - uniforms: Transformation and material data.
//   - sceneLightCount: Number of active lights in the scene.
// - Returns: The final color of the fragment.
fragment float4 lightingPass_fragment(VertexOut in [[stage_in]],
                                      constant LightData *lights [[buffer(BufferIndexLights)]],
                                      constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                                      constant int &sceneLightCount [[buffer(BufferIndexLightCount)]]) {
    float3 lighting = applyLighting(in, lights, sceneLightCount, uniforms);
    return float4(lighting, 1.0);
}

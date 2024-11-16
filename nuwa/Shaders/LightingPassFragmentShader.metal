//
//  LightingPassFragmentShader.metal
//  NuwaEngine
//
//  This shader performs the lighting calculations in the lighting pass, applying the effects
//  of multiple lights to the surface. It uses the world position and normal from the geometry pass
//  and blends light contributions from the provided light buffer.
//
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#include <simd/simd.h>
//#import "ShaderTypes.h"  // Ensure ShaderTypes.h defines LightData, Uniforms, etc.
#import "SharedShaders.metal"

using namespace metal;

/// Structure to receive interpolated world-space data from the geometry pass
struct GeometryOutput {
    float3 worldPosition;  // Position of the fragment in world space
    float3 worldNormal;    // Normal vector of the fragment in world space
};

/// Applies lighting calculations to a given fragment using light data from the buffer
///
/// - Parameters:
///   - in: The `GeometryOutput` containing world position and normal vectors.
///   - lights: Array of `LightData` structures containing light information.
///   - sceneLightCount: The number of lights in the scene to consider for calculations.
///   - uniforms: A constant `Uniforms` structure holding material and transformation information.
///
/// - Returns: The final color of the fragment after applying lighting calculations.
float3 applyLighting(GeometryOutput in,
                     constant LightData *lights [[buffer(BufferIndexLights)]],
                     constant int &sceneLightCount [[buffer(BufferIndexLightCount)]],
                     constant Uniforms &uniforms) {
    // Initialize the accumulated color for light contributions
    float3 accumulatedColor = float3(0.0);

    // Iterate through each light in the buffer
    for (int i = 0; i < sceneLightCount; i++) {
        LightData light = lights[i];
        float3 lightColor = light.color * light.intensity;

        // Apply ambient lighting, which affects the entire surface uniformly
        if (light.type == LightTypeAmbient) {
            accumulatedColor += lightColor * uniforms.material.diffuseColor;

        // Apply directional lighting based on light direction and surface normal
        } else if (light.type == LightTypeDirectional) {
            // Normalize the light direction
            float3 lightDir = normalize(light.direction);

            // Calculate the diffuse factor as the cosine of the angle between light and normal
            float diffuseFactor = max(dot(in.worldNormal, lightDir), 0.0);

            // Accumulate the diffuse lighting, modulated by the material's diffuse color
            accumulatedColor += lightColor * uniforms.material.diffuseColor * diffuseFactor;
        }
    }
    return accumulatedColor;
}

/// Fragment shader for the lighting pass, applying light contributions to the fragment.
///
/// - Parameters:
///   - in: The interpolated `GeometryOutput` containing world position and normal vectors.
///   - lights: A buffer of `LightData` structures representing the active lights in the scene.
///   - uniforms: A constant `Uniforms` structure holding material and transformation information.
///
/// - Returns: The final fragment color after lighting calculations.
fragment float4 lightingPassFragmentShader(GeometryOutput in [[stage_in]],
                                           constant LightData *lights [[buffer(BufferIndexLights)]],
                                           constant Uniforms &uniforms,
                                           constant int &sceneLightCount [[buffer(BufferIndexLightCount)]]) {
    // Calculate the lighting based on the world position and normal using `applyLighting`
    float3 lighting = applyLighting(in, lights, sceneLightCount, uniforms);

    // Return the final color with full opacity
    return float4(lighting, 1.0);
}

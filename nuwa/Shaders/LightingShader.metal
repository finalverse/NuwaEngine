//
//  LightingShader.metal
//  NuwaEngine
//
//  This shader file implements lighting calculations for NuwaEngine.
//  It processes ambient and directional lights based on parameters from
//  `LightData` structures passed in through buffers. The lighting results
//  are then applied to the surface materials defined by the `Uniforms` struct.
//
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#include <simd/simd.h>
//#import "ShaderTypes.h"  // Ensure ShaderTypes.h defines LightData, Uniforms, etc.
#import "SharedShaders.metal"

using namespace metal;

/// Output structure for vertex data passed into the fragment shader.
struct VertexOut {
    float4 position [[position]];  // Vertex position in clip space
    float4 color;                  // Vertex color, potentially used as a base color
    float3 worldPosition;          // Position of the vertex in world space
    float3 normal;                 // Normal vector at the vertex, for lighting calculations
    float2 texCoord;               // Texture coordinates
};

/// Computes lighting for the given fragment by combining multiple lights
/// from the scene. It supports ambient and directional lighting.
///
/// - Parameters:
///   - in: VertexOut structure containing world position, normal, and other per-vertex data.
///   - lights: Array of light data structures (LightData) passed from the CPU, each containing
///             type, color, and direction for each light.
///   - sceneLightCount: The number of active lights in the scene, defining the array length.
///   - uniforms: Uniform data structure containing material properties and other scene information.
///
/// - Returns: The final color for the fragment after applying ambient and directional lighting effects.
float3 applyLighting(VertexOut in,
                     constant LightData *lights [[buffer(BufferIndexLights)]],
                     int sceneLightCount,
                     constant Uniforms &uniforms) {
    // Initialize the accumulated color as black to gather light contributions
    float3 accumulatedColor = float3(0.0);

    // Iterate over each light in the scene and apply its effect to the fragment
    for (int i = 0; i < sceneLightCount; i++) {
        LightData light = lights[i];
        float3 lightColor = light.color * light.intensity;  // Scale light color by its intensity

        // Apply ambient lighting uniformly across the surface
        if (light.type == LightTypeAmbient) {
            accumulatedColor += lightColor * uniforms.material.diffuseColor;

        // Apply directional lighting based on light direction and surface normal
        } else if (light.type == LightTypeDirectional) {
            // Calculate the normalized direction to the light source
            float3 lightDir = normalize(light.direction);
            
            // Compute the diffuse lighting factor by the angle between light and normal
            float diffuseFactor = max(dot(in.normal, lightDir), 0.0);
            
            // Accumulate the diffuse component of the lighting based on the material's diffuse color
            accumulatedColor += lightColor * uniforms.material.diffuseColor * diffuseFactor;
        }
    }
    
    // Return the final accumulated color after applying all lighting contributions
    return accumulatedColor;
}

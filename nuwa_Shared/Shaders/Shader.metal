//
//  Shader.metal
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//

// create: ----
//  - This shader provides a basic vertex and fragment setup that passes vertex color to the output.
// update: ----
//  - to include sceneLighting calculations. This will simulate basic Phong sceneLighting with ambient, diffuse, and specular components.
// update: ----
//  - SceneLighting Calculations: The fragment shader calculates ambient, diffuse, and specular sceneLighting based on the properties of each sceneLight.
//  - Uniforms: The Uniforms struct now includes an array of sceneLights and the camera’s position.
// update: ----
//  - Logic for SceneLight Types: We retained the logic for ambient, directional, and point sceneLights, using ambient for a simple intensity, while directional and point sceneLights apply both diffuse and specular sceneLighting calculations.
//  - Ambient SceneLighting: Directly adds ambient sceneLight to the color based on the intensity and color of the sceneLight.
//  - Diffuse and Specular Calculations: Calculated only for directional and point sceneLights. Diffuse sceneLighting is based on the angle between the surface normal and the sceneLight direction, while specular sceneLighting adds highsceneLights depending on the angle between the view direction and the reflection direction.
//
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float4 color [[attribute(1)]];
    float3 normal [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float3 worldPosition;
    float3 normal;
};

// SceneLight structure in Metal
struct NuwaLight {
    int type;
    float3 color;
    float intensity;
    float3 position;
    float3 direction;
};

// Uniforms Structure: We define Uniforms to hold the modelMatrix, which will be applied to each vertex.
// Uniform structure for per-frame data
struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewProjectionMatrix;
    float3 cameraPosition;
    NuwaLight sceneLights[3];  // fixed sized sceneLights array
    int sceneLightCount;
};

// Transformation Application: The vertex shader now multiplies each vertex’s position by the modelMatrix to transform it.

// Vertex shader:  - pass through the position and color of each vertex
//                 - apply transformation to position
vertex VertexOut vertex_main(VertexIn in [[stage_in]], constant Uniforms &uniforms [[buffer(1)]]) {
    VertexOut out;
    out.position = uniforms.viewProjectionMatrix * uniforms.modelMatrix * in.position;
    out.worldPosition = (uniforms.modelMatrix * in.position).xyz;
    out.normal = (uniforms.modelMatrix * float4(in.normal, 0.0)).xyz;
    out.color = in.color;
    return out;
}

// Calculate sceneLighting for each fragment based on dynamic sceneLights
float3 calculateLighting(VertexOut in, constant Uniforms &uniforms) {
    float3 color = float3(0.0);

    // Loop through sceneLights
    for (int i = 0; i < uniforms.sceneLightCount; i++) {
        NuwaLight sceneLight = uniforms.sceneLights[i];

        if (sceneLight.intensity <= 0.0) continue; // Skip if sceneLight has no intensity

        // Ambient sceneLighting
        if (sceneLight.type == 0) {
            color += sceneLight.color * sceneLight.intensity;
        }

        // Diffuse and specular sceneLighting for directional and point sceneLights
        else {
            float3 sceneLightDir;
            if (sceneLight.type == 1) {
                // Directional sceneLight
                sceneLightDir = normalize(sceneLight.direction);
            } else {
                // Point sceneLight
                sceneLightDir = normalize(sceneLight.position - in.worldPosition);
            }

            // Diffuse component
            float diffuseFactor = max(dot(in.normal, sceneLightDir), 0.0);
            color += sceneLight.color * sceneLight.intensity * diffuseFactor;

            // Specular component
            float3 viewDir = normalize(uniforms.cameraPosition - in.worldPosition);
            float3 reflectDir = reflect(-sceneLightDir, in.normal);
            float specularFactor = pow(max(dot(viewDir, reflectDir), 0.0), 32.0); // 32 is shininess
            color += sceneLight.color * sceneLight.intensity * specularFactor;
        }
    }
    return color;
}

// Fragment shader: output the color passed from the vertex shader.
fragment float4 fragment_main(VertexOut in [[stage_in]], constant Uniforms &uniforms [[buffer(1)]]) {
    float3 sceneLighting = calculateLighting(in, uniforms);
    return float4(sceneLighting, 1.0) * in.color;
}


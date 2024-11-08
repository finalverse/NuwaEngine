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

/*
 fragment float4 fragment_main(VertexOut in [[stage_in]],
 constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
 constant SceneLight *lights [[buffer(BufferIndexLights)]],
 constant int &lightCount [[buffer(BufferIndexLightCount)]],
 texture2d<float> colorMap [[texture(TextureIndexColor)]]) {
 
 constexpr sampler textureSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);
 float4 baseColor = colorMap.sample(textureSampler, in.texCoord) * in.color;
 
 // Initialize final color with the diffuse color from the material
 float3 finalColor = uniforms.material.diffuseColor;
 
 // Ambient Lighting
 float3 ambientLight = float3(0.0);
 for (int i = 0; i < lightCount; ++i) {
 if (lights[i].type == LightTypeAmbient) {
 ambientLight += lights[i].color * lights[i].intensity;
 }
 }
 finalColor += ambientLight * baseColor.rgb;
 
 // Directional and Point Lighting
 for (int i = 0; i < lightCount; ++i) {
 if (lights[i].type == LightTypeDirectional) {
 float3 lightDir = normalize(-lights[i].direction);
 float diff = max(dot(in.normal, lightDir), 0.0);
 finalColor += diff * lights[i].color * lights[i].intensity;
 }
 if (lights[i].type == LightTypePoint) {
 float3 lightDir = normalize(lights[i].position - in.worldPosition);
 float diff = max(dot(in.normal, lightDir), 0.0);
 float distance = length(lights[i].position - in.worldPosition);
 float attenuation = 1.0 / (distance * distance);
 finalColor += diff * lights[i].color * lights[i].intensity * attenuation;
 }
 }
 
 return float4(finalColor, 1.0);
 }
 */

/*
fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                              texture2d<float> colorMap [[texture(TextureIndexColor)]]) {
    
    // Define a basic lighting factor
    float lightingFactor = 0.8;

    // Apply vertex color with a lighting factor, ignoring the texture for now
    float3 color = in.color.rgb * lightingFactor;
    
    // Return final color, forcing alpha to 1.0
    return float4(color, 1.0);
}
*/

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                              constant SceneLight *lights [[buffer(BufferIndexLights)]],
                              constant int &lightCount [[buffer(BufferIndexLightCount)]],
                              texture2d<float> colorMap [[texture(TextureIndexColor)]]) {

    // Base color from vertex color
    float3 baseColor = in.color.rgb;

    // Ambient lighting factor (simple multiplier for base brightness)
    float ambientStrength = 0.2;
    float3 ambient = ambientStrength * baseColor;

    // Initialize diffuse and specular components
    float3 diffuse = float3(0.0);
    float3 specular = float3(0.0);

    // Loop through lights and apply directional lighting
    for (int i = 0; i < lightCount; i++) {
        if (lights[i].type == LightTypeDirectional) {
            // Calculate the diffuse component
            float3 lightDir = normalize(lights[i].direction);
            float diff = max(dot(in.normal, lightDir), 0.0);
            diffuse += diff * lights[i].color * lights[i].intensity;
            
            // (Optional) Specular component for shininess
            float3 viewDir = normalize(uniforms.cameraPosition - in.worldPosition);
            float3 reflectDir = reflect(-lightDir, in.normal);
            float spec = pow(max(dot(viewDir, reflectDir), 0.0), uniforms.material.shininess);
            specular += spec * lights[i].color * lights[i].intensity;
        }
    }

    // Final color combines ambient, diffuse, and specular
    float3 finalColor = ambient + diffuse + specular;
    return float4(finalColor, 1.0);
}

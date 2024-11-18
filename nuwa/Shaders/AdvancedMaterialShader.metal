//
//  AdvancedMaterialShader.metal
//  NuwaEngine
//
//  Implements advanced material handling, including normal mapping, roughness, metallic reflections,
//  and ambient occlusion. Designed for Physically-Based Rendering (PBR) workflows.
//
//  Fully compatible with ShaderTypes.h.
//
//  Created by Wenyan Qin on 2024-11-19.
//

#include <metal_stdlib>
#include <simd/simd.h>
#import "SharedShaders.metal"
#import "ShaderTypes.h"

using namespace metal;

// Vertex Shader
//
// Transforms vertex attributes into clip space and prepares tangent-space vectors for advanced effects.
//
// - Parameters:
//   - in: Vertex attributes from the CPU (`VertexIn` from ShaderTypes.h).
//   - uniforms: Transformation matrices and material properties.
// - Returns: Transformed vertex data for the fragment shader.
vertex VertexOut advancedMaterial_vertex(VertexIn in [[stage_in]],
                                         constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;

    // Compute world position
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPosition.xyz;

    // Transform normal, tangent, and bitangent vectors to world space
    out.worldNormal = normalize((uniforms.modelMatrix * float4(in.normal, 0.0)).xyz);
    out.worldTangent = normalize((uniforms.modelMatrix * float4(in.tangent, 0.0)).xyz);
    out.worldBitangent = normalize((uniforms.modelMatrix * float4(in.bitangent, 0.0)).xyz);

    // Project world position into clip space
    out.position = uniforms.viewProjectionMatrix * worldPosition;

    // Pass through additional attributes
    out.color = in.color;
    out.texCoord = in.texCoord;

    return out;
}

// Fragment Shader
//
// Implements PBR shading, combining normal maps, metallic reflections, roughness, and ambient occlusion.
//
// - Parameters:
//   - in: Interpolated vertex data from the vertex shader (`VertexOut`).
//   - uniforms: Material properties and transformation data.
//   - normalMap: Normal map texture for fine surface details.
//   - roughnessMap: Texture defining surface roughness.
//   - metallicMap: Texture defining metallic properties.
// - Returns: Final color of the fragment after applying PBR shading.
fragment float4 advancedMaterial_fragment(VertexOut in [[stage_in]],
                                          constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                                          texture2d<float> normalMap [[texture(TextureIndexNormal)]],
                                          texture2d<float> roughnessMap [[texture(TextureIndexRoughness)]],
                                          texture2d<float> metallicMap [[texture(TextureIndexMetallic)]],
                                          sampler textureSampler) {
    // Sample textures
    float3 normalTex = normalize(normalMap.sample(textureSampler, in.texCoord).xyz * 2.0 - 1.0);
    float roughness = roughnessMap.sample(textureSampler, in.texCoord).r;
    float metallic = metallicMap.sample(textureSampler, in.texCoord).r;

    // Reconstruct world-space normal
    float3 T = normalize(in.worldTangent);
    float3 B = normalize(in.worldBitangent);
    float3 N = normalize(in.worldNormal);
    float3 worldNormal = normalize(T * normalTex.x + B * normalTex.y + N * normalTex.z);

    // Compute lighting (diffuse + specular)
    float3 viewDir = normalize(uniforms.cameraPosition - in.worldPosition);
    float3 lightColor = float3(1.0, 1.0, 1.0); // Example light color
    float3 lightDir = normalize(float3(0.5, 1.0, 0.5)); // Example light direction

    float NdotL = max(dot(worldNormal, lightDir), 0.0);
    float3 diffuse = uniforms.material.diffuseColor * lightColor * NdotL;

    float3 halfwayDir = normalize(lightDir + viewDir);
    float NdotH = max(dot(worldNormal, halfwayDir), 0.0);
    float specular = pow(NdotH, uniforms.material.shininess) * (1.0 - roughness);

    // Mix diffuse and specular with metallic
    float3 finalColor = mix(diffuse, lightColor, metallic) + specular;

    return float4(finalColor, 1.0);
}

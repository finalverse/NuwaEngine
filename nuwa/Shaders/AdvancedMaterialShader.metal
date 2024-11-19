//
//  AdvancedMaterialShader.metal
//  NuwaEngine
//
//  Implements advanced material handling, including normal mapping, roughness, metallic reflections,
//  and ambient occlusion. Designed for Physically-Based Rendering (PBR) workflows.
//
//  Fully compatible with ShaderTypes.h and ShaderMaterial.
//  Created by Wenyan Qin on 2024-11-19.
//

#include <metal_stdlib>
#import "SharedShaders.metal"
using namespace metal;

// Vertex Shader: Prepares world and tangent space data.
vertex VertexOut advancedMaterial_vertex(VertexIn in [[stage_in]],
                                         constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;

    // Transform position to world and clip space
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPosition.xyz;
    out.position = uniforms.viewProjectionMatrix * worldPosition;

    // Transform normals and tangents
    out.worldNormal = normalize((uniforms.modelMatrix * float4(in.normal, 0.0)).xyz);
    out.worldTangent = normalize((uniforms.modelMatrix * float4(in.tangent, 0.0)).xyz);
    out.worldBitangent = normalize((uniforms.modelMatrix * float4(in.bitangent, 0.0)).xyz);

    // Pass through attributes
    out.color = in.color;
    out.texCoord = in.texCoord;

    return out;
}

// Fragment Shader: Implements PBR shading using advanced material properties.
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

    // Transform normal to world space
    float3 T = normalize(in.worldTangent);
    float3 B = normalize(in.worldBitangent);
    float3 N = normalize(in.worldNormal);
    float3 worldNormal = normalize(T * normalTex.x + B * normalTex.y + N * normalTex.z);

    // Compute lighting
    float3 lightDir = normalize(float3(0.5, 1.0, 0.5));
    float3 viewDir = normalize(uniforms.cameraPosition - in.worldPosition);

    // Diffuse
    float NdotL = max(dot(worldNormal, lightDir), 0.0);
    float3 diffuse = uniforms.material.diffuseColor * NdotL;

    // Specular (PBR-style)
    float3 halfwayDir = normalize(lightDir + viewDir);
    float NdotH = max(dot(worldNormal, halfwayDir), 0.0);
    float specular = pow(NdotH, uniforms.material.shininess) * (1.0 - roughness);

    // Final color
    float3 finalColor = mix(diffuse, specular, metallic);

    return float4(finalColor, 1.0);
}

//
//  BasicLightingShader.metal
//  NuwaEngine
//
//  Implements Phong lighting with ambient, diffuse, and specular components for multiple light sources.
//
//  Updated to align with ShaderTypes.h.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "SharedShaders.metal"
using namespace metal;

// Vertex Shader: Transforms vertex attributes and passes interpolated attributes to the fragment shader.
vertex VertexOut basicLighting_vertex(VertexIn in [[stage_in]],
                                      constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]]) {
    VertexOut out;
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPosition.xyz;
    out.worldNormal = normalize((uniforms.modelMatrix * float4(in.normal, 0.0)).xyz);
    out.position = uniforms.viewProjectionMatrix * worldPosition;
    out.color = in.color;
    out.texCoord = in.texCoord;
    return out;
}

// Fragment Shader: Combines ambient, diffuse, and specular lighting.
fragment float4 basicLighting_fragment(VertexOut in [[stage_in]],
                                       constant LightData *lights [[buffer(BufferIndexLights)]],
                                       constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
                                       constant int &lightCount [[buffer(BufferIndexLightCount)]]) {
    float3 color = uniforms.material.diffuseColor;
    float3 ambient = float3(0.0), diffuse = float3(0.0), specular = float3(0.0);

    for (int i = 0; i < lightCount; ++i) {
        LightData light = lights[i];
        float3 lightColor = light.color * light.intensity;

        if (light.type == LightTypeAmbient) {
            ambient += lightColor * color;
        } else if (light.type == LightTypeDirectional) {
            float3 lightDir = normalize(light.direction);
            diffuse += max(dot(in.worldNormal, lightDir), 0.0) * lightColor * color;
            float3 viewDir = normalize(uniforms.cameraPosition - in.worldPosition);
            float3 halfwayDir = normalize(lightDir + viewDir);
            specular += pow(max(dot(in.worldNormal, halfwayDir), 0.0), uniforms.material.shininess) * lightColor;
        }
    }

    return float4(ambient + diffuse + specular, 1.0);
}

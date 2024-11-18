//
//  SharedShaders.metal
//  NuwaEngine
//
//  Contains reusable logic and utility functions for all shaders.
//
//  Updated to align with ShaderTypes.h.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

// Computes world-space normal from transformed attributes.
float3 computeWorldNormal(float4x4 modelMatrix, float3 normal) {
    return normalize((modelMatrix * float4(normal, 0.0)).xyz);
}

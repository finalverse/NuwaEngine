//
//  SharedShaders.metal
//  NuwaEngine
//
//  Contains reusable logic and utility functions for all shaders.
//  These functions are shared across multiple shader stages and modules.
//
//  Fully compatible with ShaderTypes.h.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
#import "ShaderTypes.h"
using namespace metal;

// Computes world-space normal from transformed attributes.
//
// - Parameters:
//   - modelMatrix: The transformation matrix from object space to world space.
//   - normal: The normal vector in object space.
// - Returns: The normalized world-space normal vector.
float3 computeWorldNormal(float4x4 modelMatrix, float3 normal) {
    return normalize((modelMatrix * float4(normal, 0.0)).xyz); // Transform and normalize
}

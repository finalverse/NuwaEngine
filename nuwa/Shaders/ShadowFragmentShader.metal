//
//  ShadowFragmentShader.metal
//  NuwaEngine
//
//  Outputs depth information for shadow mapping.
//
//  Updated to align with ShaderTypes.h.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
using namespace metal;

// Fragment Shader
//
// Outputs depth value for shadow map.
//
// - Parameters:
//   - in: Fragment data from the vertex shader.
// - Returns: The depth of the fragment for shadow calculations.
fragment float4 shadow_fragment(float4 position [[position]]) {
    return float4(position.z, position.z, position.z, 1.0);  // Depth encoding
}

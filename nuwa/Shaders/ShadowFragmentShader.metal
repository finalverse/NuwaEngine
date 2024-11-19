//
//  ShadowFragmentShader.metal
//  NuwaEngine
//
//  Outputs depth information for shadow mapping. Designed to store the fragment depth
//  into the shadow map texture for later comparison.
//
//  Fully compatible with ShaderTypes.h.
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
using namespace metal;

// Fragment Shader
//
// Outputs depth value for shadow map.
//
// - Parameters:
//   - position: The fragment's position in clip space.
// - Returns: The depth of the fragment for shadow calculations.
fragment float4 shadow_fragment(float4 position [[position]]) {
    return float4(position.z, position.z, position.z, 1.0); // Encode depth
}

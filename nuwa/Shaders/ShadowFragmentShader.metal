//
//  ShadowFragmentShader.metal
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-12.
//

#include <metal_stdlib>
using namespace metal;

// Define a compatible structure for fragment shader input
struct FragmentInput {
    float4 shadowPosition [[position]]; // Position passed from the vertex shader
};

// Corrected shadow fragment shader
fragment float4 shadowFragmentShader(FragmentInput in [[stage_in]], constant float &shadowIntensity [[buffer(0)]]) {
    // Calculate shadow factor based on shadowPosition depth and shadowIntensity
    float shadowFactor = in.shadowPosition.z < 0.5 ? shadowIntensity : 1.0;
    return float4(shadowFactor, shadowFactor, shadowFactor, 1.0);
}

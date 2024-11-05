//
//  Shader.metal
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//

// Shader.metal
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

// Uniforms Structure: We define Uniforms to hold the modelMatrix, which will be applied to each vertex.
struct Uniforms {
    float4x4 modelMatrix;
};

// Transformation Application: The vertex shader now multiplies each vertex’s position by the modelMatrix to transform it.

// Vertex shader:  - pass through the position and color of each vertex
//                 - apply transformation to position
vertex VertexOut vertex_main(VertexIn in [[stage_in]], constant Uniforms &uniforms [[buffer(1)]]) {
    VertexOut out;
    //out.position = in.position;
    out.position = uniforms.modelMatrix * in.position;  // Apply transformation
    out.color = in.color;
    return out;
}

// Fragment shader: output the color passed from the vertex shader.
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}


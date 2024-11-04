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

// Vertex shader: pass through the position and color of each vertex.
vertex VertexOut vertex_main(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = in.position;
    out.color = in.color;
    return out;
}

// Fragment shader: output the color passed from the vertex shader.
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}


//
//  ShaderTypes.h
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h


#include <simd/simd.h>

// Structure representing the vertex data to pass to the vertex shader
typedef struct {
    vector_float4 position;
    vector_float4 color;
} Vertex;

#endif /* ShaderTypes_h */

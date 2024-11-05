//
//  ShaderTypes.h
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//

// -- update
//  - SceneLight Pointer: SceneLight *sceneLights allows sceneLights to reference dynamically allocated memory.
//  - SceneLight Count: sceneLightCount keeps track of the number of sceneLights.


#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

// Structure representing the vertex data to pass to the vertex shader
typedef struct {
    vector_float4 position;
    vector_float4 color;
    vector_float3 normal; // Add normal for sceneLighting calculations
} Vertex;

// SceneLight structure in C (matching the Metal sceneLight structure)
// Name it NuwaLight to avoid naming conflic with Metal SceneLight
typedef struct {
    int type;                // 0 = ambient, 1 = directional, 2 = point
    vector_float3 color;
    float intensity;
    vector_float3 position;
    vector_float3 direction;
} NuwaLight;                // avoid naming conflict from Objective-C SceneLight

// Structure to hold per-entity transformation and sceneLighting data
typedef struct {
    matrix_float4x4 modelMatrix;    // Transformation matrix for the entity
    matrix_float4x4 viewProjectionMatrix;
    vector_float3 cameraPosition;
    NuwaLight sceneLights[3];       // fixed size array of sceneLights
    int sceneLightCount;
} Uniforms;

#endif /* ShaderTypes_h */

//
//  ShaderTypes.h
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  ShaderTypes defines shared data structures between Swift and Metal shaders.
//  Structures for vertices, lights, materials, and uniforms are mirrored here to ensure compatibility.

#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
typedef metal::int32_t EnumBackingType;
#else
#import <Foundation/Foundation.h>
typedef NSInteger EnumBackingType;
#endif

#include <simd/simd.h>

typedef NS_ENUM(EnumBackingType, BufferIndex) {
    BufferIndexMeshPositions = 0,
    BufferIndexMeshGenerics  = 1,
    BufferIndexUniforms      = 2
};

typedef NS_ENUM(EnumBackingType, VertexAttribute) {
    VertexAttributePosition  = 0,
    VertexAttributeColor     = 1,
    VertexAttributeNormal    = 2,
    VertexAttributeTexcoord  = 3
};

typedef NS_ENUM(EnumBackingType, TextureIndex) {
    TextureIndexColor    = 0
};

// Structure representing a vertex with position, color, normal, and texture coordinates
typedef struct {
    vector_float4 position;      // Vertex position in 3D space, using homogeneous coordinates
    vector_float4 color;         // Vertex color
    vector_float3 normal;        // Normal vector for lighting calculations
    vector_float2 texCoord;      // Texture coordinates for sampling
} Vertex;

typedef struct {
    int type;                   // 0 = ambient, 1 = directional, 2 = point
    vector_float3 color;        // Light color
    float intensity;            // Light intensity
    vector_float3 position;     // Position for point lights
    vector_float3 direction;    // Direction for directional lights
} SceneLight;

// Material structure for holding material properties within the shader
typedef struct {
    vector_float3 diffuseColor;
    vector_float3 specularColor;
    float shininess;
    uint8_t hasTexture; // Indicate if a texture is present
} Material;

// Uniforms structure for passing transformation and lighting data to shaders
typedef struct {
    matrix_float4x4 modelMatrix;          // Model transformation matrix
    matrix_float4x4 viewProjectionMatrix; // Combined view and projection matrix
    vector_float3 cameraPosition;         // Position of the camera in world space
    Material material;                    // Material properties for the entity
} Uniforms;

#endif /* ShaderTypes_h */

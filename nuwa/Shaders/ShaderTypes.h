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
    BufferIndexMeshPositions = 0,       // Ensure vertex        uses index 0
    BufferIndexMeshGenerics  = 1,
    BufferIndexUniforms      = 2,       // Ensure uninforms     uses index 2
    BufferIndexLights        = 3,       // Ensure lights        uses index 3
    BufferIndexLightCount    = 4        // Ensure light count   uses index 4
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

typedef NS_ENUM(EnumBackingType, LightType) {
    LightTypeAmbient      = 0,
    LightTypeDirectional  = 1,
    LightTypePoint        = 2
};

// Structure representing a vertex with position, color, normal, and texture coordinates
typedef struct {
    vector_float4 position;      // Vertex position in 3D space, using homogeneous coordinates
    vector_float4 color;         // Vertex color
    vector_float3 normal;        // Normal vector for lighting calculations
    vector_float2 texCoord;      // Texture coordinates for sampling
} Vertex;

typedef struct {
    int type;                       //  4 bytes: 0 = ambient, 1 = directional, 2 = point
    vector_float3 color;            // 12 bytes: Light color
    float intensity;                //  4 bytes: Light intensity
    vector_float3 position;         // 12 bytes: Position for point lights
    float padding1;                 //  4 bytes: Padding for alignment
    vector_float3 direction;        // 12 bytes: Direction for directional lights
    float padding2;                 //  4 bytes: Padding for alignment to 16 bytes
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
    float padding;                        // Padding for 16-byte alignment
    Material material;                    // Material properties for the entity
} Uniforms;

#endif /* ShaderTypes_h */

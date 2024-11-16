//
//  ShaderTypes.h
//  NuwaEngine
//
//  This file defines shared data structures and enums for Swift and Metal shaders.
//  Ensures efficient GPU processing by maintaining alignment compatibility between Metal shaders and Swift code.
//
//  Created by Wenyan Qin on 2024-11-05.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

/// Buffer indices used in Metal shaders to access various data buffers
enum BufferIndex : int {
    BufferIndexMeshPositions = 0,   // Vertex buffer containing mesh positions
    BufferIndexUniforms      = 2,   // Buffer for transformation matrices and material data
    BufferIndexLights        = 3,   // Buffer storing light information for scene lighting
    BufferIndexLightCount    = 4    // Buffer storing the count of lights in the scene
};

/// Vertex attributes specify the layout of vertex data in shaders
enum VertexAttribute : int {
    VertexAttributePosition  = 0,   // Position of the vertex in 3D space
    VertexAttributeColor     = 1,   // Vertex color for per-vertex color effects
    VertexAttributeNormal    = 2,   // Normal vector for lighting calculations
    VertexAttributeTexcoord  = 3    // Texture coordinates for UV mapping
};

/// Texture indices for binding textures in Metal shaders
enum TextureIndex : int {
    TextureIndexColor = 0           // Color texture for basic surface rendering
};

/// Enum defining types of lights used in the scene
enum LightType : int {
    LightTypeAmbient     = 0,       // Ambient light illuminates all objects equally
    LightTypeDirectional = 1,       // Directional light simulates distant light sources like the sun
    LightTypePoint       = 2        // Point light simulates localized sources like light bulbs
};

/// Structure representing light data, compatible with both Swift and Metal
struct LightData {
    int type;                        // Type of light (ambient, directional, or point)
    vector_float3 color;             // RGB color of the light
    float intensity;                 // Intensity multiplier for the light
    vector_float3 position;          // Position for point lights
    float padding1;                  // Padding for 16-byte alignment
    vector_float3 direction;         // Direction vector for directional lights
    float padding2;                  // Padding for 16-byte alignment
};

/// Vertex structure for compatibility between Swift and Metal, containing essential vertex attributes
struct Vertex {
    vector_float4 position;          // Homogeneous 3D position of the vertex
    vector_float4 color;             // RGBA color of the vertex
    vector_float3 normal;            // Normal vector for lighting calculations
    vector_float2 texCoord;          // Texture coordinates for UV mapping
};

/// Vertex input structure specifically for Metal shaders, with attribute bindings for efficient processing
struct VertexIn {
    vector_float3 position [[attribute(VertexAttributePosition)]];  // Vertex position
    vector_float4 color [[attribute(VertexAttributeColor)]];        // Vertex color
    vector_float3 normal [[attribute(VertexAttributeNormal)]];      // Normal for lighting
    vector_float2 texCoord [[attribute(VertexAttributeTexcoord)]];  // Texture coordinates
};

/// Material properties structure for shaders, containing basic material characteristics
struct Material {
    vector_float3 diffuseColor;      // Base color of the material
    vector_float3 specularColor;     // Specular highlight color
    float shininess;                 // Shininess factor for specular reflections
    int hasTexture;                  // Flag indicating if a texture is applied (1 = true, 0 = false)
};

/// Uniform structure containing transformation matrices, camera data, and material properties for each entity
struct Uniforms {
    matrix_float4x4 modelMatrix;         // Local-to-world transformation matrix
    matrix_float4x4 viewProjectionMatrix; // Combined view-projection matrix
    vector_float3 cameraPosition;        // Camera position in world space for lighting calculations
    float padding;                       // Padding for alignment
    struct Material material;            // Material properties for rendering the entity
};

#endif /* ShaderTypes_h */

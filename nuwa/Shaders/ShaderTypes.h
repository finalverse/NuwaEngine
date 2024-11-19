//
//  ShaderTypes.h
//  NuwaEngine
//
//  This file defines shared data structures and enums for Swift and Metal shaders.
//  Ensures efficient GPU processing by maintaining alignment compatibility between Metal shaders and Swift code.
//
//  Created by Wenyan Qin on 2024-11-05.
//  Updated on 2024-11-19.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

/// Buffer indices used in Metal shaders to access various data buffers
enum BufferIndex : int {
    BufferIndexMeshPositions = 0,   // Vertex buffer containing mesh positions
    BufferIndexUniforms      = 2,   // Buffer for transformation matrices and material data
    BufferIndexLights        = 3,   // Buffer storing light information for scene lighting
    BufferIndexLightCount    = 4,   // Buffer storing the count of lights in the scene
    BufferIndexInstances     = 5    // Buffer for instance-specific transformations (optional for instancing)
};

/// Vertex attributes specify the layout of vertex data in shaders
enum VertexAttribute : int {
    VertexAttributePosition  = 0,   // Position of the vertex in 3D space
    VertexAttributeColor     = 1,   // Vertex color for per-vertex color effects
    VertexAttributeNormal    = 2,   // Normal vector for lighting calculations
    VertexAttributeTexcoord  = 3,   // Texture coordinates for UV mapping
    VertexAttributeTangent   = 4,   // Tangent vector for normal mapping
    VertexAttributeBitangent = 5    // Bitangent vector for normal mapping
};

/// Texture indices for binding textures in Metal shaders
enum TextureIndex : int {
    TextureIndexColor = 0,           // Base color texture
    TextureIndexNormal = 1,          // Normal map texture
    TextureIndexRoughness = 2,       // Roughness texture
    TextureIndexMetallic = 3         // Metallic texture
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
    vector_float3 tangent;           // Tangent vector for normal mapping
    vector_float3 bitangent;         // Bitangent vector for normal mapping
    unsigned int instanceID;         // Instance ID for instanced rendering (optional)
};

/// Vertex input structure specifically for Metal shaders, with attribute bindings for efficient processing
struct VertexIn {
    vector_float3 position [[attribute(VertexAttributePosition)]];  // Vertex position
    vector_float4 color [[attribute(VertexAttributeColor)]];        // Vertex color
    vector_float3 normal [[attribute(VertexAttributeNormal)]];      // Normal for lighting
    vector_float2 texCoord [[attribute(VertexAttributeTexcoord)]];  // Texture coordinates
    vector_float3 tangent [[attribute(VertexAttributeTangent)]];    // Tangent for normal mapping
    vector_float3 bitangent [[attribute(VertexAttributeBitangent)]];// Bitangent for normal mapping
};

/// Vertex output structure for Metal shaders, containing transformed attributes for the fragment shader
struct VertexOut {
    vector_float4 position [[position]];  // Transformed vertex position in clip space
    vector_float4 color;                  // Interpolated vertex color
    vector_float3 worldPosition;          // Vertex position in world space
    vector_float3 worldNormal;            // Normal vector in world space
    vector_float2 texCoord;               // Interpolated texture coordinates
    vector_float3 worldTangent;           // Tangent vector in world space
    vector_float3 worldBitangent;         // Bitangent vector in world space
};

/// Material properties structure for shaders, containing enhanced material characteristics.
/// This structure is used to pass material properties from Swift to Metal shaders.
///
/// Notes:
/// - This struct includes fields for diffuse color, specular highlights, and advanced
///   material properties such as roughness and metallicity.
/// - The `hasTexture` field is used to indicate whether a texture is applied.
struct ShaderMaterial {
    vector_float3 diffuseColor;      // Base color of the material
    vector_float3 specularColor;     // Specular highlight color
    float shininess;                 // Shininess factor for specular reflections
    float roughness;                 // Surface roughness (0 = smooth, 1 = rough)
    float metallic;                  // Degree of metallicity (0 = non-metal, 1 = metal)
    vector_float3 emissiveColor;     // Color emitted by the material (for glowing effects)
    float reflectivity;              // Reflectivity factor (0 = no reflection, 1 = full reflection)
    int hasTexture;                  // Flag indicating if a texture is applied (1 = true, 0 = false)
};

/// Uniform structure containing transformation matrices, camera data, and material properties for each entity
struct Uniforms {
    matrix_float4x4 modelMatrix;         // Local-to-world transformation matrix
    matrix_float4x4 viewProjectionMatrix; // Combined view-projection matrix
    vector_float3 cameraPosition;        // Camera position in world space for lighting calculations
    float padding;                       // Padding for alignment
    struct ShaderMaterial material;      // Enhanced material properties for rendering the entity
};

#endif /* ShaderTypes_h */

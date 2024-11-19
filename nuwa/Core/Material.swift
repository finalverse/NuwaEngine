//
//  Material.swift
//  NuwaEngine
//
//  The `Material` class represents visual properties of a surface, such as color, shininess, roughness, metallicity, and optional texture.
//  It integrates directly with the rendering pipeline and provides methods for dynamic property adjustment.
//
//  Updated on 2024-11-19.
//

import Foundation
import Metal
import MetalKit

// MARK: - Shader-Compatible MaterialProperties Struct

/// A struct representing material properties in a format compatible with shaders.
struct MaterialProperties {
    var diffuseColor: SIMD3<Float>
    var specularColor: SIMD3<Float>
    var shininess: Float
    var roughness: Float
    var metallic: Float
    var emissiveColor: SIMD3<Float>
    var reflectivity: Float
    var hasTexture: Int32
}

// MARK: - Material Class

/// Represents visual properties of a surface, including dynamic shader property binding.
class Material {
    // MARK: - Properties
    
    var diffuseColor: SIMD3<Float>         // Base color of the material
    var specularColor: SIMD3<Float>        // Specular reflection color
    var shininess: Float                   // Shininess factor for specular highlights
    var roughness: Float = 0.5             // Roughness of the material surface
    var metallic: Float = 0.0              // Metallic property of the material
    var emissiveColor: SIMD3<Float> = .zero // Emissive color for glowing effects
    var reflectivity: Float = 0.0          // Reflectivity for mirror-like surfaces
    var hasTexture: Bool                   // Indicates if this material uses a texture
    var texture: MTLTexture?               // Optional base color texture
    var normalMap: MTLTexture?             // Optional normal map texture
    var roughnessMap: MTLTexture?          // Optional roughness map texture
    var metallicMap: MTLTexture?           // Optional metallic map texture

    // MARK: - Initialization

    /// Initializes a `Material` instance with color and optional textures.
    /// - Parameters:
    ///   - diffuseColor: The base color of the material.
    ///   - specularColor: The specular color for reflections.
    ///   - shininess: Shininess factor for specular highlights.
    ///   - hasTexture: Flag indicating if a base color texture is used.
    ///   - device: The Metal device used for creating textures.
    ///   - textureNames: Optional dictionary of texture names (e.g., baseColor, normalMap, etc.).
    init(diffuseColor: SIMD3<Float>,
         specularColor: SIMD3<Float>,
         shininess: Float,
         hasTexture: Bool,
         device: MTLDevice,
         textureNames: [String: String]? = nil) {
        self.diffuseColor = diffuseColor
        self.specularColor = specularColor
        self.shininess = shininess
        self.hasTexture = hasTexture

        // Load textures if provided
        if let textureNames = textureNames {
            self.texture = hasTexture ? loadTexture(device: device, textureName: textureNames["baseColor"]) : nil
            self.normalMap = loadTexture(device: device, textureName: textureNames["normalMap"])
            self.roughnessMap = loadTexture(device: device, textureName: textureNames["roughnessMap"])
            self.metallicMap = loadTexture(device: device, textureName: textureNames["metallicMap"])
        }
    }

    // MARK: - Texture Management

    /// Loads a texture from the specified file in the `Assets/Textures` folder.
    /// - Parameters:
    ///   - device: The Metal device used to create the texture.
    ///   - textureName: The name of the texture file (without file extension).
    /// - Returns: An optional `MTLTexture` if loading is successful.
    private func loadTexture(device: MTLDevice, textureName: String?) -> MTLTexture? {
        guard let name = textureName,
              let textureURL = Bundle.main.url(forResource: "Assets/Textures/\(name)", withExtension: "png") else {
            print("Warning: Texture \(textureName ?? "nil") not found.")
            return nil
        }

        let textureLoader = MTKTextureLoader(device: device)
        let options: [MTKTextureLoader.Option: Any] = [
            .SRGB: false,
            .origin: MTKTextureLoader.Origin.bottomLeft,
            .generateMipmaps: NSNumber(value: true)
        ]

        do {
            let texture = try textureLoader.newTexture(URL: textureURL, options: options)
            print("Texture \(name) loaded successfully.")
            return texture
        } catch {
            print("Error loading texture \(name): \(error)")
            return nil
        }
    }

    // MARK: - Shader Compatibility

    /// Converts the `Material` class instance into a shader-compatible structure.
    /// - Returns: A `MaterialProperties` struct compatible with `ShaderTypes.h`.
    
    func toShaderMaterial() -> ShaderMaterial {
        return ShaderMaterial(
            diffuseColor: diffuseColor,
            specularColor: specularColor,
            shininess: shininess,
            roughness: roughness,
            metallic: metallic,
            emissiveColor: emissiveColor,
            reflectivity: reflectivity,
            hasTexture: hasTexture ? 1 : 0
        )
    }

    // MARK: - Binding to Shader

    /// Binds material properties and textures to the fragment shader.
    /// - Parameter renderEncoder: The Metal render command encoder used to issue drawing commands.
    func bindToShader(renderEncoder: MTLRenderCommandEncoder) {
        // Populate the shader-compatible Material struct
        var shaderMaterial = toShaderMaterial()

        // Bind the material properties to the fragment shader
        renderEncoder.setFragmentBytes(&shaderMaterial, length: MemoryLayout<Material>.stride, index: 1)

        // Bind textures
        if let texture = texture {
            renderEncoder.setFragmentTexture(texture, index: Int(TextureIndexColor.rawValue))
        }
        if let normalMap = normalMap {
            renderEncoder.setFragmentTexture(normalMap, index: Int(TextureIndexNormal.rawValue))
        }
        if let roughnessMap = roughnessMap {
            renderEncoder.setFragmentTexture(roughnessMap, index: Int(TextureIndexRoughness.rawValue))
        }
        if let metallicMap = metallicMap {
            renderEncoder.setFragmentTexture(metallicMap, index: Int(TextureIndexMetallic.rawValue))
        }
    }
}

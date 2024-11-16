//
//  Material.swift
//  NuwaEngine
//
//  The `Material` class represents visual properties of a surface, such as color, shininess, and optional texture.
//  It includes methods for dynamically adjusting roughness and metallic properties.
//
//  Created by Wenyan Qin on 2024-11-09.
//

import Foundation
import Metal
import MetalKit

class Material {
    var diffuseColor: SIMD3<Float>         // Base color of the material
    var specularColor: SIMD3<Float>        // Specular reflection color
    var shininess: Float                   // Shininess factor for specular highlights
    var roughness: Float = 0.5             // Roughness of the material surface
    var metallic: Float = 0.0              // Metallic property of the material
    var emissiveColor: SIMD3<Float> = .zero // Emissive color for glowing effects
    var reflectivity: Float = 0.0          // Reflectivity for mirror-like surfaces
    var hasTexture: Bool                   // Indicates if this material uses a texture
    var texture: MTLTexture?               // Optional texture for the material

    /// Initializes a Material instance with color and optional texture.
    /// - Parameters:
    ///   - diffuseColor: The base color of the material.
    ///   - specularColor: The specular color for reflections.
    ///   - shininess: Shininess factor for specular highlights.
    ///   - hasTexture: Flag indicating if a texture is used.
    ///   - device: The Metal device used for creating the texture.
    ///   - textureName: The name of the texture file in the Assets/Textures directory (optional).
    init(diffuseColor: SIMD3<Float>,
         specularColor: SIMD3<Float>,
         shininess: Float,
         hasTexture: Bool,
         device: MTLDevice,
         textureName: String? = nil) {
        self.diffuseColor = diffuseColor
        self.specularColor = specularColor
        self.shininess = shininess
        self.hasTexture = hasTexture

        // Load texture if textureName is provided and hasTexture is true
        if let name = textureName, hasTexture {
            self.texture = loadTexture(device: device, textureName: name)
        }
    }

    /// Loads a texture from the specified file in the `Assets/Textures` folder.
    /// - Parameters:
    ///   - device: The Metal device used to create the texture.
    ///   - textureName: The name of the texture file (without file extension).
    /// - Returns: An optional `MTLTexture` if loading is successful.
    private func loadTexture(device: MTLDevice, textureName: String) -> MTLTexture? {
        guard let textureURL = Bundle.main.url(forResource: "Assets/Textures/\(textureName)", withExtension: "png") else {
            print("Error: Texture file \(textureName) not found.")
            return nil
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        let options: [MTKTextureLoader.Option : Any] = [
            .SRGB : false,
            .origin : MTKTextureLoader.Origin.bottomLeft,
            .generateMipmaps : true
        ]
        
        do {
            let texture = try textureLoader.newTexture(URL: textureURL, options: options)
            print("Texture \(textureName) loaded successfully.")
            return texture
        } catch {
            print("Error loading texture \(textureName): \(error)")
            return nil
        }
    }

    /// Sets the roughness of the material.
    /// - Parameter roughness: Roughness value to apply.
    func setRoughness(_ roughness: Float) {
        self.roughness = roughness
    }

    /// Sets the metallic property of the material.
    /// - Parameter metallic: Metallic value to apply.
    func setMetallic(_ metallic: Float) {
        self.metallic = metallic
    }

    /// Resets the material properties to default values.
    func resetProperties() {
        self.roughness = 0.5
        self.metallic = 0.0
    }

    /// Binds material properties and texture (if available) to the fragment shader.
    /// - Parameter renderEncoder: The Metal render command encoder used to issue drawing commands.
    func bindToShader(renderEncoder: MTLRenderCommandEncoder) {
        // Define a struct for passing material properties to the shader
        struct MaterialProperties {
            var diffuseColor: SIMD3<Float>
            var specularColor: SIMD3<Float>
            var shininess: Float
            var roughness: Float
            var metallic: Float
            var hasTexture: Int32
        }

        // Populate the material properties struct
        var materialProperties = MaterialProperties(
            diffuseColor: diffuseColor,
            specularColor: specularColor,
            shininess: shininess,
            roughness: roughness,
            metallic: metallic,
            hasTexture: hasTexture ? 1 : 0
        )
        
        // Bind the material properties to the fragment shader
        renderEncoder.setFragmentBytes(&materialProperties, length: MemoryLayout<MaterialProperties>.stride, index: 1)
        
        // Bind the texture if available
        if let texture = texture {
            renderEncoder.setFragmentTexture(texture, index: 0) // Assuming 0 is TextureIndexColor
        }
    }
}

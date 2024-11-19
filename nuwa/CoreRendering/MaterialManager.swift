//
//  MaterialManager.swift
//  NuwaEngine
//
//  Manages materials, including loading and caching textures, and applying
//  material properties to Metal render encoders.
//
//  Created by Wenyan Qin on 2024-11-09. Updated on 2024-11-19.
//

import Foundation
import Metal
import MetalKit
import simd

/// Manages textures and material properties for rendering.
class MaterialManager {
    private var textures: [String: MTLTexture] = [:] // Cache for loaded textures
    private let textureLoader: MTKTextureLoader      // MetalKit texture loader

    /// Initializes the `MaterialManager` with a Metal device.
    /// - Parameter device: Metal device for texture loading.
    init(device: MTLDevice) {
        textureLoader = MTKTextureLoader(device: device)
    }

    /// Loads a texture from the app's asset catalog.
    /// - Parameter name: The texture file name.
    /// - Returns: The loaded `MTLTexture` or nil if loading fails.
    func loadTexture(named name: String) -> MTLTexture? {
        if let cachedTexture = textures[name] {
            return cachedTexture
        }

        guard let textureURL = Bundle.main.url(forResource: "Assets/Textures/\(name)", withExtension: "png") else {
            print("Error: Texture \(name) not found.")
            return nil
        }

        do {
            let texture = try textureLoader.newTexture(URL: textureURL, options: [
                .origin: MTKTextureLoader.Origin.bottomLeft,
                .generateMipmaps: true
            ])
            textures[name] = texture
            return texture
        } catch {
            print("Error loading texture \(name): \(error)")
            return nil
        }
    }

    /// Applies material properties and textures to the render encoder.
    /// - Parameters:
    ///   - material: Material data to apply.
    ///   - renderEncoder: Render command encoder.
    func applyMaterial(_ material: Material, to renderEncoder: MTLRenderCommandEncoder) {
        struct MaterialProperties {
            var diffuseColor: SIMD3<Float>
            var specularColor: SIMD3<Float>
            var shininess: Float
            var hasTexture: Int32
        }

        var materialProps = MaterialProperties(
            diffuseColor: material.diffuseColor,
            specularColor: material.specularColor,
            shininess: material.shininess,
            hasTexture: material.hasTexture ? 1 : 0
        )

        renderEncoder.setFragmentBytes(&materialProps, length: MemoryLayout<MaterialProperties>.stride, index: Int(BufferIndexUniforms.rawValue))
        
        if let texture = textures["default"] {
            renderEncoder.setFragmentTexture(texture, index: Int(TextureIndexColor.rawValue))
        }
    }
}

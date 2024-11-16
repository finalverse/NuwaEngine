//
//  MaterialManager.swift
//  NuwaEngine:
//    - Manages loading, caching, and applying materials for entities.
//
//  Created by Wenyan Qin on 2024-11-09.
//

import Foundation
import Metal
import MetalKit
import simd

/// `MaterialManager` manages materials and textures, providing flexibility in applying material properties dynamically.
class MaterialManager {
    private var textures: [String: MTLTexture] = [:]  // Cache for textures by name
    private let textureLoader: MTKTextureLoader       // Texture loader for loading textures

    init(device: MTLDevice) {
        textureLoader = MTKTextureLoader(device: device)
    }

    /// Loads a texture from the asset catalog and caches it.
    /// - Parameter name: The name of the texture file.
    /// - Returns: The loaded MTLTexture or nil if loading fails.
    func loadTexture(named name: String) -> MTLTexture? {
        // Check if the texture is already loaded
        if let cachedTexture = textures[name] {
            return cachedTexture
        }

        guard let textureURL = Bundle.main.url(forResource: "Assets/Textures/\(name)", withExtension: "png") else {
            print("Error: Texture \(name) not found in assets.")
            return nil
        }

        do {
            let texture = try textureLoader.newTexture(URL: textureURL, options: [
                .origin: MTKTextureLoader.Origin.bottomLeft,
                .generateMipmaps: NSNumber(value: true)
            ])
            textures[name] = texture
            return texture
        } catch {
            print("Error loading texture \(name): \(error)")
            return nil
        }
    }

    /// Applies material properties to a render encoder for rendering.
    /// - Parameters:
    ///   - renderEncoder: The render command encoder.
    ///   - material: The material to be applied.
    func applyMaterial(_ material: Material, to renderEncoder: MTLRenderCommandEncoder) {
        struct MaterialProperties {
            var diffuseColor: SIMD3<Float>
            var specularColor: SIMD3<Float>
            var shininess: Float
            var emissiveColor: SIMD3<Float>
            var reflectivity: Float
            var hasTexture: Int32
        }

        var materialProperties = MaterialProperties(
            diffuseColor: material.diffuseColor,
            specularColor: material.specularColor,
            shininess: material.shininess,
            emissiveColor: material.emissiveColor,
            reflectivity: material.reflectivity,
            hasTexture: material.hasTexture ? 1 : 0
        )

        renderEncoder.setFragmentBytes(&materialProperties, length: MemoryLayout<MaterialProperties>.stride, index: 1)

        if let texture = material.texture {
            renderEncoder.setFragmentTexture(texture, index: 0)
        }
    }
}

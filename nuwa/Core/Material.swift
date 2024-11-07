//
//  Material.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-07.
//

import Foundation
import Metal

class Material {
    var diffuseColor: SIMD3<Float>
    var specularColor: SIMD3<Float>
    var shininess: Float
    var hasTexture: Bool

    init(diffuseColor: SIMD3<Float>, specularColor: SIMD3<Float>, shininess: Float, hasTexture: Bool) {
        self.diffuseColor = diffuseColor
        self.specularColor = specularColor
        self.shininess = shininess
        self.hasTexture = hasTexture
    }

    // Method to bind material properties to the fragment shader
    // Method to bind material properties to the fragment shader
    func bindToShader(renderEncoder: MTLRenderCommandEncoder) {
        var materialProperties =
            Material(diffuseColor: self.diffuseColor,
                    specularColor: self.specularColor,
                    shininess: self.shininess,
                    hasTexture: ((self.hasTexture ? 1 : 0) != 0))
        renderEncoder.setFragmentBytes(&materialProperties, length: MemoryLayout<Material>.stride, index: 1)
    }
}

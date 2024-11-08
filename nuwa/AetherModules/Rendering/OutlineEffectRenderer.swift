//
//  OutlineEffectRenderer.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-08.
//

import Foundation
// AetherModules/Rendering/OutlineEffectRenderer.swift

import Metal

/// Renderer for applying an outline effect to an entity
class OutlineEffectRenderer: EffectRenderer {
    private var outlineColor: SIMD4<Float> = SIMD4<Float>(1, 1, 0, 1) // Yellow outline

    override func setupPipeline(device: MTLDevice, shaderName: String = "outlineShader") {
        // Setup pipeline with outline shader
    }

    override func applyEffect(renderEncoder: MTLRenderCommandEncoder, entity: Entity) {
        renderEncoder.setFragmentBytes(&outlineColor, length: MemoryLayout<SIMD4<Float>>.size, index: 1)
        renderEncoder.setVertexBuffer(entity.vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: entity.vertexCount)
    }
}

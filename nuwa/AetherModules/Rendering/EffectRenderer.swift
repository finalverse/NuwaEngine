//
//  EffectRenderer.swift
//  NuwaEngine - AetherModules/Rendering/EffectRenderer.swift
//
//  Created by Wenyan Qin on 2024-11-08.
//

import Foundation
import Metal

/// Base class for applying visual effects to entities in the 3D world
class EffectRenderer {
    var pipelineState: MTLRenderPipelineState?

    func setupPipeline(device: MTLDevice, shaderName: String) {
        // Setup pipeline with a generic effect shader
        // This allows subclasses to apply their specific effects
    }

    func applyEffect(renderEncoder: MTLRenderCommandEncoder, entity: Entity) {
        // Override to apply specific effects in subclasses
    }
}

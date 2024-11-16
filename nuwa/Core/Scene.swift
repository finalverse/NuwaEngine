//
//  Scene.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  Scene manages all entities in the scene, including lights and global settings like ambient lighting.
//  It provides functions to add, remove, and update entities.

// Scene.swift
// Manages all entities, including global settings like ambient lighting

import Foundation
import simd
import Metal

class Scene {
    var entities: [Entity] = []
    var ambientLightColor: SIMD3<Float> = SIMD3<Float>(0.1, 0.1, 0.1)
    var lightingManager: LightingManager?  // Updated from LightingShader to LightingManager

    init(device: MTLDevice) {
        lightingManager = LightingManager(device: device)
    }

    func addEntity(_ entity: Entity) {
        entities.append(entity)
    }

    func removeEntity(_ entity: Entity) {
        entities.removeAll { $0 === entity }
    }

    func update(deltaTime: Float, device: MTLDevice) {
        for entity in entities {
            entity.updateUniforms(viewProjectionMatrix: matrix_identity_float4x4, cameraPosition: SIMD3<Float>(0, 0, 0))
        }
        
        // Update lighting buffer if lightingManager is present
        lightingManager?.updateLightBuffer()
    }
}

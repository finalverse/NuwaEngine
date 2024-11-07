//
//  Scene.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  Scene manages all entities in the scene, including lights and global settings like ambient lighting.
//  It provides functions to add, remove, and update entities.

import Foundation

class Scene {
    var entities: [Entity] = []                // List of all entities in the scene
    var ambientLightColor: SIMD3<Float> = SIMD3<Float>(0.1, 0.1, 0.1) // Global ambient light color

    init() {}

    /// Adds a new entity to the scene
    func addEntity(_ entity: Entity) {
        entities.append(entity)
    }

    /// Removes an entity from the scene if it exists
    func removeEntity(_ entity: Entity) {
        entities.removeAll { $0 === entity }
    }

    /// Updates all entities in the scene by applying transformations, animations, etc.
    func update(deltaTime: Float) {
        for entity in entities {
            entity.update(deltaTime: deltaTime)
        }
    }
}

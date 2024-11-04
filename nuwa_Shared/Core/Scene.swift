//
//  Scene.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//

// Scene.swift
// Represents a scene containing a collection of entities. Manages adding and removing entities.

import Foundation

class Scene {
    var entities: [Entity] = []

    // Adds an entity to the scene.
    func addEntity(_ entity: Entity) {
        entities.append(entity)
    }

    // Removes an entity from the scene.
    func removeEntity(_ entity: Entity) {
        entities = entities.filter { $0 !== entity }
    }
}


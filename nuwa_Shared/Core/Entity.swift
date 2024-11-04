//
//  Entity.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//

// Entity.swift
// Represents a basic renderable object in the scene. Holds a reference to its SceneNode for transformation data.

import Foundation
import simd
import Metal

class Entity {
    var node: SceneNode       // Holds position, rotation, and scale of the entity.

    init(node: SceneNode) {
        self.node = node
    }

    // Draws the entity using the provided render encoder. To be overridden by subclasses.
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        // Placeholder for rendering logic.
        // Subclasses or specific entities will implement their own drawing logic here.
    }
}


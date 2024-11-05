//
//  Entity.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//

// Entity.swift
// Represents a basic renderable object in the scene. Holds a reference to its SceneNode for transformation data.

// update: ---
// Add a uniformBuffer property to hold the transformation data for each entity.
// uniformBuffer: Holds an instance of Uniforms (the structure that contains modelMatrix). Each entity will update this buffer with its transformation matrix before drawing.

import Foundation
import simd
import Metal

class Entity {
    var node: SceneNode             // Holds position, rotation, and scale of the entity.
    var uniformBuffer: MTLBuffer?   // Buffer to hold transformation matrix for the entity

    init(node: SceneNode, device: MTLDevice) {
        self.node = node

        // Initialize the uniform buffer for the transformation matrix
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: [])
    }

    // Draws the entity using the provided render encoder. To be overridden by subclasses.
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        // Placeholder for rendering logic.
        // Subclasses or specific entities will implement their own drawing logic here.
    }
}


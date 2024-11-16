//
//  SceneGraph.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-09.
//

import Foundation
import Metal

/// `SceneGraph` organizes entities hierarchically, allowing for efficient spatial management.
class SceneGraph {
    private var rootNode: SceneNode
    
    // Singleton instance for shared access across modules
    static let shared = SceneGraph()
    
    init() {
        rootNode = SceneNode()
    }

    func addEntity(_ entity: Entity, parent: SceneNode? = nil) {
        let parentNode = parent ?? rootNode
        parentNode.addChild(entity)
    }

    func update(deltaTime: Float) {
        rootNode.update(deltaTime: deltaTime)
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        rootNode.render(renderEncoder: renderEncoder)
    }
    
    // New method for updating lighting intensity in the scene
    func updateLighting(intensity: Float) {
        // Implement the logic to adjust lighting in the scene graph as needed
        // This could involve passing the intensity value to a lighting system or shader
    }
}

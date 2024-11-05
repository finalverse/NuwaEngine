//
//  SceneNode.swift
//  nuwa Core/SceneNode
//
//  Created by Wenyan Qin on 2024-11-05.
//

// SceneNode.swift
// Represents a node in the scene graph. Holds transformation data and manages a hierarchical structure of children.
// update -------
// - Parent-Child Relationships: Each SceneNode can now have a parent and multiple children, creating a tree-like structure.
// - worldMatrix(): The transformation matrix now includes the parent’s transformation matrix, allowing children to inherit transformations from their parents.
// update -------
// - Animator: Each SceneNode can have an optional Animator to manage animations.
// - Update Method: The update(deltaTime:) method applies animations to the node and recursively updates child nodes.


import Foundation
import simd

class SceneNode {
    
    //Defines the node’s translation in the scene.
    var position: SIMD3<Float> = SIMD3(0, 0, 0)
    
    //Defines the node’s rotation in Euler angles (x, y, z) in radians.
    var rotation: SIMD3<Float> = SIMD3(0, 0, 0)
    
    //Defines the node’s scale in each axis.
    var scale: SIMD3<Float> = SIMD3(1, 1, 1)
    
    var parent: SceneNode?              // Reference to parent node
    var children: [SceneNode] = []      // Array to hold child nodes
    var animator: Animator?             // Animator to manage animations for this node


    // Adds a child node and sets this node as the parent
    func addChild(_ child: SceneNode) {
        child.parent = self
        children.append(child)
    }

    // Removes a child node and clears its parent
    func removeChild(_ child: SceneNode) {
        children = children.filter { $0 !== child }
        child.parent = nil
    }

    // Computes the world transformation matrix for this node.
    // Calculates the transformation matrix by applying translation, rotation, and scaling in the correct order. This matrix will be used by the GPU to position vertices accordingly.
    func worldMatrix() -> float4x4 {
        // Apply scaling, rotation, and translation in the correct order
        var matrix = float4x4(translation: position)

        matrix = float4x4(rotation: rotation) * matrix
        matrix = float4x4(scaling: scale) * matrix
        
        // taking parent transformations into account
        if let parentMatrix = parent?.worldMatrix() {
            matrix = parentMatrix * matrix
        }
        
        return matrix
    }
    
    // Update the node's transformation if it has an animator
    func update(deltaTime: Float) {
        animator?.update(node: self, deltaTime: deltaTime)
        children.forEach { $0.update(deltaTime: deltaTime) }
    }
}

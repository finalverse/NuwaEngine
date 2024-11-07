//
//  SceneNode.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  SceneNode represents a node in a transformation hierarchy, allowing for parent-child relationships.
//  Each node has position, rotation, and scale properties, and transformations are combined in a hierarchical structure.

import simd

class SceneNode {
    var position: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    var rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    var scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1)

    private var children: [SceneNode] = []   // Child nodes
    weak var parent: SceneNode?              // Optional parent node (weak to avoid retain cycles)

    /// Computes the world transformation matrix by combining this node's transformation with its parent's.
    func worldMatrix() -> float4x4 {
        var matrix = float4x4(translation: position)
        matrix = matrix * float4x4(rotation)
        matrix = matrix * float4x4(scaling: scale)
        
        if let parent = parent {
            return parent.worldMatrix() * matrix
        } else {
            return matrix
        }
    }

    /// Adds a child node to this node, establishing a parent-child relationship.
    func addChild(_ child: SceneNode) {
        child.parent = self
        children.append(child)
    }

    /// Removes a child node from this node, breaking the parent-child relationship.
    func removeChild(_ child: SceneNode) {
        children.removeAll { $0 === child }
        child.parent = nil
    }

    /// Updates all child nodes recursively.
    func update(deltaTime: Float) {
        // Update each child node's transformations or animations if needed
        for child in children {
            child.update(deltaTime: deltaTime)
        }
    }
}

//
//  SceneNode.swift
//  nuwa Core/SceneNode
//
//  Created by Wenyan Qin on 2024-11-05.
//

// SceneNode.swift
// Represents a node in the scene graph. Holds transformation data and manages a hierarchical structure of children.

import Foundation
import simd

class SceneNode {
    var position: SIMD3<Float> = SIMD3(0, 0, 0)
    var rotation: SIMD3<Float> = SIMD3(0, 0, 0)
    var scale: SIMD3<Float> = SIMD3(1, 1, 1)
    var children: [SceneNode] = []

    // Adds a child node.
    func addChild(_ child: SceneNode) {
        children.append(child)
    }

    // Removes a child node.
    func removeChild(_ child: SceneNode) {
        children = children.filter { $0 !== child }
    }

    // Computes the world transformation matrix for this node.
    func worldMatrix() -> float4x4 {
        var matrix = float4x4(translation: position)
        matrix = matrix * float4x4(rotation: rotation)
        matrix = matrix * float4x4(scaling: scale)
        return matrix
    }
}

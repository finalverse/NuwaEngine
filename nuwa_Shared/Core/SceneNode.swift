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
    
    //Defines the node’s translation in the scene.
    var position: SIMD3<Float> = SIMD3(0, 0, 0)
    
    //Defines the node’s rotation in Euler angles (x, y, z) in radians.
    var rotation: SIMD3<Float> = SIMD3(0, 0, 0)
    
    //Defines the node’s scale in each axis.
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
    // Calculates the transformation matrix by applying translation, rotation, and scaling in the correct order. This matrix will be used by the GPU to position vertices accordingly.
    func worldMatrix() -> float4x4 {
        // Apply scaling, rotation, and translation in the correct order
        var matrix = float4x4(translation: position)
        //matrix = matrix * float4x4(rotation: rotation)
        //matrix = matrix * float4x4(scaling: scale)
        matrix = float4x4(rotation: rotation) * matrix
        matrix = float4x4(scaling: scale) * matrix
        return matrix
    }
}

//
//  SceneNode.swift
//  NuwaEngine - Core/SceneNode.swift
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  SceneNode represents a hierarchical transformation node with position, rotation, and scale properties.

import simd
import Metal

class SceneNode {
    var position: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    var rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    var scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1)
    
    private var children: [SceneNode] = []
    weak var parent: SceneNode?
    
    // New property to manage animation states
    var animationState: String? // Tracks the current animation state
    
    func worldMatrix() -> float4x4 {
        let translationMatrix = float4x4(translation: position)
        let rotationMatrix = float4x4(rotation)
        let scalingMatrix = float4x4(scaling: scale)
        
        let localTransform = translationMatrix * rotationMatrix * scalingMatrix
        
        if let parentMatrix = parent?.worldMatrix() {
            return parentMatrix * localTransform
        } else {
            return localTransform
        }
    }

    func addChild(_ child: SceneNode) {
        child.parent = self
        children.append(child)
    }

    func removeChild(_ child: SceneNode) {
        children.removeAll { $0 === child }
        child.parent = nil
    }

    func update(deltaTime: Float) {
        for child in children {
            child.update(deltaTime: deltaTime)
        }
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        (self as? Entity)?.draw(renderEncoder: renderEncoder)
        
        for child in children {
            child.render(renderEncoder: renderEncoder)
        }
    }
    
    // New method to trigger animations by name
    func triggerAnimation(named animationName: String) {
        // Here, you could manage specific animations or states for different animations
        self.animationState = animationName
        // Implement the actual animation logic if needed
    }
}

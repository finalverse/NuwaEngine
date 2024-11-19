//
//  SceneNode.swift
//  NuwaEngine
//
//  Represents a hierarchical transformation node with position, rotation, scale, and animation properties.
//  SceneNode acts as the foundation for all spatial entities in the scene graph.
//
//  Updated on 2024-11-19.
//

import simd
import Metal

/// Represents a node in the scene graph, supporting hierarchical transformations and animations.
class SceneNode {
    // MARK: - Properties

    var position: SIMD3<Float> = SIMD3<Float>(0, 0, 0)          // Node's position in world space
    var rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0)) // Node's rotation in world space
    var scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1)             // Node's scale in world space

    private var children: [SceneNode] = []                      // Child nodes in the hierarchy
    weak var parent: SceneNode?                                 // Parent node in the hierarchy

    // MARK: - Animation Support
    var activeAnimations: [String] = [] // Tracks active animations by name

    // MARK: - Transformation

    /// Computes the combined transformation matrix for the node.
    /// - Returns: The transformation matrix in world space.
    func worldMatrix() -> matrix_float4x4 {
        let translationMatrix = matrix_float4x4(translation: position)
        let rotationMatrix = matrix_float4x4(rotation)
        let scalingMatrix = matrix_float4x4(scaling: scale)

        let localTransform = translationMatrix * rotationMatrix * scalingMatrix
        if let parentMatrix = parent?.worldMatrix() {
            return parentMatrix * localTransform
        } else {
            return localTransform
        }
    }

    // MARK: - Hierarchy Management

    /// Adds a child node to this node.
    /// - Parameter child: The child node to add.
    func addChild(_ child: SceneNode) {
        child.parent = self
        children.append(child)
    }

    /// Removes a child node from this node.
    /// - Parameter child: The child node to remove.
    func removeChild(_ child: SceneNode) {
        children.removeAll { $0 === child }
        child.parent = nil
    }

    // MARK: - Animation Support

    /// Triggers an animation on the node.
    /// - Parameter animationName: The name of the animation to trigger.
    func triggerAnimation(named animationName: String) {
        if !activeAnimations.contains(animationName) {
            activeAnimations.append(animationName)
            handleAnimation(named: animationName)
        }
    }

    /// Handles the logic for playing an animation.
    /// - Parameter animationName: The name of the animation being played.
    func handleAnimation(named animationName: String) {
        print("Animation '\(animationName)' triggered for SceneNode at position \(position)")
        // Implement actual animation logic here (e.g., position updates, effects)
    }

    /// Updates the animation state for the node. Called every frame.
    /// - Parameter deltaTime: Time elapsed since the last frame.
    func updateAnimations(deltaTime: TimeInterval) {
        for animationName in activeAnimations {
            if animationName == "engagementAnimation" {
                // Example: Adjust position over time
                position += SIMD3<Float>(0.0, 0.01 * Float(deltaTime), 0.0)
            }
        }
        // Clear finished animations (optional logic)
    }

    // MARK: - Updates

    /// Updates the node and its children each frame.
    /// - Parameter deltaTime: The time elapsed since the last update.
    func update(deltaTime: Float) {
        updateAnimations(deltaTime: TimeInterval(deltaTime))
        for child in children {
            child.update(deltaTime: deltaTime)
        }
    }

    // MARK: - Rendering

    /// Renders the node and its children using the given render encoder.
    /// - Parameter renderEncoder: The Metal render command encoder.
    func render(renderEncoder: MTLRenderCommandEncoder) {
        (self as? Entity)?.draw(renderEncoder: renderEncoder)
        for child in children {
            child.render(renderEncoder: renderEncoder)
        }
    }
}

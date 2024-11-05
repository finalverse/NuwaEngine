//
//  Animator.swift
//  NuwaEngine Aniation/Animator.swift
//
//  Created by Wenyan Qin on 2024-11-05.
//

// create -------
// The Animator class will manage individual animations, allowing us to specify the type (e.g., rotation) and duration.
// - Animation Types: Animator supports translation, rotation, and scaling animations, each with a target transformation and duration.
// - Update Function: The update(node:deltaTime:) function adjusts the SceneNode’s transformation based on the elapsed time.
// - Completion Check: isComplete() determines if the animation has finished based on its duration.
                                                
import Foundation
import simd

enum AnimationType {
    case translation(SIMD3<Float>, duration: Float)
    case rotation(SIMD3<Float>, duration: Float)
    case scaling(SIMD3<Float>, duration: Float)
}

class Animator {
    var type: AnimationType
    private var elapsedTime: Float = 0.0

    init(type: AnimationType) {
        self.type = type
    }

    // Updates the transformation based on the animation type and elapsed time
    func update(node: SceneNode, deltaTime: Float) {
        elapsedTime += deltaTime

        switch type {
        case .translation(let targetPosition, let duration):
            let progress = min(elapsedTime / duration, 1.0)
            node.position = lerp(start: node.position, end: targetPosition, t: progress)
        case .rotation(let targetRotation, let duration):
            let progress = min(elapsedTime / duration, 1.0)
            node.rotation = lerp(start: node.rotation, end: targetRotation, t: progress)
        case .scaling(let targetScale, let duration):
            let progress = min(elapsedTime / duration, 1.0)
            node.scale = lerp(start: node.scale, end: targetScale, t: progress)
        }
    }

    // Checks if the animation is complete
    func isComplete() -> Bool {
        switch type {
        case .translation(_, let duration),
             .rotation(_, let duration),
             .scaling(_, let duration):
            return elapsedTime >= duration
        }
    }

    // Linear interpolation function
    private func lerp(start: SIMD3<Float>, end: SIMD3<Float>, t: Float) -> SIMD3<Float> {
        return start + (end - start) * t
    }
}



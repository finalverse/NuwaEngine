//
//  Animator.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  Animator handles animations for entities, applying transformations over time.
//  Supported Animations:
//    - Rotation
//    - Translation
//    - Scaling
//    - Future Support: Keyframe-based animations with an `AnimationClip`

import Foundation
import simd

enum AnimationType {
    case rotation(axis: SIMD3<Float>, angle: Float, duration: Float)
    case translation(offset: SIMD3<Float>, duration: Float)
    case scaling(scale: SIMD3<Float>, duration: Float)
    // Future support for keyframe animations
}

class Animator {
    private var animationType: AnimationType
    private var elapsedTime: Float = 0.0
    private var isActive: Bool = true

    init(type: AnimationType) {
        self.animationType = type
    }

    // Update function applies the animation based on elapsed time and animation type
    func update(deltaTime: Float, node: SceneNode) {
        guard isActive else { return }

        elapsedTime += deltaTime
        switch animationType {
        case .rotation(let axis, let angle, let duration):
            let progress = min(elapsedTime / duration, 1.0)
            let currentAngle = angle * progress
            node.rotation = simd_quatf(angle: currentAngle, axis: normalize(axis))
            if progress >= 1.0 { isActive = false } // End animation after duration

        case .translation(let offset, let duration):
            let progress = min(elapsedTime / duration, 1.0)
            node.position += offset * progress
            if progress >= 1.0 { isActive = false }

        case .scaling(let scale, let duration):
            let progress = min(elapsedTime / duration, 1.0)
            node.scale = scale * progress
            if progress >= 1.0 { isActive = false }
        }
    }

    // Reset the animation, allowing it to replay from the beginning
    func reset() {
        elapsedTime = 0.0
        isActive = true
    }
}

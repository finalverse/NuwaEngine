//
//  Camera.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  Camera manages the view and projection matrices for rendering.
//  It supports both perspective and orthographic projections.

import simd

enum ProjectionType {
    case perspective
    case orthographic
}

class Camera {
    var position: SIMD3<Float> = SIMD3<Float>(0, 0, -5)  // Default position
    var lookAtTarget: SIMD3<Float> = SIMD3<Float>(0, 0, 0) // Point the camera is looking at
    var up: SIMD3<Float> = SIMD3<Float>(0, 1, 0)          // Up direction
    
    var aspectRatio: Float = 1.0                          // Aspect ratio of the view
    var fieldOfView: Float = 45.0 * (Float.pi / 180.0)    // Field of view in radians
    var nearPlane: Float = 0.1                            // Near clipping plane
    var farPlane: Float = 100.0                           // Far clipping plane

    var projectionType: ProjectionType = .perspective     // Projection type

    /// Computed property to get the combined view-projection matrix
    var viewProjectionMatrix: float4x4 {
        return projectionMatrix() * viewMatrix()
    }

    /// Calculates and returns the view matrix based on position and orientation
    func viewMatrix() -> float4x4 {
        return float4x4(eye: position, center: lookAtTarget, up: up)
    }

    /// Calculates and returns the projection matrix based on the projection type
    func projectionMatrix() -> float4x4 {
        switch projectionType {
        case .perspective:
            return float4x4(perspectiveProjectionFov: fieldOfView, aspectRatio: aspectRatio, nearZ: nearPlane, farZ: farPlane)
        case .orthographic:
            let orthoWidth: Float = 10.0  // Width of orthographic view
            let orthoHeight = orthoWidth / aspectRatio
            return float4x4(orthographicProjection: orthoWidth, height: orthoHeight, nearZ: nearPlane, farZ: farPlane)
        }
    }

    /// Moves the camera to a new position
    func setPosition(_ newPosition: SIMD3<Float>) {
        position = newPosition
    }

    /// Rotates the camera by changing the look-at target
    func lookAt(_ target: SIMD3<Float>) {
        lookAtTarget = target
    }
}

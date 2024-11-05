//
//  Camera.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-05.
//

import Foundation

// --------------------------------------------------
// - Position and Rotation: Defines where the camera is in the scene and its orientation.
// - Projection Matrix: Uses a perspective projection with a field of view, aspect ratio, near plane, and far plane.
// - View Matrix: Calculates the view matrix based on the camera’s position and rotation.

import simd

class Camera {
    var position: SIMD3<Float> = SIMD3(0, 0, 2) // Position the camera a bit away from the origin
    var rotation: SIMD3<Float> = SIMD3(0, 0, 0)
    var fieldOfView: Float = 45.0 * (.pi / 180) // Convert degrees to radians
    var aspectRatio: Float = 1.0
    var nearPlane: Float = 0.1
    var farPlane: Float = 100.0

    // Computes the view matrix based on position and rotation
    func viewMatrix() -> float4x4 {
        let translationMatrix = float4x4(translation: -position)
        let rotationMatrix = float4x4(rotation: rotation)
        return rotationMatrix * translationMatrix
    }

    // Computes the projection matrix using perspective projection
    func projectionMatrix() -> float4x4 {
        return float4x4(perspectiveProjectionFov: fieldOfView, aspectRatio: aspectRatio, nearPlane: nearPlane, farPlane: farPlane)
    }
}

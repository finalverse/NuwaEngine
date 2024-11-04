//
//  MatrixExtensions.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//

import Foundation

// MatrixExtensions.swift
// Provides utility functions for creating transformation matrices using SIMD types.

import simd

extension float4x4 {
    // Initializes a translation matrix
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        self.columns.3 = SIMD4(translation.x, translation.y, translation.z, 1.0)
    }

    // Initializes a rotation matrix using Euler angles (in radians) for each axis
    init(rotation: SIMD3<Float>) {
        let rotationX = float4x4(rotationX: rotation.x)
        let rotationY = float4x4(rotationY: rotation.y)
        let rotationZ = float4x4(rotationZ: rotation.z)
        self = rotationZ * rotationY * rotationX
    }

    // Initializes a rotation matrix around the X-axis
    init(rotationX angle: Float) {
        self = float4x4([
            SIMD4(1, 0, 0, 0),
            SIMD4(0, cos(angle), -sin(angle), 0),
            SIMD4(0, sin(angle), cos(angle), 0),
            SIMD4(0, 0, 0, 1)
        ])
    }

    // Initializes a rotation matrix around the Y-axis
    init(rotationY angle: Float) {
        self = float4x4([
            SIMD4(cos(angle), 0, sin(angle), 0),
            SIMD4(0, 1, 0, 0),
            SIMD4(-sin(angle), 0, cos(angle), 0),
            SIMD4(0, 0, 0, 1)
        ])
    }

    // Initializes a rotation matrix around the Z-axis
    init(rotationZ angle: Float) {
        self = float4x4([
            SIMD4(cos(angle), -sin(angle), 0, 0),
            SIMD4(sin(angle), cos(angle), 0, 0),
            SIMD4(0, 0, 1, 0),
            SIMD4(0, 0, 0, 1)
        ])
    }

    // Initializes a scaling matrix
    init(scaling: SIMD3<Float>) {
        self = matrix_identity_float4x4
        self.columns.0.x = scaling.x
        self.columns.1.y = scaling.y
        self.columns.2.z = scaling.z
    }
}

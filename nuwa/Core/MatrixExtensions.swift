//
//  MatrixExtensions.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  This file provides utility functions for creating and manipulating transformation matrices.
//  Includes translation, rotation, scaling, perspective projection, and orthographic projection.

import simd

extension float4x4 {
    
    /// Creates a translation matrix for moving entities in 3D space
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        self.columns.3 = SIMD4(translation.x, translation.y, translation.z, 1.0)
    }

    /// Creates a rotation matrix for a rotation around the X axis
    init(rotationX angle: Float) {
        self = matrix_identity_float4x4
        self.columns.1.y = cos(angle)
        self.columns.1.z = -sin(angle)
        self.columns.2.y = sin(angle)
        self.columns.2.z = cos(angle)
    }

    /// Creates a rotation matrix for a rotation around the Y axis
    init(rotationY angle: Float) {
        self = matrix_identity_float4x4
        self.columns.0.x = cos(angle)
        self.columns.0.z = sin(angle)
        self.columns.2.x = -sin(angle)
        self.columns.2.z = cos(angle)
    }

    /// Creates a rotation matrix for a rotation around the Z axis
    init(rotationZ angle: Float) {
        self = matrix_identity_float4x4
        self.columns.0.x = cos(angle)
        self.columns.0.y = -sin(angle)
        self.columns.1.x = sin(angle)
        self.columns.1.y = cos(angle)
    }

    /// Creates a scaling matrix to scale entities in 3D space
    init(scaling: SIMD3<Float>) {
        self = matrix_identity_float4x4
        self.columns.0.x = scaling.x
        self.columns.1.y = scaling.y
        self.columns.2.z = scaling.z
    }

    /// Creates a perspective projection matrix for rendering 3D scenes
    init(perspectiveProjectionFov fov: Float, aspectRatio: Float, nearZ: Float, farZ: Float) {
        let yScale = 1 / tan(fov * 0.5)
        let xScale = yScale / aspectRatio
        let zRange = farZ - nearZ
        let zScale = -(farZ + nearZ) / zRange
        let wzScale = -2 * farZ * nearZ / zRange

        self.init()
        columns = (
            SIMD4<Float>(xScale, 0, 0, 0),
            SIMD4<Float>(0, yScale, 0, 0),
            SIMD4<Float>(0, 0, zScale, -1),
            SIMD4<Float>(0, 0, wzScale, 0)
        )
    }

    /// Creates an orthographic projection matrix for 2D and UI rendering
    init(orthographicProjection width: Float, height: Float, nearZ: Float, farZ: Float) {
        let zRange = farZ - nearZ
        let zScale = -2 / zRange
        let wzScale = -(farZ + nearZ) / zRange

        self.init()
        columns = (
            SIMD4<Float>(2 / width, 0, 0, 0),
            SIMD4<Float>(0, 2 / height, 0, 0),
            SIMD4<Float>(0, 0, zScale, 0),
            SIMD4<Float>(0, 0, wzScale, 1)
        )
    }

    /// Creates a view matrix to position the camera in 3D space
    init(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) {
        let f = normalize(center - eye)
        let s = normalize(cross(f, up))
        let u = cross(s, f)

        self.init()
        columns = (
            SIMD4<Float>(s.x, u.x, -f.x, 0),
            SIMD4<Float>(s.y, u.y, -f.y, 0),
            SIMD4<Float>(s.z, u.z, -f.z, 0),
            SIMD4<Float>(-dot(s, eye), -dot(u, eye), dot(f, eye), 1)
        )
    }
}

//
//  SceneLight.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  `SceneLight` represents light data in the scene, including types like ambient, directional, and point lights.
//  Struct ensures alignment compatibility with Metal shaders for efficient GPU processing.
//

import simd

enum LightType: Int32 {
    case ambient = 0
    case directional = 1
    case point = 2
}

/// `SceneLight` is a data structure compatible with Metal, holding light properties for rendering.
struct SceneLight {
    var type: Int32                   //  4 bytes for light type (0 = ambient, 1 = directional, 2 = point)
    var color: SIMD3<Float>           // 12 bytes for light color (RGB)
    var intensity: Float              //  4 bytes for light intensity
    var position: SIMD3<Float>        // 12 bytes for the position in world space (for point lights)
    var padding1: Float = 0.0         //  4 bytes padding to align to 48 bytes
    var direction: SIMD3<Float>       // 12 bytes for directional light direction
    var padding2: Float = 0.0         //  4 bytes padding to maintain 48-byte alignment

    /// Initializes a SceneLight with default or specified values.
    init(type: LightType,
         color: SIMD3<Float>,
         intensity: Float,
         position: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
         direction: SIMD3<Float> = SIMD3<Float>(0, 0, -1)) {
        self.type = type.rawValue
        self.color = color
        self.intensity = intensity
        self.position = position
        self.direction = normalize(direction)
    }

    /// Helper function to create an ambient light.
    static func ambient(color: SIMD3<Float>, intensity: Float) -> SceneLight {
        return SceneLight(type: .ambient, color: color, intensity: intensity)
    }

    /// Helper function to create a directional light.
    static func directional(color: SIMD3<Float>, intensity: Float, direction: SIMD3<Float>) -> SceneLight {
        return SceneLight(type: .directional, color: color, intensity: intensity, direction: direction)
    }

    /// Helper function to create a point light.
    static func point(color: SIMD3<Float>, intensity: Float, position: SIMD3<Float>) -> SceneLight {
        return SceneLight(type: .point, color: color, intensity: intensity, position: position)
    }
}

//
//  Light.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-05.
//

// create ------
// - Light Types: We define ambient, directional, and point light types.
// - Light Properties: Each light has a color, intensity, and, depending on its type, a position or direction.

import Foundation

import simd

// Basic light types for the NUWA Engine
enum LightType {
    case ambient
    case directional
    case point
}

// Light structure to define properties for each light
struct Light {
    var type: LightType
    var color: SIMD3<Float>
    var intensity: Float
    var position: SIMD3<Float> = SIMD3(0, 0, 0) // Used for point lights
    var direction: SIMD3<Float> = SIMD3(0, -1, 0) // Used for directional lights

    init(type: LightType, color: SIMD3<Float>, intensity: Float, position: SIMD3<Float> = SIMD3(0, 0, 0), direction: SIMD3<Float> = SIMD3(0, -1, 0)) {
        self.type = type
        self.color = color
        self.intensity = intensity
        self.position = position
        self.direction = normalize(direction)
    }
}

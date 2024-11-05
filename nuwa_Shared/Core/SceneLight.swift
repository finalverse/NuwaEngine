//
//  SceneLight.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-05.
//

// create ------
// - SceneLight Types: We define ambient, directional, and point SceneLight types.
// - SceneLight Properties: Each SceneLight has a color, intensity, and, depending on its type, a position or direction.

import Foundation

import simd

// Basic SceneLight types for the NUWA Engine
enum SceneLightType {
    case ambient
    case directional
    case point
}

// SceneLight structure to define properties for each light
struct SceneLight {
    var type: SceneLightType        // // 0 = ambient, 1 = directional, 2 = point
    var color: SIMD3<Float>
    var intensity: Float
    var position: SIMD3<Float> = SIMD3(0, 0, 0) // Used for point scene lights
    var direction: SIMD3<Float> = SIMD3(0, -1, 0) // Used for directional scene lights

    init(type: SceneLightType, color: SIMD3<Float>, intensity: Float, position: SIMD3<Float> = SIMD3(0, 0, 0), direction: SIMD3<Float> = SIMD3(0, -1, 0)) {
        self.type = type
        self.color = color
        self.intensity = intensity
        self.position = position
        self.direction = normalize(direction)
    }
}

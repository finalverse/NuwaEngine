//
//  SceneLight.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  SceneLight represents different types of light sources in the scene, including ambient, directional, and point lights.
//  Each light type has distinct properties for position, color, direction, and intensity.

import simd

enum LightType: Int {
    case ambient = 0
    case directional = 1
    case point = 2
}

class SceneLight {
    var type: LightType                  // Type of the light (ambient, directional, point)
    var color: SIMD3<Float>              // Color of the light
    var intensity: Float                 // Intensity of the light
    var position: SIMD3<Float>           // Position for point lights
    var direction: SIMD3<Float>          // Direction for directional lights

    /// Initializes a SceneLight with the given properties.
    init(type: LightType,
         color: SIMD3<Float>,
         intensity: Float,
         position: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
         direction: SIMD3<Float> = SIMD3<Float>(0, 0, -1)) {
        self.type = type
        self.color = color
        self.intensity = intensity
        self.position = position
        self.direction = direction
    }

    /// Updates the light's position (useful for dynamic or moving lights)
    func setPosition(_ newPosition: SIMD3<Float>) {
        self.position = newPosition
    }

    /// Updates the light's direction (useful for directional lights)
    func setDirection(_ newDirection: SIMD3<Float>) {
        self.direction = normalize(newDirection)
    }

    /// Adjusts the intensity of the light
    func setIntensity(_ newIntensity: Float) {
        self.intensity = newIntensity
    }
}

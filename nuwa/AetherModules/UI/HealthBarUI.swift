//
//  HealthBarUI.swift
//  NuwaEngine - AetherModules/UI/HealthBarUI.swift
//
//  Created by Wenyan Qin on 2024-11-08.
//

import Foundation
import simd
import Metal

/// Health bar UI that dynamically displays health status as a colored bar
class HealthBarUI: InteractiveUI {
    var health: Float = 1.0

    func updateHealth(to newHealth: Float) {
        health = max(0.0, min(newHealth, 1.0)) // Clamps health between 0 and 1
    }

    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        // Adjust health bar size and color based on health value
        let width = 0.5 * health
        let healthColor: SIMD4<Float> = health > 0.5 ? SIMD4(0, 1, 0, 1) : SIMD4(1, 0, 0, 1)
        // Render a rectangle with `width` and `healthColor`
    }
}

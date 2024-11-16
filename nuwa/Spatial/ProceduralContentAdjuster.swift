//
//  ProceduralContentAdjuster.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-12.
//

import Foundation
import MetalKit

class ProceduralContentAdjuster {
    var sceneEntities: [SceneNode] // Entities to adjust
    var animationTriggerThreshold: Float // Threshold to trigger animations
    var effectIntensity: Float = 1.0 // Base intensity for environmental effects
    var engagementDurations: [Int: TimeInterval] = [:] // Tracks engagement duration
    
    init(entities: [SceneNode], animationTriggerThreshold: Float) {
        self.sceneEntities = entities
        self.animationTriggerThreshold = animationTriggerThreshold
    }
    
    func adjustBasedOnEngagement(engagedEntityIndices: [Int]) {
        for index in engagedEntityIndices {
            let entity = sceneEntities[index]
            entity.position += SIMD3<Float>(0.0, 0.05, 0.0)
            
            if let engagementTime = engagementDurations[index], Float(engagementTime) > animationTriggerThreshold {
                applyEnvironmentalEffects()
                entity.triggerAnimation(named: "engagementAnimation")
            }
        }
    }
    
    private func applyEnvironmentalEffects() {
        effectIntensity += 0.1
        SceneGraph.shared.updateLighting(intensity: effectIntensity)
    }
}

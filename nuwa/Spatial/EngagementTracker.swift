//
//  EngagementTracker.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-12.
//

import Foundation
import MetalKit

/// `EngagementTracker` monitors user proximity to entities within the scene and tracks engagement duration.
/// Entities respond adaptively when the user is within a specified distance for a certain time threshold.
class EngagementTracker {
    
    // MARK: - Properties
    
    var userPosition: SIMD3<Float>           // Current user position in the scene, updated in real-time
    var trackedEntities: [SceneNode]         // Entities being monitored for proximity-based interactions
    var proximityThreshold: Float            // Distance threshold for triggering engagement behavior
    var engagementDurations: [Int: TimeInterval] = [:] // Dictionary to track engagement time for each entity
    
    // MARK: - Initializer
    
    /// Initializes the EngagementTracker with entities to track and a proximity threshold.
    /// - Parameters:
    ///   - entities: An array of SceneNode instances to monitor for user engagement.
    ///   - proximityThreshold: The distance within which an entity is considered "engaged" by the user.
    init(entities: [SceneNode], proximityThreshold: Float) {
        self.trackedEntities = entities
        self.proximityThreshold = proximityThreshold
        self.userPosition = SIMD3<Float>(0, 0, 0) // Default initialization to ensure property is set
    }
    
    // MARK: - Position and Engagement Tracking
    
    /// Updates the user's position in the scene.
    /// - Parameter position: The new user position as a SIMD3<Float> vector.
    func updateUserPosition(position: SIMD3<Float>) {
        self.userPosition = position
    }
    
    /// Tracks engagement by measuring user proximity to each entity and adjusting behavior based on engagement duration.
    /// - Parameter deltaTime: The time increment since the last update, used to accumulate engagement time.
    /// - Returns: An array of indices representing entities currently within engagement range.
    func trackEngagement(deltaTime: TimeInterval) -> [Int] {
        var engagedEntities: [Int] = []
        
        for (index, entity) in trackedEntities.enumerated() {
            let distance = length(userPosition - entity.position)
            
            // Check if the user is within the proximity threshold for engagement
            if distance < proximityThreshold {
                engagedEntities.append(index)
                // Increment engagement time for this entity
                engagementDurations[index] = (engagementDurations[index] ?? 0) + deltaTime
                
                // Trigger entity adjustments if engagement duration exceeds threshold (e.g., 5 seconds)
                if let time = engagementDurations[index], time > 5.0 {
                    adjustEntityPosition(entity: entity)
                    entity.triggerAnimation(named: "engagementAnimation")
                }
            } else {
                // Reset engagement time if user moves out of range
                engagementDurations[index] = 0
            }
        }
        return engagedEntities
    }
    
    // MARK: - Adaptive Behavior
    
    /// Adjusts the position of the specified entity when engaged by the user.
    /// - Parameter entity: The SceneNode instance to adjust.
    private func adjustEntityPosition(entity: SceneNode) {
        entity.position += SIMD3<Float>(0.1, 0.0, 0.0) // Example: slight shift along the x-axis
    }
}

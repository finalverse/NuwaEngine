//
//  Behavior.swift
//  NuwaEngine - AetherModules/Behavior/Behavior.swift
//
//  Created by Wenyan Qin on 2024-11-08.
//

import Foundation
import simd

/// Enum defining AI behavior types for modular expansion
enum BehaviorType {
    case wander(bounds: SIMD3<Float>)
    case pursue(target: Entity)
    case flee(from: Entity)
    case patrol(points: [SIMD3<Float>])
    case idle
}

/// Protocol defining behavior methods that all behaviors must implement
protocol Behavior {
    var type: BehaviorType { get }
    func update(for entity: Entity, deltaTime: Float)
}

/// WanderBehavior for entities to move within random bounds.
class WanderBehavior: Behavior {
    var type: BehaviorType
    private var wanderDirection: SIMD3<Float>
    private let bounds: SIMD3<Float>

    init(bounds: SIMD3<Float>) {
        self.type = .wander(bounds: bounds)
        self.bounds = bounds
        self.wanderDirection = SIMD3<Float>(0.5, 0, 0.5)
    }

    /// Updates the entity’s position within the given bounds.
    /// - Parameters:
    ///   - entity: The entity to apply the wander behavior.
    ///   - deltaTime: The time elapsed since the last update.
    func update(for entity: Entity, deltaTime: Float) {
        entity.position += wanderDirection * deltaTime

        // Reverse direction if out of bounds
        if abs(entity.position.x) > bounds.x || abs(entity.position.z) > bounds.z {
            wanderDirection = -wanderDirection
        }
    }
}

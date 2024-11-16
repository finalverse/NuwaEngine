//
//  TerrainGenerator.swift
//  NuwaEngine - AetherModules/Procedural/TerrainGenerator.swift
//
//  Created by Wenyan Qin on 2024-11-08.
//

import Foundation
import simd
import Metal

/// Procedural generator for creating terrain based on noise functions, conforming to the `ProceduralGenerator` protocol.
class TerrainGenerator: ProceduralGenerator {
    let gridSize: Int         // Number of grid points in each dimension
    let maxHeight: Float      // Maximum height of terrain peaks
    private let shaderManager: ShaderManager

    /// Initializes the terrain generator with grid size, height range, and shader manager.
    /// - Parameters:
    ///   - gridSize: The number of grid points per dimension.
    ///   - maxHeight: The maximum height of the terrain.
    ///   - shaderManager: The shader manager for managing shaders used in terrain rendering.
    init(gridSize: Int, maxHeight: Float, shaderManager: ShaderManager) {
        self.gridSize = gridSize
        self.maxHeight = maxHeight
        self.shaderManager = shaderManager
    }

    /// Generates a terrain entity with procedurally generated vertices.
    /// - Parameter device: The Metal device used to create buffers for the terrain entity.
    /// - Returns: A procedurally generated `Entity` conforming to the protocol.
    func generate(device: MTLDevice) -> Entity {
        let terrainEntity = TerrainEntity(device: device, shaderManager: shaderManager, gridSize: gridSize, maxHeight: maxHeight)
        terrainEntity.generateVertices()
        return terrainEntity
    }
}

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

    /// Initializes the terrain generator with grid size and height range.
    init(gridSize: Int, maxHeight: Float) {
        self.gridSize = gridSize
        self.maxHeight = maxHeight
    }

    /// Generates a terrain entity with procedurally generated vertices.
    /// - Parameter device: The Metal device used to create buffers for the terrain entity.
    /// - Returns: A procedurally generated `TerrainEntity`.
    func generate(device: MTLDevice) -> Entity {
        let terrainEntity = TerrainEntity(device: device, gridSize: gridSize, maxHeight: maxHeight, uniformSize: MemoryLayout<Uniforms>.stride)
        terrainEntity.generateVertices()
        return terrainEntity
    }
}

/// Entity that represents procedurally generated terrain.
class TerrainEntity: Entity {
    private var vertices: [Vertex] = [] // Array to store generated vertices
    let gridSize: Int                   // Number of grid points per dimension
    let maxHeight: Float                // Maximum height of the terrain

    /// Initializes the terrain entity with grid size, max height, and device information for creating buffers.
    /// - Parameters:
    ///   - device: The Metal device used for buffer creation.
    ///   - gridSize: The number of grid points along each dimension.
    ///   - maxHeight: The maximum height of the terrain peaks.
    ///   - uniformSize: The size of the uniform buffer to allocate.
    init(device: MTLDevice, gridSize: Int, maxHeight: Float, uniformSize: Int) {
        self.gridSize = gridSize
        self.maxHeight = maxHeight
        super.init(device: device, uniformSize: uniformSize)
    }

    /// Generates vertices for the terrain based on noise functions, populating the vertex buffer.
    func generateVertices() {
        for x in 0..<gridSize {
            for z in 0..<gridSize {
                let height = perlinNoise(x: Float(x), z: Float(z)) * maxHeight
                vertices.append(Vertex(position: SIMD4<Float>(Float(x), height, Float(z), 1),
                                       color: SIMD4<Float>(0.3, 0.8, 0.3, 1), // Greenish terrain color
                                       normal: SIMD3<Float>(0, 1, 0),         // Upward normal
                                       texCoord: SIMD2<Float>(Float(x) / Float(gridSize), Float(z) / Float(gridSize))))
            }
        }
        setupVertexBuffer(with: vertices)
    }

    /// Sets up the vertex buffer for the terrain vertices.
    /// - Parameter vertices: The array of vertices to be stored in the buffer.
    private func setupVertexBuffer(with vertices: [Vertex]) {
        let dataSize = vertices.count * MemoryLayout<Vertex>.stride
        vertexBuffer = device?.makeBuffer(bytes: vertices, length: dataSize, options: [])
    }

    /// Simulates Perlin noise. Replace with a true Perlin noise function for more realistic terrain.
    private func perlinNoise(x: Float, z: Float) -> Float {
        return sin(x * 0.1) * cos(z * 0.1) // Simple wave-based height variation
    }
}

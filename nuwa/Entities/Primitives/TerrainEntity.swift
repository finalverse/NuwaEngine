//
//  TerrainEntity.swift
//  NuwaEngine
//
//  This file defines the `TerrainEntity` class, representing a procedurally generated terrain.
//  It creates a grid of vertices with height variations based on a noise function.
//
//  Created by Wenyan Qin on 2024-11-08.
//

import Foundation
import simd
import Metal

/// Entity that represents procedurally generated terrain.
class TerrainEntity: Entity {
    private var vertices: [Vertex] = []    // Array to store generated vertices
    let gridSize: Int                      // Number of grid points per dimension
    let maxHeight: Float                   // Maximum height of the terrain

    /// Initializes the terrain entity with grid size, max height, device, and shader manager.
    /// - Parameters:
    ///   - device: The Metal device used for buffer creation.
    ///   - shaderManager: The shader manager to manage shaders for the terrain entity.
    ///   - gridSize: The number of grid points along each dimension.
    ///   - maxHeight: The maximum height of the terrain peaks.
    init(device: MTLDevice, shaderManager: ShaderManager, gridSize: Int, maxHeight: Float) {
        self.gridSize = gridSize
        self.maxHeight = maxHeight
        super.init(device: device, shaderManager: shaderManager, lightingManager: LightingManager(device: device))
        
        // Generate vertices for the terrain
        generateVertices()
    }

    /// Generates vertices for the terrain based on a simplified noise function.
    /// Populates the vertex buffer with the generated vertices.
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
        vertexBuffer = device.makeBuffer(bytes: vertices, length: dataSize, options: [])
    }

    /// A simplified Perlin noise function for generating height variations.
    /// - Parameters:
    ///   - x: The x-coordinate in the grid.
    ///   - z: The z-coordinate in the grid.
    /// - Returns: A pseudo-random height value.
    private func perlinNoise(x: Float, z: Float) -> Float {
        return sin(x * 0.1) * cos(z * 0.1)  // Simple wave-based height variation
    }

    /// Draw function to render the terrain.
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard let vertexBuffer = vertexBuffer, let uniformBuffer = uniformBuffer else {
            print("Warning: Missing vertex or uniform buffer.")
            return
        }
        
        // Retrieve pipeline state from shaderManager
        guard let pipelineState = shaderManager.getPipelineState(vertexShaderName: "vertex_main", fragmentShaderName: "fragment_main") else {
            print("Error: Could not retrieve pipeline state.")
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        
        material?.bindToShader(renderEncoder: renderEncoder)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}

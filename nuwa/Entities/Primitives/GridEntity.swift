//
//  GridEntity.swift
//  NuwaEngine
//
//  Represents a ground plane grid with distinct colors for the X and Z axes, serving as a visual guide for the scene's coordinate space.
//  Updated to align with the latest ShaderTypes and rendering pipeline.
//
//  Updated by ChatGPT on 2024-11-19.
//

import Foundation
import MetalKit

/// `GridEntity` represents a ground plane grid with distinct colors for X and Z axes, and gray for other grid lines.
class GridEntity: Entity {
    private var gridVertices: [Vertex] = []    // Array to store grid vertices

    /// Initializes a `GridEntity` with specified grid size, spacing, device, shader manager, and lighting manager.
    /// - Parameters:
    ///   - device: The Metal device used for buffer creation.
    ///   - shaderManager: The shader manager for handling shaders.
    ///   - lightingManager: The lighting manager for managing lighting effects in the scene.
    ///   - gridSize: Total size of the grid (e.g., 10 for a 10x10 grid).
    ///   - gridSpacing: Distance between each line in the grid.
    init(device: MTLDevice, shaderManager: ShaderManager, lightingManager: LightingManager, gridSize: Float, gridSpacing: Float) {
        super.init(device: device, shaderManager: shaderManager, lightingManager: lightingManager)
        
        // Generate grid vertices and assign them to the buffer
        gridVertices = GridEntity.generateGridVertices(gridSize: gridSize, gridSpacing: gridSpacing)
        setupVertexBuffer()
    }

    /// Sets up the vertex buffer for the grid using the generated vertices.
    private func setupVertexBuffer() {
        let dataSize = gridVertices.count * MemoryLayout<Vertex>.stride
        vertexBuffer = device.makeBuffer(bytes: gridVertices, length: dataSize, options: [])
    }

    /// Generates vertices for the grid lines on the ground plane.
    /// - Parameters:
    ///   - gridSize: Total size of the grid (e.g., 10 for a 10x10 grid).
    ///   - gridSpacing: Distance between each line in the grid.
    /// - Returns: Array of vertices representing the grid lines.
    static func generateGridVertices(gridSize: Float, gridSpacing: Float) -> [Vertex] {
        var vertices: [Vertex] = []
        let halfSize = gridSize / 2
        let xAxisColor = SIMD4<Float>(1.0, 0.0, 0.0, 1.0)    // Red for X-axis
        let zAxisColor = SIMD4<Float>(0.0, 0.0, 1.0, 1.0)    // Blue for Z-axis
        let gridLineColor = SIMD4<Float>(0.5, 0.5, 0.5, 1.0) // Gray for other grid lines

        let tangent = SIMD3<Float>(1.0, 0.0, 0.0)            // Tangent for normal mapping
        let bitangent = SIMD3<Float>(0.0, 0.0, 1.0)          // Bitangent for normal mapping
        let instanceID: UInt32 = 0                           // Default instance ID for non-instanced rendering

        for i in stride(from: -halfSize, through: halfSize, by: gridSpacing) {
            // Vertical lines (parallel to the Z-axis)
            vertices.append(Vertex(position: SIMD4<Float>(i, 0, -halfSize, 1),
                                   color: i == 0 ? zAxisColor : gridLineColor,
                                   normal: SIMD3<Float>(0, 1, 0),
                                   texCoord: SIMD2<Float>(0, 0),
                                   tangent: tangent,
                                   bitangent: bitangent,
                                   instanceID: instanceID))
            vertices.append(Vertex(position: SIMD4<Float>(i, 0, halfSize, 1),
                                   color: i == 0 ? zAxisColor : gridLineColor,
                                   normal: SIMD3<Float>(0, 1, 0),
                                   texCoord: SIMD2<Float>(0, 0),
                                   tangent: tangent,
                                   bitangent: bitangent,
                                   instanceID: instanceID))

            // Horizontal lines (parallel to the X-axis)
            vertices.append(Vertex(position: SIMD4<Float>(-halfSize, 0, i, 1),
                                   color: i == 0 ? xAxisColor : gridLineColor,
                                   normal: SIMD3<Float>(0, 1, 0),
                                   texCoord: SIMD2<Float>(0, 0),
                                   tangent: tangent,
                                   bitangent: bitangent,
                                   instanceID: instanceID))
            vertices.append(Vertex(position: SIMD4<Float>(halfSize, 0, i, 1),
                                   color: i == 0 ? xAxisColor : gridLineColor,
                                   normal: SIMD3<Float>(0, 1, 0),
                                   texCoord: SIMD2<Float>(0, 0),
                                   tangent: tangent,
                                   bitangent: bitangent,
                                   instanceID: instanceID))
        }
        return vertices
    }

    /// Draw function to render the grid.
    /// - Parameter renderEncoder: The Metal render command encoder used for issuing rendering commands.
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        // Ensure all necessary resources are available
        guard let vertexBuffer = vertexBuffer,
              let uniformBuffer = uniformBuffer,
              let pipelineState = shaderManager.getPipelineState(
                vertexShaderName: "vertex_main",
                fragmentShaderName: "fragment_main",
                vertexDescriptor: createVertexDescriptor()
              ) else {
            print("Warning: Missing vertex buffer, uniform buffer, or pipeline state.")
            return
        }
        
        // Set the pipeline state for rendering
        renderEncoder.setRenderPipelineState(pipelineState)

        // Bind the vertex buffer at index 0
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Bind the uniform buffer at index 2 for both vertex and fragment shaders
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 2)
        
        // Draw the grid lines as line primitives
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: gridVertices.count)
    }
}

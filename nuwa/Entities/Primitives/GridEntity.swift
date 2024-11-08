//
//  GridEntity.swift
//  NuwaEngine
//
//  Updated by ChatGPT on 2024-11-08.
//

import Foundation
import MetalKit

/// `GridEntity` represents a ground plane grid with distinct colors for X and Z axes.
class GridEntity: Entity {
    private var gridVertices: [Vertex] = []
    
    init(device: MTLDevice, gridSize: Float, gridSpacing: Float) {
        super.init(device: device, uniformSize: MemoryLayout<Uniforms>.stride)
        
        // Generate grid vertices and assign them to the buffer
        gridVertices = GridEntity.generateGridVertices(gridSize: gridSize, gridSpacing: gridSpacing)
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

        for i in stride(from: -halfSize, through: halfSize, by: gridSpacing) {
            // Vertical lines (parallel to the Z-axis)
            vertices.append(Vertex(position: SIMD4<Float>(i, 0, -halfSize, 1),
                                   color: i == 0 ? zAxisColor : gridLineColor,
                                   normal: SIMD3<Float>(0, 1, 0),
                                   texCoord: SIMD2<Float>(0, 0)))
            vertices.append(Vertex(position: SIMD4<Float>(i, 0, halfSize, 1),
                                   color: i == 0 ? zAxisColor : gridLineColor,
                                   normal: SIMD3<Float>(0, 1, 0),
                                   texCoord: SIMD2<Float>(0, 0)))

            // Horizontal lines (parallel to the X-axis)
            vertices.append(Vertex(position: SIMD4<Float>(-halfSize, 0, i, 1),
                                   color: i == 0 ? xAxisColor : gridLineColor,
                                   normal: SIMD3<Float>(0, 1, 0),
                                   texCoord: SIMD2<Float>(0, 0)))
            vertices.append(Vertex(position: SIMD4<Float>(halfSize, 0, i, 1),
                                   color: i == 0 ? xAxisColor : gridLineColor,
                                   normal: SIMD3<Float>(0, 1, 0),
                                   texCoord: SIMD2<Float>(0, 0)))
        }
        return vertices
    }

    /// Draw function to render the grid
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard let vertexBuffer = vertexBuffer, let uniformBuffer = uniformBuffer else {
            print("Warning: Missing vertex or uniform buffer.")
            return
        }
        
        // Bind the vertex buffer at index 0
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Bind the uniform buffer at index 2 for both vertex and fragment shaders
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 2)
        
        // Draw the grid lines as line primitives
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: gridVertices.count)
    }
}

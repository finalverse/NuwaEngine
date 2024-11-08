//
//  AxisEntity.swift
//  NuwaEngine
//
//  Created by ChatGPT on 2024-11-08.
//

import Foundation
import MetalKit

/// `AxisEntity` represents the X, Y, and Z axes with distinct colors and arrowheads for visual guidance.
class AxisEntity: Entity {
    private var axisVertices: [Vertex] = []

    init(device: MTLDevice, axisLength: Float) {
        super.init(device: device, uniformSize: MemoryLayout<Uniforms>.stride)
        
        // Generate axis vertices with distinct colors for X, Y, and Z axes
        axisVertices = AxisEntity.generateAxisVertices(axisLength: axisLength)
        let dataSize = axisVertices.count * MemoryLayout<Vertex>.stride
        vertexBuffer = device.makeBuffer(bytes: axisVertices, length: dataSize, options: [])
    }

    /// Generates vertices for the X, Y, and Z axes with unique colors.
    /// - Parameter axisLength: Length of each axis line.
    /// - Returns: Array of vertices representing the three axes.
    static func generateAxisVertices(axisLength: Float) -> [Vertex] {
        let xColor = SIMD4<Float>(1.0, 0.0, 0.0, 1.0)  // Red for X-axis
        let yColor = SIMD4<Float>(0.0, 1.0, 0.0, 1.0)  // Green for Y-axis
        let zColor = SIMD4<Float>(0.0, 0.0, 1.0, 1.0)  // Blue for Z-axis
        
        var vertices: [Vertex] = []
        
        // X-axis line
        vertices.append(Vertex(position: SIMD4<Float>(0, 0, 0, 1), color: xColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)))
        vertices.append(Vertex(position: SIMD4<Float>(axisLength, 0, 0, 1), color: xColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)))
        
        // Y-axis line
        vertices.append(Vertex(position: SIMD4<Float>(0, 0, 0, 1), color: yColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)))
        vertices.append(Vertex(position: SIMD4<Float>(0, axisLength, 0, 1), color: yColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)))
        
        // Z-axis line
        vertices.append(Vertex(position: SIMD4<Float>(0, 0, 0, 1), color: zColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)))
        vertices.append(Vertex(position: SIMD4<Float>(0, 0, axisLength, 1), color: zColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)))
        
        return vertices
    }

    /// Draw function to render the axes
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
        
        // Draw the axis lines as line primitives
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: axisVertices.count)
    }
}

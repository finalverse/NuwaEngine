//
//  AxisEntity.swift
//  NuwaEngine
//
//  This file defines the `AxisEntity` class, which represents the X, Y, and Z axes in the scene.
//  Each axis is displayed with distinct colors and has arrowheads for visual orientation.
//  This class is useful for debugging or scene orientation purposes.
//
//  Created by ChatGPT on 2024-11-08.
//

import Foundation
import MetalKit

/// `AxisEntity` represents the X, Y, and Z axes with distinct colors and arrowheads for visual guidance.
class AxisEntity: Entity {
    private var axisVertices: [Vertex] = []  // Array to store vertices for the axis lines

    /// Initializes an `AxisEntity` to display the coordinate axes.
    /// - Parameters:
    ///   - device: The Metal device used for buffer creation.
    ///   - shaderManager: The shader manager for handling shaders.
    ///   - axisLength: Length of each axis line.
    init(device: MTLDevice, shaderManager: ShaderManager, lightingManager: LightingManager, axisLength: Float) {
        super.init(device: device, shaderManager: shaderManager, lightingManager: LightingManager(device: device))
        
        // Generate vertices for the axis lines and store them in the vertex buffer
        axisVertices = AxisEntity.generateAxisVertices(axisLength: axisLength)
        setupVertexBuffer()
    }

    /// Sets up the vertex buffer with generated vertices for the axis lines.
    private func setupVertexBuffer() {
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
        
        return [
            // X-axis line
            Vertex(position: SIMD4<Float>(0, 0, 0, 1), color: xColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)),
            Vertex(position: SIMD4<Float>(axisLength, 0, 0, 1), color: xColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)),
            
            // Y-axis line
            Vertex(position: SIMD4<Float>(0, 0, 0, 1), color: yColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)),
            Vertex(position: SIMD4<Float>(0, axisLength, 0, 1), color: yColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)),
            
            // Z-axis line
            Vertex(position: SIMD4<Float>(0, 0, 0, 1), color: zColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)),
            Vertex(position: SIMD4<Float>(0, 0, axisLength, 1), color: zColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0))
        ]
    }

    /// Draw function to render the axis lines.
    /// This function binds necessary resources and uses line primitives to render the axes.
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        // Ensure required resources are available
        guard let vertexBuffer = vertexBuffer,
              let uniformBuffer = uniformBuffer,
              let pipelineState = shaderManager.getPipelineState(vertexShaderName: "vertex_main", fragmentShaderName: "fragment_main") else {
            print("Warning: Missing vertex buffer, uniform buffer, or pipeline state.")
            return
        }
        
        // Set the pipeline state for rendering
        renderEncoder.setRenderPipelineState(pipelineState)

        // Bind the vertex buffer at index 0
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Bind the uniform buffer at index 1 for both vertex and fragment shaders
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        
        // Draw the axis lines as line primitives
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: axisVertices.count)
    }
}

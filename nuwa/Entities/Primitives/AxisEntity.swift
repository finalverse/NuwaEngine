//
//  AxisEntity.swift
//  NuwaEngine
//
//  This file defines the `AxisEntity` class, which represents the X, Y, and Z axes in the scene.
//  Each axis is displayed with distinct colors and has arrowheads for visual orientation.
//  This class is useful for debugging or scene orientation purposes.
//
//  Updated on 2024-11-19.
//

import Foundation
import MetalKit

/// `AxisEntity` represents the X, Y, and Z axes with distinct colors and arrowheads for visual guidance.
class AxisEntity: Entity {
    // MARK: - Properties

    private var axisVertices: [Vertex] = [] // Array to store vertices for the axis lines

    // MARK: - Initialization

    /// Initializes an `AxisEntity` to display the coordinate axes.
    /// - Parameters:
    ///   - device: The Metal device used for buffer creation.
    ///   - shaderManager: The shader manager for handling shaders.
    ///   - lightingManager: The lighting manager for the scene.
    ///   - axisLength: Length of each axis line.
    init(device: MTLDevice, shaderManager: ShaderManager, lightingManager: LightingManager, axisLength: Float) {
        super.init(device: device, shaderManager: shaderManager, lightingManager: lightingManager)
        
        // Generate vertices for the axis lines and store them in the vertex buffer
        axisVertices = AxisEntity.generateAxisVertices(axisLength: axisLength)
        setupVertexBuffer()
    }

    // MARK: - Vertex Buffer Setup

    /// Sets up the vertex buffer with generated vertices for the axis lines.
    private func setupVertexBuffer() {
        let dataSize = axisVertices.count * MemoryLayout<Vertex>.stride
        vertexBuffer = device.makeBuffer(bytes: axisVertices, length: dataSize, options: [])
    }

    // MARK: - Vertex Generation

    /// Generates vertices for the X, Y, and Z axes with unique colors.
    /// Each axis includes tangent, bitangent, and instance ID information for compatibility.
    /// - Parameter axisLength: Length of each axis line.
    /// - Returns: Array of vertices representing the three axes.
    static func generateAxisVertices(axisLength: Float) -> [Vertex] {
        let xColor = SIMD4<Float>(1.0, 0.0, 0.0, 1.0)  // Red for X-axis
        let yColor = SIMD4<Float>(0.0, 1.0, 0.0, 1.0)  // Green for Y-axis
        let zColor = SIMD4<Float>(0.0, 0.0, 1.0, 1.0)  // Blue for Z-axis
        
        let tangent = SIMD3<Float>(1.0, 0.0, 0.0)  // Tangent vector
        let bitangent = SIMD3<Float>(0.0, 1.0, 0.0) // Bitangent vector
        let instanceID: UInt32 = 0                 // Instance ID (not used for static axes)

        return [
            // X-axis line
            Vertex(position: SIMD4<Float>(0, 0, 0, 1), color: xColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0), tangent: tangent, bitangent: bitangent, instanceID: instanceID),
            Vertex(position: SIMD4<Float>(axisLength, 0, 0, 1), color: xColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0), tangent: tangent, bitangent: bitangent, instanceID: instanceID),
            
            // Y-axis line
            Vertex(position: SIMD4<Float>(0, 0, 0, 1), color: yColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0), tangent: tangent, bitangent: bitangent, instanceID: instanceID),
            Vertex(position: SIMD4<Float>(0, axisLength, 0, 1), color: yColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0), tangent: tangent, bitangent: bitangent, instanceID: instanceID),
            
            // Z-axis line
            Vertex(position: SIMD4<Float>(0, 0, 0, 1), color: zColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0), tangent: tangent, bitangent: bitangent, instanceID: instanceID),
            Vertex(position: SIMD4<Float>(0, 0, axisLength, 1), color: zColor, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0), tangent: tangent, bitangent: bitangent, instanceID: instanceID)
        ]
    }

    // MARK: - Rendering

    /// Draw function to render the axis lines.
    /// This function binds necessary resources and uses line primitives to render the axes.
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        // Ensure required resources are available
        guard let vertexBuffer = vertexBuffer,
              let uniformBuffer = uniformBuffer,
              let pipelineState = shaderManager.getPipelineState(
                  vertexShaderName: "vertex_main",
                  fragmentShaderName: "fragment_main",
                  vertexDescriptor: createVertexDescriptor() // Pass the vertex descriptor here
              ) else {
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

    /// Creates a vertex descriptor for the axis entity.
    /// - Returns: A configured `MTLVertexDescriptor`.
    override func createVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()

        // Position attribute
        vertexDescriptor.attributes[0].format = .float4   // Use float4 for position
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        // Color attribute
        vertexDescriptor.attributes[1].format = .float4   // Use float4 for color
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0

        // Normal attribute
        vertexDescriptor.attributes[2].format = .float3
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD4<Float>>.stride * 2
        vertexDescriptor.attributes[2].bufferIndex = 0

        // Texture coordinates
        vertexDescriptor.attributes[3].format = .float2
        vertexDescriptor.attributes[3].offset = MemoryLayout<SIMD4<Float>>.stride * 2 + MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[3].bufferIndex = 0

        // Tangent attribute
        vertexDescriptor.attributes[4].format = .float3
        vertexDescriptor.attributes[4].offset = MemoryLayout<SIMD4<Float>>.stride * 2 + MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD2<Float>>.stride
        vertexDescriptor.attributes[4].bufferIndex = 0

        // Bitangent attribute
        vertexDescriptor.attributes[5].format = .float3
        vertexDescriptor.attributes[5].offset = MemoryLayout<SIMD4<Float>>.stride * 2 + MemoryLayout<SIMD3<Float>>.stride * 2 + MemoryLayout<SIMD2<Float>>.stride
        vertexDescriptor.attributes[5].bufferIndex = 0

        // Set layout for the vertex buffer
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        vertexDescriptor.layouts[0].stepFunction = .perVertex

        return vertexDescriptor
    }
}

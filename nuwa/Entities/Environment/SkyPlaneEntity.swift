//
//  SkyPlaneEntity.swift
//  NuwaEngine
//
//  SkyPlaneEntity represents a large white plane at the back of the scene,
//  serving as a sky or background for the 3D environment.
//
//  Created by Wenyan Qin on 2024-11-09.
//

import Foundation
import MetalKit

/// `SkyPlaneEntity` represents a large white plane that serves as the sky or background in the scene.
class SkyPlaneEntity: Entity {
    private var skyVertices: [Vertex] = []      // Array holding the vertices of the sky plane
    
    /// Initializes a `SkyPlaneEntity` with the device, shader manager, and lighting manager.
    /// - Parameters:
    ///   - device: The Metal device used for buffer creation.
    ///   - shaderManager: The shader manager to handle shaders for rendering.
    ///   - lightingManager: The lighting manager to handle lighting effects for the entity.
    override init(device: MTLDevice, shaderManager: ShaderManager, lightingManager: LightingManager) {
        super.init(device: device, shaderManager: shaderManager, lightingManager: lightingManager)
        
        // Generate vertices for a large horizontal plane and set up the vertex buffer
        skyVertices = SkyPlaneEntity.generateSkyPlaneVertices()
        setupVertexBuffer()
    }
    
    /// Generates vertices for a large white plane to serve as the sky or background.
    /// - Returns: Array of vertices representing the sky plane.
    static func generateSkyPlaneVertices() -> [Vertex] {
        let color = SIMD4<Float>(1.0, 1.0, 1.0, 1.0) // White color for the sky plane
        let size: Float = 1000.0                      // Large size to cover the background
        
        return [
            Vertex(position: SIMD4<Float>(-size, -1, -size, 1), color: color, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)),
            Vertex(position: SIMD4<Float>(size, -1, -size, 1), color: color, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(1, 0)),
            Vertex(position: SIMD4<Float>(-size, -1, size, 1), color: color, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 1)),
            Vertex(position: SIMD4<Float>(size, -1, size, 1), color: color, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(1, 1))
        ]
    }
    
    /// Sets up the vertex buffer for the sky plane using the generated vertices.
    private func setupVertexBuffer() {
        let dataSize = skyVertices.count * MemoryLayout<Vertex>.stride
        vertexBuffer = device.makeBuffer(bytes: skyVertices, length: dataSize, options: [])
    }

    /// Draw function to render the sky plane.
    /// - Parameter renderEncoder: The Metal render command encoder used for issuing rendering commands.
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        // Ensure all necessary resources are available
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
        
        // Bind the uniform buffer at index 2 for both vertex and fragment shaders
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 2)
        
        // Draw the plane as a triangle strip to form a rectangle
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: skyVertices.count)
    }
}

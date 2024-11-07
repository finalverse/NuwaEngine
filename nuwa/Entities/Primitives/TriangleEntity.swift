//
//  TriangleEntity.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  TriangleEntity represents a simple triangle with position, color, and optional material properties.
//  It serves as a basic test entity for rendering and transformations.

import Metal
import simd

/// TriangleEntity represents a simple 2D triangle with vertex color, normal, and texture coordinates
/// that is rendered on the screen using Metal.
class TriangleEntity: Entity {
    /// The vertex buffer that holds the vertex data for the triangle
    //var vertexBuffer: MTLBuffer?

    /// Vertices for the triangle, each with position, color, normal, and texture coordinates
    private let vertices: [Vertex] = [
        Vertex(position: SIMD4<Float>(arrayLiteral: 0.0,  0.5, 0.0, 1.0),
               color:    SIMD4<Float>(1.0, 0.0, 0.0, 1.0),
               normal:   SIMD3<Float>(0, 0, 1),
               texCoord: SIMD2<Float>(0.5, 1.0)),                           // Top vertex
        Vertex(position: SIMD4<Float>(arrayLiteral: -0.5, -0.5, 0.0, 1.0),
               color:    SIMD4<Float>(0.0, 1.0, 0.0, 1.0),
               normal:   SIMD3<Float>(0, 0, 1),
               texCoord: SIMD2<Float>(0.0, 0.0)),                           // Bottom-left vertex
        Vertex(position: SIMD4<Float>(arrayLiteral: 0.5, -0.5, 0.0, 1.0),
               color:    SIMD4<Float>(0.0, 0.0, 1.0, 1.0),
               normal:   SIMD3<Float>(0, 0, 1),
               texCoord: SIMD2<Float>(1.0, 0.0))                            // Bottom-right vertex
    ]

    /// Initializes the triangle entity, setting up the vertex buffer and uniform buffer
    /// - Parameter device: The Metal device used to create buffers
    init(device: MTLDevice) {
        // Calculate the size of the uniform buffer based on the Uniforms struct
        let uniformSize = MemoryLayout<Uniforms>.size
        super.init(device: device, uniformSize: uniformSize)
        
        // Create the vertex buffer with the triangle's vertex data
        let dataSize = vertices.count * MemoryLayout<Vertex>.stride
        vertexBuffer = device.makeBuffer(bytes: vertices, length: dataSize, options: [])
    }

    /// Draws the triangle using the provided render encoder
    /// - Parameter renderEncoder: The Metal render command encoder used to issue drawing commands
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard let vertexBuffer = vertexBuffer else {
            print("Warning: Vertex buffer is not set.")
            return
        }
        guard let uniformBuffer = uniformBuffer else {
            print("Warning: Uniform buffer is not set.")
            return
        }

        // Set the vertex buffer at index 0
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Bind the uniform buffer at index 2 as expected by vertex_main
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        
        // Set additional buffers like the material and light information
        if let material = material {
            material.bindToShader(renderEncoder: renderEncoder)
        }

        // Calculate vertex count from buffer length
        let vertexCount = vertexBuffer.length / MemoryLayout<Vertex>.stride
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
    }
}

//
//  TriangleEntity.swift
//  NuwaEngine
//
//  This file defines the `TriangleEntity` class, representing a simple 2D triangle with a material.
//  It is useful for basic testing and rendering demonstrations.
//
//  Created by Wenyan Qin on 2024-11-08.
//  Updated on 2024-11-19.
//

import Metal
import simd

/// Represents a simple 2D triangle entity with a material.
class TriangleEntity: Entity {
    private let vertices: [Vertex] = [
        Vertex(
            position: SIMD4<Float>(0.0, 0.5, 0.0, 1.0),
            color: SIMD4<Float>(1.0, 0.0, 0.0, 1.0),
            normal: SIMD3<Float>(0, 0, 1),
            texCoord: SIMD2<Float>(0.5, 1.0),
            tangent: SIMD3<Float>(1, 0, 0),
            bitangent: SIMD3<Float>(0, 1, 0),
            instanceID: 0
        ),
        Vertex(
            position: SIMD4<Float>(-0.5, -0.5, 0.0, 1.0),
            color: SIMD4<Float>(0.0, 1.0, 0.0, 1.0),
            normal: SIMD3<Float>(0, 0, 1),
            texCoord: SIMD2<Float>(0.0, 0.0),
            tangent: SIMD3<Float>(1, 0, 0),
            bitangent: SIMD3<Float>(0, 1, 0),
            instanceID: 0
        ),
        Vertex(
            position: SIMD4<Float>(0.5, -0.5, 0.0, 1.0),
            color: SIMD4<Float>(0.0, 0.0, 1.0, 1.0),
            normal: SIMD3<Float>(0, 0, 1),
            texCoord: SIMD2<Float>(1.0, 0.0),
            tangent: SIMD3<Float>(1, 0, 0),
            bitangent: SIMD3<Float>(0, 1, 0),
            instanceID: 0
        )
    ]

    /// Initializes the triangle entity with device and shader manager.
    /// - Parameters:
    ///   - device: The Metal device used for buffer creation.
    ///   - shaderManager: The shader manager to manage shaders for the triangle entity.
    override init(device: MTLDevice, shaderManager: ShaderManager, lightingManager: LightingManager) {
        super.init(device: device, shaderManager: shaderManager, lightingManager: lightingManager)
        
        // Setup the vertex buffer with triangle vertices
        let dataSize = vertices.count * MemoryLayout<Vertex>.stride
        vertexBuffer = device.makeBuffer(bytes: vertices, length: dataSize, options: [])
        
        // Assign a basic material to the triangle
        material = Material(
            diffuseColor: SIMD3<Float>(1.0, 0.5, 0.5),
            specularColor: SIMD3<Float>(1.0, 1.0, 1.0),
            shininess: 32.0,
            hasTexture: false,
            device: device
        )
    }

    /// Draw function to render the triangle.
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard let vertexBuffer = vertexBuffer, let uniformBuffer = uniformBuffer else {
            print("Warning: Missing vertex or uniform buffer.")
            return
        }
        
        // Retrieve pipeline state from shaderManager
        guard let pipelineState = shaderManager.getPipelineState(
            vertexShaderName: "vertex_main",
            fragmentShaderName: "fragment_main",
            vertexDescriptor: createVertexDescriptor() // Ensure accessibility in `Entity`.
        ) else {
            print("Error: Could not retrieve pipeline state.")
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        
        // Bind material directly
        material.bindToShader(renderEncoder: renderEncoder)
        
        // Draw the triangle
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}

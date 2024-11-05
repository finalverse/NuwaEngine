//
//  TriangleEntity.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-05.
//

// TriangleEntity.swift
// A simple triangle entity with vertex data for rendering.

//  - Uniform Buffer: uniformBuffer holds the transformation matrix (modelMatrix) for this entity.
//  - Updating Transformation Matrix: In draw(renderEncoder:), we update uniformBuffer with the current transformation matrix from node.worldMatrix() before rendering.
//  - Binding the Buffer: We set uniformBuffer at index 1, matching the Uniforms buffer in the shader.

import Foundation
import MetalKit

class TriangleEntity: Entity {
    var vertexBuffer: MTLBuffer?
    
    // uniformBuffer holds the transformation matrix (modelMatrix) for this entity.
    var uniformBuffer: MTLBuffer?

    init(device: MTLDevice) {
        super.init(node: SceneNode())

        // Define vertices for a triangle with positions and colors
        let vertices: [Vertex] = [
            Vertex(position: SIMD4<Float>(0.0,  0.5, 0.0, 1.0), color: SIMD4<Float>(1.0, 0.0, 0.0, 1.0)), // Top (Red)
            Vertex(position: SIMD4<Float>(-0.5, -0.5, 0.0, 1.0), color: SIMD4<Float>(0.0, 1.0, 0.0, 1.0)), // Bottom Left (Green)
            Vertex(position: SIMD4<Float>(0.5, -0.5, 0.0, 1.0), color: SIMD4<Float>(0.0, 0.0, 1.0, 1.0))  // Bottom Right (Blue)
        ]

        // Create a vertex buffer for the triangle and transformation data
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: [])
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: [])
    }

    // Draw function to render the triangle
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard let vertexBuffer = vertexBuffer,
              let uniformBuffer = uniformBuffer else { return }

        // Update the transformation matrix
        var uniforms = Uniforms(modelMatrix: node.worldMatrix())
        memcpy(uniformBuffer.contents(), &uniforms, MemoryLayout<Uniforms>.stride)
        
        // Set buffers and draw
        //renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        //renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    }
}

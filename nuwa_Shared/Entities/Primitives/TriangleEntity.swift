//
//  TriangleEntity.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-05.
//

// TriangleEntity.swift
// A simple triangle entity with vertex data for rendering.

// update -------
//  - Uniform Buffer: uniformBuffer holds the transformation matrix (modelMatrix) for this entity.
//  - Updating Transformation Matrix: In draw(renderEncoder:), we update uniformBuffer with the current transformation matrix from node.worldMatrix() before rendering.
//  - Binding the Buffer: We set uniformBuffer at index 1, matching the Uniforms buffer in the shader.
// update -------
//  - TriangleEntity now uses the base Entity initializer, which sets up uniformBuffer.
//  - In the draw() function, we update uniformBuffer with the transformation matrix (modelMatrix) from node.worldMatrix().

import Foundation
import MetalKit

class TriangleEntity: Entity {
    var vertexBuffer: MTLBuffer?
    
    init(device: MTLDevice) {
        super.init(node: SceneNode(), device: device)
        
        // Define vertices for a triangle with positions, colors, and normals
        let vertices: [Vertex] = [
            Vertex(position: SIMD4<Float>(0.0,  0.5, 0.0, 1.0), color: SIMD4<Float>(1.0, 0.0, 0.0, 1.0), normal: SIMD3<Float>(0, 0, 1)), // Top (Red)
            Vertex(position: SIMD4<Float>(-0.5, -0.5, 0.0, 1.0), color: SIMD4<Float>(0.0, 1.0, 0.0, 1.0), normal: SIMD3<Float>(0, 0, 1)), // Bottom Left (Green)
            Vertex(position: SIMD4<Float>(0.5, -0.5, 0.0, 1.0), color: SIMD4<Float>(0.0, 0.0, 1.0, 1.0), normal: SIMD3<Float>(0, 0, 1))  // Bottom Right (Blue)
        ]

        // Create a vertex buffer for the triangle and transformation data
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: [])
    }

    // Draw function to render the triangle
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard let vertexBuffer = vertexBuffer, let uniformBuffer = uniformBuffer else { return }

        // Set the vertex buffer at index 0
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        // Set the uniforms buffer for both the vertex and fragment stages at index 1
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)

        // Draw the triangle
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    }
}

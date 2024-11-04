//
//  TriangleEntity.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-05.
//

// TriangleEntity.swift
// A simple triangle entity with vertex data for rendering.

import Foundation
import MetalKit

class TriangleEntity: Entity {
    var vertexBuffer: MTLBuffer?

    init(device: MTLDevice) {
        super.init(node: SceneNode())

        // Define vertices for a triangle with positions and colors
        let vertices: [Vertex] = [
            Vertex(position: SIMD4<Float>(0.0,  0.5, 0.0, 1.0), color: SIMD4<Float>(1.0, 0.0, 0.0, 1.0)), // Top (Red)
            Vertex(position: SIMD4<Float>(-0.5, -0.5, 0.0, 1.0), color: SIMD4<Float>(0.0, 1.0, 0.0, 1.0)), // Bottom Left (Green)
            Vertex(position: SIMD4<Float>(0.5, -0.5, 0.0, 1.0), color: SIMD4<Float>(0.0, 0.0, 1.0, 1.0))  // Bottom Right (Blue)
        ]

        // Create a vertex buffer for the triangle
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: [])
    }

    // Draw function to render the triangle
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard let vertexBuffer = vertexBuffer else { return }

        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    }
}

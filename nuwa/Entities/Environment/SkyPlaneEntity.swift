//
//  SkyPlaneEntity.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-09.
//
//  SkyPlaneEntity represents a large white plane at the back of the scene,
//  serving as a sky or background.

import Foundation
import MetalKit

/// `SkyPlaneEntity` represents a large white plane that serves as the sky or background in the scene.
class SkyPlaneEntity: Entity {
    private var skyVertices: [Vertex] = []
    
    init(device: MTLDevice) {
        super.init(device: device, uniformSize: MemoryLayout<Uniforms>.stride)
        
        // Generate vertices for a large horizontal plane
        skyVertices = SkyPlaneEntity.generateSkyPlaneVertices()
        let dataSize = skyVertices.count * MemoryLayout<Vertex>.stride
        vertexBuffer = device.makeBuffer(bytes: skyVertices, length: dataSize, options: [])
    }
    
    /// Generates vertices for a large white plane
    static func generateSkyPlaneVertices() -> [Vertex] {
        let color = SIMD4<Float>(1.0, 1.0, 1.0, 1.0) // White color for the sky plane
        let size: Float = 100000.0                      // Size of the sky plane (large enough to cover the background)
        
        return [
            Vertex(position: SIMD4<Float>(-size, -1, -size, 1), color: color, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 0)),
            Vertex(position: SIMD4<Float>(size, -1, -size, 1), color: color, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(1, 0)),
            Vertex(position: SIMD4<Float>(-size, -1, size, 1), color: color, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(0, 1)),
            Vertex(position: SIMD4<Float>(size, -1, size, 1), color: color, normal: SIMD3<Float>(0, 1, 0), texCoord: SIMD2<Float>(1, 1))
        ]
    }
    
    /// Draw function to render the sky plane
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
        
        // Draw the plane as a triangle strip to form a rectangle
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: skyVertices.count)
    }
}

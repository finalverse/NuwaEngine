//
//  Entity.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  Entity serves as a base class for all objects in the scene that can be rendered and updated.
//  It includes a transform, optional material, and optional animation.

import Foundation
import simd
import Metal

class Entity {
    var node: SceneNode                    // Transform node for position, rotation, scaling
    var material: Material?                // Optional material for rendering
    var animator: Animator?                // Optional animator for handling entity animations
    var device: MTLDevice?
    var vertexBuffer: MTLBuffer?           // Buffer for storing vertex data
    var uniformBuffer: MTLBuffer?          // Buffer for storing uniform data

    // Computed property for vertex count based on the vertex buffer length
    var vertexCount: Int {
        guard let vertexBuffer = vertexBuffer else { return 0 }
        return vertexBuffer.length / MemoryLayout<Vertex>.stride
    }
    
    init(device: MTLDevice, uniformSize: Int) {
        self.node = SceneNode()
        self.device = device
        
        // Initialize uniform buffer with specified size
        self.uniformBuffer = device.makeBuffer(length: uniformSize, options: .storageModeShared)
    }

    /// Updates the entity each frame, applying animations if present
    func update(deltaTime: Float) {
        animator?.update(deltaTime: deltaTime, node: node)
    }

    /// Updates the uniform buffer with the latest transformation and camera data
    func updateUniforms(viewProjectionMatrix: matrix_float4x4, cameraPosition: SIMD3<Float>) {
        guard let bufferPointer = uniformBuffer?.contents().bindMemory(to: Uniforms.self, capacity: 1) else { return }
        
        // Update the model and view-projection matrices, and the camera position
        bufferPointer.pointee.modelMatrix = node.worldMatrix()
        bufferPointer.pointee.viewProjectionMatrix = viewProjectionMatrix
        bufferPointer.pointee.cameraPosition = cameraPosition
    }
    
    /// Logs buffer information for debugging
    func logBufferInfo() {
        if let vertexBuffer = vertexBuffer {
            print("Vertex buffer size: \(vertexBuffer.length) bytes")
            print("Vertex count: \(vertexCount)")
        } else {
            print("No vertex buffer assigned.")
        }
        
        if let uniformBuffer = uniformBuffer {
            print("Uniform buffer size: \(uniformBuffer.length) bytes")
        } else {
            print("No uniform buffer assigned.")
        }
    }

    /// Draw function to be called by RenderSystem
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard let material = material else {
            print("Warning: Entity has no material assigned.")
            return
        }

        // Bind material properties to the render pipeline if needed
        material.bindToShader(renderEncoder: renderEncoder)

        // Bind vertex buffer and draw the entity
        if let vertexBuffer = vertexBuffer {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            // Assuming this is a triangle entity for now
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        } else {
            print("Warning: Entity has no vertex buffer assigned.")
        }
    }
}

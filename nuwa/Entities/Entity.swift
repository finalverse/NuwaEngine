//
//  Entity.swift
//  NuwaEngine
//
//  This file defines the `Entity` class, a base class for all renderable entities in the scene.
//  Each entity can have materials, textures, and interact with lighting effects through the `LightingManager`.
//  Additionally, adaptive behavior based on user proximity is included.
//
//  Created by Wenyan Qin on 2024-11-05.
//

import Foundation
import simd
import Metal

/// Base class for all renderable entities in the scene.
class Entity: SceneNode {
    
    let device: MTLDevice                    // Metal device for creating GPU resources
    var material: Material?                  // Material applied to the entity
    let shaderManager: ShaderManager         // Manages shaders for this entity
    var vertexBuffer: MTLBuffer?             // Buffer holding vertex data for rendering
    var vertexCount: Int = 0                 // Number of vertices in the buffer
    var uniformBuffer: MTLBuffer?            // Uniform buffer for transformation matrices
    var textures: [MTLTexture] = []          // Array to hold multiple textures
    var lightingManager: LightingManager?    // Manages scene lighting effects

    init(device: MTLDevice, shaderManager: ShaderManager, lightingManager: LightingManager) {
        self.device = device
        self.shaderManager = shaderManager
        self.lightingManager = lightingManager
        super.init()
        setupVertices()
        setupUniformBuffer()
    }

    /// Configures vertex data for the entity.
    private func setupVertices() {
        let vertices: [VertexIn] = [
            VertexIn(position: SIMD3<Float>(0.0,  0.5, 0.0),
                     color: SIMD4<Float>(1.0, 0.0, 0.0, 1.0),
                     normal: SIMD3<Float>(0, 0, 1),
                     texCoord: SIMD2<Float>(0.5, 1.0)),
            VertexIn(position: SIMD3<Float>(-0.5, -0.5, 0.0),
                     color: SIMD4<Float>(0.0, 1.0, 0.0, 1.0),
                     normal: SIMD3<Float>(0, 0, 1),
                     texCoord: SIMD2<Float>(0.0, 0.0)),
            VertexIn(position: SIMD3<Float>(0.5, -0.5, 0.0),
                     color: SIMD4<Float>(0.0, 0.0, 1.0, 1.0),
                     normal: SIMD3<Float>(0, 0, 1),
                     texCoord: SIMD2<Float>(1.0, 0.0))
        ]
        
        vertexCount = vertices.count
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride, options: [])
    }

    /// Sets up the uniform buffer to hold transformation matrices.
    private func setupUniformBuffer() {
        let bufferSize = MemoryLayout<matrix_float4x4>.stride
        uniformBuffer = device.makeBuffer(length: bufferSize, options: [])
    }

    /// Updates the uniform buffer with the model-view-projection matrix.
    func updateUniforms(viewProjectionMatrix: matrix_float4x4, cameraPosition: SIMD3<Float>) {
        let modelMatrix = worldMatrix()
        let modelViewProjectionMatrix = viewProjectionMatrix * modelMatrix

        if let buffer = uniformBuffer {
            let pointer = buffer.contents().assumingMemoryBound(to: matrix_float4x4.self)
            pointer.pointee = modelViewProjectionMatrix
        }
    }

    /// Draws the entity using the provided render command encoder.
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard let vertexBuffer = vertexBuffer,
              let uniformBuffer = uniformBuffer,
              let material = material else {
            print("Warning: Missing vertex buffer, uniform buffer, or material.")
            return
        }
        
        guard let pipelineState = shaderManager.getPipelineState(vertexShaderName: "vertex_main", fragmentShaderName: "fragment_main") else {
            print("Error: Could not retrieve pipeline state.")
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        
        material.bindToShader(renderEncoder: renderEncoder)

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
    }

    /// Sets the texture for the entity based on proximity.
    func setTexture(_ texture: MTLTexture) {
        // Sets a new texture dynamically, based on user proximity
    }

    /// Adjusts lighting intensity based on user proximity.
    func adjustLighting(userProximity: Float) {
        let maxProximity: Float = 50.0
        let intensity = max(0.2, 1.0 - (userProximity / maxProximity))
        lightingManager?.adjustIntensity(intensity)
    }

    /// Updates the texture of the entity based on user proximity.
    func updateTextureForProximity(userProximity: Float) {
        let proximityThreshold: Float = 25.0
        let textureIndex = Int(userProximity / proximityThreshold) % textures.count
        setTexture(textures[textureIndex])
    }

    /// Orients the entity to face the user.
    func orientEntityToUser(userPosition: SIMD3<Float>) {
        // Code for orientation, typically involving Quaternion calculations
    }

    /// Adjusts the scale of the entity based on proximity to the user.
    func scaleEntityForProximity(userProximity: Float) {
        let maxScaleDistance: Float = 30.0
        let scaleFactor = 1.0 + (1.0 - (userProximity / maxScaleDistance))
        setScale(SIMD3<Float>(scaleFactor, scaleFactor, scaleFactor))
    }
    
    /// Sets the scale of the entity.
    /// - Parameter scale: New scale for the entity as a SIMD3 vector.
    private func setScale(_ scale: SIMD3<Float>) {
        // Applies a scaling transformation to the entity
        // Modify the entity's transformation matrix or scale property accordingly
    }

    /// Triggers lighting changes based on user proximity.
    func proximityLightingTrigger(userProximity: Float) {
        let lightingChangeThreshold: Float = 15.0
        if userProximity < lightingChangeThreshold {
            lightingManager?.setColor(SIMD3<Float>(1.0, 0.7, 0.5))
        } else {
            lightingManager?.resetColor()
        }
    }

    /// Adjusts material properties based on user proximity.
    func updateMaterialBasedOnProximity(userProximity: Float) {
        let materialChangeThreshold: Float = 20.0
        if userProximity < materialChangeThreshold {
            material?.setRoughness(0.8)
            material?.setMetallic(0.4)
        } else {
            material?.resetProperties()
        }
    }
}

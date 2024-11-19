//
//  Entity.swift
//  NuwaEngine
//
//  This file defines the `Entity` class, a base class for all renderable entities in the scene.
//  Entities can manage their own shaders, materials, textures, and interact with scene lighting.
//  The design also considers future extensibility for subclasses.
//
//  Updated on 2024-11-19.
//

import Foundation
import simd
import Metal

/// Base class for all renderable entities in the scene.
class Entity: SceneNode {
    // MARK: - Properties

    let device: MTLDevice                      // Metal device for creating GPU resources
    var material: Material                     // Material applied to the entity
    let shaderManager: ShaderManager           // Manages shaders for this entity
    var vertexBuffer: MTLBuffer?               // Buffer holding vertex data for rendering
    var vertexCount: Int = 0                   // Number of vertices in the buffer
    var uniformBuffer: MTLBuffer?              // Uniform buffer for transformation matrices
    var textures: [MTLTexture] = []            // Array to hold multiple textures
    var lightingManager: LightingManager?      // Manages scene lighting effects

    /// Unique shader names for this entity, enabling different rendering techniques.
    var vertexShaderName: String = "defaultVertexShader"
    var fragmentShaderName: String = "defaultFragmentShader"

    // MARK: - Initialization

    /// Initializes an entity with essential managers and GPU resources.
    init(device: MTLDevice, shaderManager: ShaderManager, lightingManager: LightingManager) {
        self.device = device
        self.shaderManager = shaderManager
        self.lightingManager = lightingManager

        // Default material with basic properties
        self.material = Material(
            diffuseColor: SIMD3<Float>(1.0, 1.0, 1.0),
            specularColor: SIMD3<Float>(1.0, 1.0, 1.0),
            shininess: 32.0,
            hasTexture: false,
            device: device
        )

        super.init()
        setupVertices()
        setupUniformBuffer()
    }

    
    // MARK: - Animation Overrides (Optional)

    /// Handles the logic for animations specific to entities.
    /// - Parameter animationName: The name of the animation being played.
    override func handleAnimation(named animationName: String) {
        super.handleAnimation(named: animationName)
        if animationName == "engagementAnimation" {
            print("Entity-specific animation logic for '\(animationName)'")
        }
    }
    
    // MARK: - Setup Methods

    /// Configures vertex data for the entity.
    private func setupVertices() {
        let vertices: [VertexIn] = [
            VertexIn(position: SIMD3<Float>(0.0, 0.5, 0.0),
                     color: SIMD4<Float>(1.0, 0.0, 0.0, 1.0),
                     normal: SIMD3<Float>(0, 0, 1),
                     texCoord: SIMD2<Float>(0.5, 1.0),
                     tangent: SIMD3<Float>(1, 0, 0),
                     bitangent: SIMD3<Float>(0, 1, 0)),
            VertexIn(position: SIMD3<Float>(-0.5, -0.5, 0.0),
                     color: SIMD4<Float>(0.0, 1.0, 0.0, 1.0),
                     normal: SIMD3<Float>(0, 0, 1),
                     texCoord: SIMD2<Float>(0.0, 0.0),
                     tangent: SIMD3<Float>(1, 0, 0),
                     bitangent: SIMD3<Float>(0, 1, 0)),
            VertexIn(position: SIMD3<Float>(0.5, -0.5, 0.0),
                     color: SIMD4<Float>(0.0, 0.0, 1.0, 1.0),
                     normal: SIMD3<Float>(0, 0, 1),
                     texCoord: SIMD2<Float>(1.0, 0.0),
                     tangent: SIMD3<Float>(1, 0, 0),
                     bitangent: SIMD3<Float>(0, 1, 0))
        ]
        
        vertexCount = vertices.count
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride, options: [])
    }

    /// Sets up the uniform buffer to hold transformation matrices and material data.
    private func setupUniformBuffer() {
        let bufferSize = MemoryLayout<Uniforms>.stride
        uniformBuffer = device.makeBuffer(length: bufferSize, options: [])
    }

    // MARK: - Updates

    /// Updates the uniform buffer with the model-view-projection matrix, camera position, and material data.
    /// - Parameters:
    ///   - viewProjectionMatrix: The combined view-projection matrix for transforming vertices.
    ///   - cameraPosition: The position of the camera in world space.
    func updateUniforms(viewProjectionMatrix: matrix_float4x4, cameraPosition: SIMD3<Float>) {
        guard let buffer = uniformBuffer else {
            print("Error: Uniform buffer is not initialized.")
            return
        }

        // Convert Material (class) to MaterialProperties (struct)
        let shaderMaterial = material.toShaderMaterial()

        // Populate the Uniforms struct
        var uniforms = Uniforms(
            modelMatrix: worldMatrix(),
            viewProjectionMatrix: viewProjectionMatrix,
            cameraPosition: cameraPosition,
            padding: 0,
            material: shaderMaterial // Correctly using MaterialProperties
        )

        // Copy the uniforms into the uniform buffer
        memcpy(buffer.contents(), &uniforms, MemoryLayout<Uniforms>.stride)
    }
    
    // MARK: - Rendering

    /// Draws the entity using the provided render command encoder.
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        guard let vertexBuffer = vertexBuffer,
              let uniformBuffer = uniformBuffer else {
            print("Warning: Missing vertex buffer or uniform buffer.")
            return
        }

        // Retrieve the pipeline state for the entity's shaders
        guard let pipelineState = shaderManager.getPipelineState(
            vertexShaderName: vertexShaderName,
            fragmentShaderName: fragmentShaderName,
            vertexDescriptor: createVertexDescriptor()
        ) else {
            print("Error: Could not retrieve pipeline state.")
            return
        }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: Int(BufferIndexUniforms.rawValue))

        if let lightBuffer = lightingManager?.buffer {
            renderEncoder.setFragmentBuffer(lightBuffer, offset: 0, index: Int(BufferIndexLights.rawValue))
        }

        material.bindToShader(renderEncoder: renderEncoder)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
    }

    // MARK: - Helper Methods

    /// Creates a vertex descriptor for the vertex buffer layout.
    /// - Returns: A configured `MTLVertexDescriptor`.
    func createVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()

        vertexDescriptor.attributes[0].format = .float3   // Position
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        vertexDescriptor.attributes[1].format = .float4   // Color
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0

        vertexDescriptor.attributes[2].format = .float3   // Normal
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[2].bufferIndex = 0

        vertexDescriptor.attributes[3].format = .float2   // Texture Coordinates
        vertexDescriptor.attributes[3].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride + MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[3].bufferIndex = 0

        vertexDescriptor.layouts[0].stride = MemoryLayout<VertexIn>.stride
        vertexDescriptor.layouts[0].stepFunction = .perVertex

        return vertexDescriptor
    }

    // MARK: - Extensibility for Subclasses

    /// Updates material and other properties dynamically for subclasses.
    func updateMaterialForDynamicBehaviors() {
        // Override in subclasses for custom material updates
    }
}

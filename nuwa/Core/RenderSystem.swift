//
//  RenderSystem.swift
//  nuwa
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  RenderSystem manages the Metal rendering pipeline, setting up shaders, buffers, and rendering entities in the scene.
//  It handles lighting and materials, and efficiently manages buffers for optimized performance.

import MetalKit

class RenderSystem {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState?
    var clearColor: MTLClearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    var camera: Camera?
    var sceneLights: [SceneLight] = []
    var sceneLightBuffer: MTLBuffer?

    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        setupPipeline()
    }

    /// Configures the Metal pipeline with vertex and fragment shaders, and prepares the vertex descriptor
    private func setupPipeline() {
        guard let library = device.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "vertex_main"),
              let fragmentFunction = library.makeFunction(name: "fragment_main") else {
            print("Failed to create Metal shader functions.")
            return
        }

        let vertexDescriptor = MTLVertexDescriptor()
        
        // Position attribute at index 0, using buffer index 0
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        // Color attribute at index 1, using buffer index 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        // Normal attribute at index 2, using buffer index 0
        vertexDescriptor.attributes[2].format = .float3
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD4<Float>>.stride * 2
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        // Texture coordinates attribute at index 3, using buffer index 0
        vertexDescriptor.attributes[3].format = .float2
        vertexDescriptor.attributes[3].offset = MemoryLayout<SIMD4<Float>>.stride * 2 + MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[3].bufferIndex = 0
        
        // Set stride for buffer index 0, which includes all vertex attributes
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        vertexDescriptor.layouts[0].stepFunction = .perVertex

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            print("Pipeline state successfully created.")
        } catch {
            print("Failed to create pipeline state: \(error)")
        }
    }

    /// Adds a new light to the scene and updates the light buffer
    func addSceneLight(_ sceneLight: SceneLight) {
        sceneLights.append(sceneLight)
        updateSceneLightBuffer()
    }

    /// Updates the buffer for scene lights to store up to 3 lights
    private func updateSceneLightBuffer() {
        let lightCount = min(sceneLights.count, 3) // Limit to 3 lights for simplicity
        let sceneLightDataSize = MemoryLayout<SceneLight>.stride * lightCount
        sceneLightBuffer = device.makeBuffer(bytes: sceneLights, length: sceneLightDataSize, options: [])
    }

    /// Updates each entity in the scene and applies transformations
    func update(scene: Scene, deltaTime: Float) {
        for entity in scene.entities {
            entity.update(deltaTime: deltaTime)
        }
    }

    /// Renders all entities in the scene with camera and lighting information
    func render(scene: Scene, drawable: CAMetalDrawable) {
        guard let pipelineState = pipelineState,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let camera = camera else {
            return
        }

        // Create and configure renderPassDescriptor
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].clearColor = clearColor
        //renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderEncoder.setRenderPipelineState(pipelineState)

        // Compute the view-projection matrix
        let viewProjectionMatrix = camera.projectionMatrix() * camera.viewMatrix()
        var lightCount = min(sceneLights.count, 3)

        for entity in scene.entities {
            // Update uniforms with the latest transformations and camera data
            entity.updateUniforms(viewProjectionMatrix: viewProjectionMatrix, cameraPosition: camera.position)

            // Bind the entity's uniform buffer to the vertex and fragment shaders
            if let uniformBuffer = entity.uniformBuffer {
                renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
            }

            // Bind the vertex buffer if it exists (e.g., for TriangleEntity)
            if let vertexBuffer = entity.vertexBuffer {
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            }

            // Bind the sceneLightBuffer and lightCount to the fragment shader
            renderEncoder.setFragmentBuffer(sceneLightBuffer, offset: 0, index: 2)
            renderEncoder.setFragmentBytes(&lightCount, length: MemoryLayout<Int32>.size, index: 3)

            // Draw the entity
            entity.draw(renderEncoder: renderEncoder)
        }
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

}

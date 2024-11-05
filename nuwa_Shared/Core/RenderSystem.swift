//
//  RenderSystem.swift
//  nuwa Core
//
//  Created by Wenyan Qin on 2024-11-05.
//

//import Foundation

// RenderSystem.swift
// create: ------
//  - Manages the rendering pipeline using Metal and renders all entities in the scene.
// update: ------
//  - Add a camera parameter to RenderSystem.
//  - Update the render() method to use the camera’s view and projection matrices.
// update: ------
//  - update(scene:deltaTime:): This method iterates over all entities in the scene and updates their SceneNode with the elapsed time, applying animations if they’re present.
// update: ------
//  - set up a basic SceneLight manager in RenderSystem to add and manage SceneLights.
//  - SceneLight Array: RenderSystem has a SceneLights array to store up to 3 SceneLights (matching the shader).
//  - Set SceneLights: Before rendering each entity, we pass the SceneLights array to the shader via the uniforms buffer.
// update: ------
//  - SceneLight Buffer: SceneLightBuffer is a MTLBuffer created to hold an array of SceneLight structs. updateSceneLightBuffer() allocates memory for this buffer based on the current number of SceneLights.
//  - Setting SceneLights and SceneLightCount: Each frame, we set uniforms.pointee.SceneLights to the address of SceneLightBuffer and uniforms.pointee.SceneLightCount to the number of SceneLights, making these accessible in the shader.
//  - Limit to 3 Lights: In updateSceneLightBuffer, we limit sceneLights to the first 3 lights (limitedLights) before creating the buffer. This ensures that we don’t exceed the fixed-size array defined in ShaderTypes.h.
//  - Update sceneLightCount Safely: We set sceneLightCount to min(sceneLights.count, 3) in render to reflect the actual number of lights in the buffer.

import MetalKit

class RenderSystem {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState?
    var clearColor: MTLClearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    var camera: Camera?                     // add camera parameter
    var sceneLights: [NuwaLight] = []       // Store sceneLights in the scene
    var sceneLightBuffer: MTLBuffer?        // Buffer to hold sceneLight data for the GPU

    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        setupPipeline()
    }

    // Sets up the Metal rendering pipeline with a basic shader and vertex descriptor.
    private func setupPipeline() {
        guard let library = device.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "vertex_main"),
              let fragmentFunction = library.makeFunction(name: "fragment_main") else {
            print("Failed to create Metal shader functions.")
            return
        }

        // Configure the vertex descriptor to match VertexIn structure in Shader.metal
        let vertexDescriptor = MTLVertexDescriptor()
        
        // - Position Attribute (Index 0): The position data (float4) is set at index 0 with no offset.
        // - Color Attribute (Index 1): The color data (float4) is set at index 1 with an offset based on the size of the position.
        // - Normal Attribute (Index 2): The normal data (float3) is set at index 2, with an offset accounting for both the position and color attributes.
        // - Stride Calculation: The stride now includes position + color + normal to ensure each vertex has the full data required.
                                                                                                                
        // Position attribute at index 0
        vertexDescriptor.attributes[0].format = .float4       // `position` is a float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        // Color attribute at index 1
        vertexDescriptor.attributes[1].format = .float4       // `color` is a float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0

        // Normal attribute at index 2
        vertexDescriptor.attributes[2].format = .float3       // `normal` is a float3
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD4<Float>>.stride * 2
        vertexDescriptor.attributes[2].bufferIndex = 0

        // Set stride for a single vertex (position + color + normal)
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD4<Float>>.stride * 2 + MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.layouts[0].stepFunction = .perVertex

        // Create the pipeline descriptor and attach vertex descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = vertexDescriptor  // Attach the vertex descriptor here

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create pipeline state: \(error)")
        }
    }

    func addSceneLight(_ sceneLight: NuwaLight) {
        sceneLights.append(sceneLight)
        updateSceneLightBuffer()
    }
    
    private func updateSceneLightBuffer() {
        // Limit to 3 lights to match the shader's fixed-size array
        let limitedLights = Array(sceneLights.prefix(3))
        
        // Allocate buffer for up to 3 lights
        let sceneLightDataSize = MemoryLayout<NuwaLight>.stride * limitedLights.count
        sceneLightBuffer = device.makeBuffer(bytes: limitedLights, length: sceneLightDataSize, options: [])
    }
    
    func update(scene: Scene, deltaTime: Float) {
        scene.entities.forEach { $0.node.update(deltaTime: deltaTime) }
    }
    
    func render(scene: Scene, drawable: CAMetalDrawable) {
        guard let pipelineState = pipelineState,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].clearColor = clearColor
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
              let camera = camera else {
            return
        }

        // Set the pipeline state once at the beginning of the render pass
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // Compute the view-projection matrix
        let viewProjectionMatrix = camera.projectionMatrix() * camera.viewMatrix()

        for entity in scene.entities {
            // Update entity’s uniform buffer with view-projection matrix
            if let uniforms = entity.uniformBuffer?.contents().bindMemory(to: Uniforms.self, capacity: 1) {
                uniforms.pointee.modelMatrix = entity.node.worldMatrix()
                uniforms.pointee.viewProjectionMatrix = viewProjectionMatrix
                uniforms.pointee.cameraPosition = camera.position

                // Set sceneLights and sceneLightCount
                if let lightsPointer = sceneLightBuffer?.contents().assumingMemoryBound(to: NuwaLight.self) {
                    // Assign up to 3 lights individually, matching the tuple layout
                    if sceneLights.count > 0 {
                        uniforms.pointee.sceneLights.0 = lightsPointer[0]
                    }
                    if sceneLights.count > 1 {
                        uniforms.pointee.sceneLights.1 = lightsPointer[1]
                    }
                    if sceneLights.count > 2 {
                        uniforms.pointee.sceneLights.2 = lightsPointer[2]
                    }
                    uniforms.pointee.sceneLightCount = Int32(min(sceneLights.count, 3))
                }
            }
            entity.draw(renderEncoder: renderEncoder)
        }

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

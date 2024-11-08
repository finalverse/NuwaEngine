//
//  RenderSystem.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  RenderSystem manages the rendering pipeline using Metal and renders all entities in the scene.
//  It also configures lighting, material, and future advanced effects such as deferred shading and shadow mapping.
//

import MetalKit

/// RenderSystem is responsible for setting up the Metal rendering pipeline and rendering entities with proper shaders.
class RenderSystem {
    let device: MTLDevice                  // The Metal device
    let commandQueue: MTLCommandQueue      // Command queue for issuing render commands
    var pipelineState: MTLRenderPipelineState?  // Render pipeline state
    var depthState: MTLDepthStencilState?       // Depth stencil state for depth testing
    var clearColor: MTLClearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Clear color for rendering
    var camera: Camera?                    // Camera for view and projection matrices
    var sceneLights: [SceneLight] = []     // Collection of lights in the scene
    var sceneLightBuffer: MTLBuffer?       // Buffer for storing light data
    var shaderLibrary: MTLLibrary?         // Shader library containing all compiled Metal shaders
    var depthTexture: MTLTexture?          // Depth texture for depth testing

    /// Initializes the RenderSystem with a device, prepares the pipeline, and sets up shader resources.
    init(device: MTLDevice, viewSize: CGSize) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        setupPipeline()
        setupDepthStencil()
        updateDepthTexture(size: viewSize)  // Ensure depth texture is initialized with the correct view size
    }

    /// Configures the Metal rendering pipeline, loading shaders and setting up the vertex descriptor.
    private func setupPipeline() {
        do {
            shaderLibrary = device.makeDefaultLibrary()
            guard let library = shaderLibrary,
                  let vertexFunction = library.makeFunction(name: "vertex_main"),
                  let fragmentFunction = library.makeFunction(name: "fragment_main") else {
                print("Failed to create Metal shader functions.")
                return
            }

            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].format = .float4       // Position attribute
            vertexDescriptor.attributes[1].format = .float4       // Color attribute
            vertexDescriptor.attributes[2].format = .float3       // Normal attribute
            vertexDescriptor.attributes[3].format = .float2       // Texture coordinates attribute
            vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
            vertexDescriptor.layouts[0].stepFunction = .perVertex

            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.vertexDescriptor = vertexDescriptor
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            //print("Pipeline state successfully created.")

        } catch {
            print("Failed to create pipeline state: \(error)")
        }
    }

    /// Sets up the depth stencil state for depth testing.
    private func setupDepthStencil() {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        depthState = device.makeDepthStencilState(descriptor: depthDescriptor)
    }

    /// Updates the depth texture based on the view's drawable size.
    func updateDepthTexture(size: CGSize) {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                  width: Int(size.width),
                                                                  height: Int(size.height),
                                                                  mipmapped: false)
        descriptor.usage = .renderTarget
        descriptor.storageMode = .private
        depthTexture = device.makeTexture(descriptor: descriptor)
        
        if depthTexture == nil {
            print("Failed to create depth texture.")
        } else {
            //print("Depth texture successfully created.")
        }
    }

    /// Adds a new light to the scene and updates the light buffer for rendering.
    func addSceneLight(_ sceneLight: SceneLight) {
        sceneLights.append(sceneLight)
        updateSceneLightBuffer()
    }

    /// Updates the buffer for scene lights, storing up to 3 lights.
    private func updateSceneLightBuffer() {
        let lightCount = min(sceneLights.count, 3)  // Limit to 3 lights for simplicity
        var limitedLights = Array(sceneLights.prefix(lightCount))
        
        // Calculate the buffer size based on the aligned size of SceneLight
        // Calculate buffer size: aligned size of SceneLight (48 bytes) * number of lights
        //let sceneLightDataSize = 48 * lightCount
        let sceneLightDataSize = MemoryLayout<SceneLight>.stride * lightCount
        
        //print("MemoryLayout<SceneLight>.stride = \(MemoryLayout<SceneLight>.stride)")
        //print("SceneLight size: \(MemoryLayout<SceneLight>.size)")    // Should be 48 bytes
        //print("SceneLight stride: \(MemoryLayout<SceneLight>.stride)") // Should also be 48 bytes
        //print("sceneLightDataSize = \(sceneLightDataSize)")
        
        sceneLightBuffer = device.makeBuffer(bytes: &limitedLights, length: sceneLightDataSize, options: [])
    }

    /// Updates each entity in the scene with transformations, animations, and lighting.
    func update(scene: Scene, deltaTime: Float) {
        for entity in scene.entities {
            entity.update(deltaTime: deltaTime)
            entity.updateUniforms(viewProjectionMatrix: camera?.viewProjectionMatrix ?? matrix_identity_float4x4,
                                  cameraPosition: camera?.position ?? SIMD3<Float>(0, 0, 0))
        }
        updateSceneLightBuffer()  // Refresh light buffer for rendering
    }
    

    /// Renders all entities in the scene, handling lights, materials, and other properties.
    /// Renders all entities in the scene, handling lights, materials, and other properties.
    func render(scene: Scene, drawable: CAMetalDrawable) {
        guard let pipelineState = pipelineState,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = createRenderPassDescriptor(for: drawable),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
              let camera = camera else {
            print("Render setup incomplete: Missing pipeline, command buffer, or render pass descriptor.")
            return
        }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        
        // Set the viewProjection matrix and camera position for each entity
        let viewProjectionMatrix = camera.projectionMatrix() * camera.viewMatrix()
        var lightCount = Int32(min(sceneLights.count, 3))

        // Update and set the light buffer
        if let sceneLightBuffer = sceneLightBuffer {
            renderEncoder.setFragmentBuffer(sceneLightBuffer, offset: 0, index: 3) // Use raw value 3 for BufferIndexLights
        }

        // Bind the light count as a separate buffer
        renderEncoder.setFragmentBytes(&lightCount, length: MemoryLayout<Int32>.stride, index: 4) // Use raw value 4 for BufferIndexLightCount

        // Render each entity in the scene
        for entity in scene.entities {
            //print("Rendering entity: \(entity)") //debugging output
            // Ensure uniform buffer is set to the correct index expected by the vertex shader
            if let uniformBuffer = entity.uniformBuffer {
                //renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
                //renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 2)
                renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2) // Use raw value 2 for BufferIndexUniforms
                renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 2)

            }

            // Bind the vertex buffer
            if let vertexBuffer = entity.vertexBuffer {
                // Use raw value 0 for BufferIndexMeshPositions
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                //renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: BufferIndexMeshPositions.rawValue)
            }
            
            // Bind material properties if present
            if let material = entity.material {
                material.bindToShader(renderEncoder: renderEncoder)
            }

            // Draw the entity
            let vertexCount = entity.vertexCount
            //print("Drawing entity with vertex count: \(entity.vertexCount)") // for debugging
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: entity.vertexCount)
        }

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    /// Creates a render pass descriptor for the drawable, setting up color and depth attachments.
    private func createRenderPassDescriptor(for drawable: CAMetalDrawable) -> MTLRenderPassDescriptor? {
        guard let depthTexture = depthTexture else {
            print("Warning: Depth texture is not set.")
            return nil  // Early exit if depth texture isn't available
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        
        // Configure color attachment
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].clearColor = clearColor
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // Configure depth attachment
        renderPassDescriptor.depthAttachment.texture = depthTexture
        renderPassDescriptor.depthAttachment.clearDepth = 1.0
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .dontCare
        
        return renderPassDescriptor
    }
}

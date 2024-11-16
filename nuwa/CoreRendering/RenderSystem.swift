//
//  RenderSystem.swift
//  NuwaEngine
//
//  This file manages the Metal rendering pipeline, including shaders, depth, and entity updates.
//  It provides functions to render a scene with proper depth and lighting configurations.
//
//  Created by Wenyan Qin on 2024-11-05.
//

import MetalKit

/// Manages the rendering pipeline, shaders, and depth configurations for rendering entities in a scene.
class RenderSystem {
    // MARK: - Properties

    let device: MTLDevice                                  // Metal device used for rendering
    let commandQueue: MTLCommandQueue                      // Queue to organize and execute rendering commands
    var depthState: MTLDepthStencilState?                  // Depth stencil state for enabling depth testing
    var clearColor: MTLClearColor = MTLClearColor(red: 0.7, green: 0.6, blue: 0.9, alpha: 1.0) // Background clear color (light purple)
    //var clearColor: MTLClearColor = MTLClearColor(red: 0.8, green: 0.7, blue: 1.0, alpha: 1.0) // Background clear color (light purple)
    var camera: Camera?                                    // Camera providing view and projection matrices
    var lightingManager: LightingManager?                  // Manages the lights in the scene
    let shaderManager: ShaderManager                       // Manages shaders and pipeline states for rendering
    
    private var depthTexture: MTLTexture?                  // Depth texture for depth testing

    // MARK: - Initialization

    /// Initializes the RenderSystem with the specified device, view size, and shader manager.
    /// - Parameters:
    ///   - device: The Metal device to use for rendering.
    ///   - viewSize: The size of the rendering view, used to initialize depth texture.
    ///   - shaderManager: The ShaderManager to handle shader pipelines.
    init(device: MTLDevice, viewSize: CGSize, shaderManager: ShaderManager) {
        self.device = device
        self.shaderManager = shaderManager
        self.commandQueue = device.makeCommandQueue()!
        setupDepthStencil()
        updateViewSize(size: viewSize)
    }

    // MARK: - Setup Methods

    /// Sets up the depth stencil state to enable depth testing.
    private func setupDepthStencil() {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less       // Closer pixels overwrite farther pixels
        depthDescriptor.isDepthWriteEnabled = true         // Enable writing to the depth buffer
        depthState = device.makeDepthStencilState(descriptor: depthDescriptor)
    }

    /// Updates the depth texture based on the new view size.
    /// - Parameter size: The new size of the view, used to update the depth texture.
    func updateViewSize(size: CGSize) {
        guard size.width > 0 && size.height > 0 else {
            //print("Warning: Ignoring updateViewSize() call with zero dimensions (\(size.width) x \(size.height)).")
            return
        }
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                  width: Int(size.width),
                                                                  height: Int(size.height),
                                                                  mipmapped: false)
        descriptor.usage = .renderTarget
        descriptor.storageMode = .private
        depthTexture = device.makeTexture(descriptor: descriptor)
        
        print("Depth texture created with dimensions: \(Int(size.width)) x \(Int(size.height))")
    }

    // MARK: - Scene Updates

    /// Updates each entity in the scene for a given frame.
    /// - Parameters:
    ///   - scene: The scene containing all entities to update.
    ///   - deltaTime: The time elapsed since the last frame, used for animations and movements.
    func update(scene: Scene, deltaTime: Float) {
        for entity in scene.entities {
            entity.update(deltaTime: deltaTime)
        }
    }

    // MARK: - Rendering

    /// Renders all entities within the scene to the provided drawable.
    /// - Parameters:
    ///   - scene: The scene containing all entities to render.
    ///   - drawable: The drawable surface where the content will be presented.
    
    func render(scene: Scene, drawable: CAMetalDrawable?) {
        //guard let drawable = drawable else { return }
        guard let drawable = drawable else {
            print("Error: Drawable is nil.")
            return
        }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = createRenderPassDescriptor(for: drawable) else { return }
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        renderEncoder.setDepthStencilState(depthState)

        // Bind lighting buffer
        if let lightBuffer = lightingManager?.buffer {
            renderEncoder.setFragmentBuffer(lightBuffer, offset: 0, index: Int(BufferIndexLights.rawValue))
        }

        // Camera setup ---
        // Get the view-projection matrix from the camera
        let viewProjectionMatrix = camera?.viewProjectionMatrix ?? matrix_identity_float4x4
        for entity in scene.entities {
            entity.updateUniforms(viewProjectionMatrix: viewProjectionMatrix, cameraPosition: camera?.position ?? SIMD3<Float>(0, 0, 0))

            // Set the pipeline state for each entity
            if let pipelineState = shaderManager.getPipelineState(vertexShaderName: "vertex_main", fragmentShaderName: "fragment_main") {
                renderEncoder.setRenderPipelineState(pipelineState)
            }
            entity.draw(renderEncoder: renderEncoder)
        }

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    /*
    // test render() with a Minimal Render Pass
    func render(scene: Scene, drawable: CAMetalDrawable?) {
        guard let drawable = drawable else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = createRenderPassDescriptor(for: drawable) else { return }

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
     */

    // MARK: - Helper Methods

    /// Creates a render pass descriptor configured for the drawable's color and depth attachments.
    /// - Parameter drawable: The drawable for which the render pass descriptor is created.
    /// - Returns: A configured render pass descriptor or nil if the depth texture is unavailable.
    private func createRenderPassDescriptor(for drawable: CAMetalDrawable) -> MTLRenderPassDescriptor? {
        guard let depthTexture = depthTexture else { return nil }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].clearColor = clearColor
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        renderPassDescriptor.depthAttachment.texture = depthTexture
        renderPassDescriptor.depthAttachment.clearDepth = 1.0
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .dontCare
        
        return renderPassDescriptor
    }
    
    /// Creates a vertex descriptor for the vertex buffer layout.
    /// - Returns: A configured MTLVertexDescriptor.
    func createVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()

        // Position attribute
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        // Color attribute
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0

        // Normal attribute
        vertexDescriptor.attributes[2].format = .float3
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[2].bufferIndex = 0

        // TexCoord attribute
        vertexDescriptor.attributes[3].format = .float2
        vertexDescriptor.attributes[3].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride + MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[3].bufferIndex = 0

        // Layout for vertex buffer
        vertexDescriptor.layouts[0].stride = MemoryLayout<VertexIn>.stride
        vertexDescriptor.layouts[0].stepFunction = .perVertex

        return vertexDescriptor
    }
}

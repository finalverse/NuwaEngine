//
//  RenderSystem.swift
//  NuwaEngine
//
//  Manages the Metal rendering pipeline, including shaders, depth testing, lighting, and entity rendering.
//  Supports multiple shaders and ensures compatibility with dynamic rendering features.
//
//  Created by Wenyan Qin on 2024-11-05. Updated on 2024-11-19.
//

import MetalKit

/// Manages the Metal rendering pipeline, shaders, lighting, and depth configurations for rendering entities in a scene.
class RenderSystem {
    // MARK: - Properties

    let device: MTLDevice                                  // Metal device used for rendering
    let commandQueue: MTLCommandQueue                      // Queue to organize and execute rendering commands
    var depthState: MTLDepthStencilState?                  // Depth stencil state for enabling depth testing
    var clearColor: MTLClearColor = MTLClearColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0) // Background clear color
    var camera: Camera?                                    // Camera providing view and projection matrices
    var lightingManager: LightingManager?                  // Manages the lights in the scene
    let shaderManager: ShaderManager                       // Manages shaders and pipeline states
    let materialManager: MaterialManager                   // Manages textures and materials for entities

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
        self.materialManager = MaterialManager(device: device)
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
            print("Warning: Ignoring updateViewSize() with zero dimensions (\(size.width) x \(size.height)).")
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

        // Bind per-frame camera matrix
        let viewProjectionMatrix = camera?.viewProjectionMatrix ?? matrix_identity_float4x4
        let cameraPosition = camera?.position ?? SIMD3<Float>(0, 0, 0)

        // Draw each entity
        for entity in scene.entities {
            // Update entity uniforms
            entity.updateUniforms(viewProjectionMatrix: viewProjectionMatrix, cameraPosition: cameraPosition)

            // Select appropriate shaders based on entity type
            let vertexShader = entity.vertexShaderName ?? "vertex_main"
            let fragmentShader = entity.fragmentShaderName ?? "fragment_main"

            // Get or create the pipeline state
            if let pipelineState = shaderManager.getPipelineState(
                vertexShaderName: vertexShader,
                fragmentShaderName: fragmentShader,
                vertexDescriptor: createVertexDescriptor()
            ) {
                renderEncoder.setRenderPipelineState(pipelineState)
            }

            // Apply material properties
            materialManager.applyMaterial(entity.material, to: renderEncoder)

            // Draw the entity
            entity.draw(renderEncoder: renderEncoder)
        }

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

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
        vertexDescriptor.attributes[Int(VertexAttributePosition.rawValue)].format = .float3
        vertexDescriptor.attributes[Int(VertexAttributePosition.rawValue)].offset = 0
        vertexDescriptor.attributes[Int(VertexAttributePosition.rawValue)].bufferIndex = 0

        // Color attribute
        vertexDescriptor.attributes[Int(VertexAttributeColor.rawValue)].format = .float4
        vertexDescriptor.attributes[Int(VertexAttributeColor.rawValue)].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[Int(VertexAttributeColor.rawValue)].bufferIndex = 0

        // Normal attribute
        vertexDescriptor.attributes[Int(VertexAttributeNormal.rawValue)].format = .float3
        vertexDescriptor.attributes[Int(VertexAttributeNormal.rawValue)].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[Int(VertexAttributeNormal.rawValue)].bufferIndex = 0

        // TexCoord attribute
        vertexDescriptor.attributes[Int(VertexAttributeTexcoord.rawValue)].format = .float2
        vertexDescriptor.attributes[Int(VertexAttributeTexcoord.rawValue)].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride + MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[Int(VertexAttributeTexcoord.rawValue)].bufferIndex = 0

        // Layout for vertex buffer
        vertexDescriptor.layouts[0].stride = MemoryLayout<VertexIn>.stride
        vertexDescriptor.layouts[0].stepFunction = .perVertex

        return vertexDescriptor
    }
}

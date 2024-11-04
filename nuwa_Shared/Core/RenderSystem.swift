//
//  RenderSystem.swift
//  nuwa Core
//
//  Created by Wenyan Qin on 2024-11-05.
//

//import Foundation

// RenderSystem.swift
// Manages the rendering pipeline using Metal and renders all entities in the scene.

import MetalKit

class RenderSystem {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState?
    var clearColor: MTLClearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

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
        
        // Position attribute at index 0
        vertexDescriptor.attributes[0].format = .float4       // `position` is a float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        // Color attribute at index 1
        vertexDescriptor.attributes[1].format = .float4       // `color` is a float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0

        // Set stride for a single vertex (position + color)
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD4<Float>>.stride * 2
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

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderEncoder.setRenderPipelineState(pipelineState)

        for entity in scene.entities {
            entity.draw(renderEncoder: renderEncoder)
        }

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

//
//  ShaderManager.swift
//  NuwaEngine
//
//  This file manages the loading of Metal shaders, creation of pipeline states, and caching for efficient rendering.
//
//  Created by Wenyan Qin on 2024-11-10.
//

import Foundation
import Metal

/// Manages the loading of Metal shader functions and creation of render pipeline states.
class ShaderManager {
    private let device: MTLDevice                       // Metal device used for shader creation
    private var library: MTLLibrary?                    // Shader library loaded from the app bundle
    private var pipelineStates: [String: MTLRenderPipelineState] = [:] // Cache of pipeline states

    /// Initializes the `ShaderManager` and loads the shader library.
    /// - Parameter device: The Metal device used to load shaders and create pipeline states.
    init(device: MTLDevice) {
        self.device = device
        loadLibrary()
    }

    /// Loads the shader library from the app bundle.
    private func loadLibrary() {
        do {
            library = try device.makeDefaultLibrary(bundle: Bundle.main)
            print("Shader library successfully loaded.")
        } catch {
            print("Error: Failed to load shader library: \(error)")
        }
    }

    /// Retrieves a Metal function from the shader library.
    /// - Parameter name: The name of the shader function.
    /// - Returns: The `MTLFunction` or `nil` if the function is not found.
    func getFunction(named name: String) -> MTLFunction? {
        guard let library = library else {
            print("Error: Shader library is not loaded.")
            return nil
        }
        return library.makeFunction(name: name)
    }

    /// Retrieves or creates a render pipeline state for the specified vertex and fragment shaders.
    /// - Parameters:
    ///   - vertexShaderName: The name of the vertex shader.
    ///   - fragmentShaderName: The name of the fragment shader.
    /// - Returns: The `MTLRenderPipelineState` or `nil` if creation fails.
    func getPipelineState(vertexShaderName: String, fragmentShaderName: String) -> MTLRenderPipelineState? {
        let key = "\(vertexShaderName)-\(fragmentShaderName)"

        // Return cached pipeline state if available
        if let pipelineState = pipelineStates[key] {
            return pipelineState
        }

        // Create a new pipeline state
        guard let vertexFunction = getFunction(named: vertexShaderName),
              let fragmentFunction = getFunction(named: fragmentShaderName) else {
            print("Error: Could not load shaders \(vertexShaderName) and \(fragmentShaderName).")
            return nil
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = RenderSystem(device: device, viewSize: .zero, shaderManager: self).createVertexDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        do {
            let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            pipelineStates[key] = pipelineState // Cache the pipeline state
            return pipelineState
        } catch {
            print("Error: Failed to create pipeline state: \(error)")
            return nil
        }
    }
}

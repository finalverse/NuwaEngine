//
//  ShaderManager.swift
//  NuwaEngine
//
//  Manages Metal shader functions and pipeline states. Supports caching
//  and dynamic shader retrieval for flexible rendering pipelines.
//
//  Created by Wenyan Qin on 2024-11-10. Updated on 2024-11-19.
//

import Foundation
import Metal

/// Handles Metal shader loading, pipeline state creation, and caching.
class ShaderManager {
    private let device: MTLDevice                          // Metal device used for shader operations
    private var library: MTLLibrary?                      // Shader library loaded from the app bundle
    private var pipelineStates: [String: MTLRenderPipelineState] = [:] // Cached pipeline states

    /// Initializes the `ShaderManager` and loads the shader library.
    /// - Parameter device: Metal device for shader operations.
    init(device: MTLDevice) {
        self.device = device
        loadLibrary()
    }

    /// Loads the shader library from the app bundle.
    private func loadLibrary() {
        do {
            library = try device.makeDefaultLibrary(bundle: Bundle.main)
            print("Shader library loaded successfully.")
        } catch {
            print("Error: Failed to load shader library - \(error)")
        }
    }

    /// Retrieves a Metal function from the shader library.
    /// - Parameter name: Shader function name.
    /// - Returns: The `MTLFunction`, or nil if not found.
    func getFunction(named name: String) -> MTLFunction? {
        guard let library = library else {
            print("Error: Shader library not loaded.")
            return nil
        }
        return library.makeFunction(name: name)
    }

    /// Retrieves or creates a pipeline state for the specified vertex and fragment shaders.
    /// - Parameters:
    ///   - vertexShaderName: Vertex shader function name.
    ///   - fragmentShaderName: Fragment shader function name.
    ///   - vertexDescriptor: Vertex descriptor for pipeline configuration.
    /// - Returns: A configured `MTLRenderPipelineState` or nil if creation fails.
    func getPipelineState(vertexShaderName: String, fragmentShaderName: String, vertexDescriptor: MTLVertexDescriptor) -> MTLRenderPipelineState? {
        let key = "\(vertexShaderName)-\(fragmentShaderName)"

        // Return cached pipeline state if available
        if let cachedState = pipelineStates[key] {
            return cachedState
        }

        // Create a new pipeline state
        guard let vertexFunction = getFunction(named: vertexShaderName),
              let fragmentFunction = getFunction(named: fragmentShaderName) else {
            print("Error: Failed to load shaders \(vertexShaderName) and \(fragmentShaderName).")
            return nil
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        do {
            let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            pipelineStates[key] = pipelineState // Cache pipeline state
            return pipelineState
        } catch {
            print("Error: Failed to create pipeline state - \(error)")
            return nil
        }
    }
    
    // If a “default pipeline” is required (e.g., for debugging or fallback purposes)
    func getDefaultPipelineState(vertexDescriptor: MTLVertexDescriptor) -> MTLRenderPipelineState? {
        return getPipelineState(vertexShaderName: "phongVertexShader",
                                fragmentShaderName: "phongFragmentShader",
                                vertexDescriptor: vertexDescriptor)
    }
}

//
//  LightingManager.swift
//  NuwaEngine
//
//  `LightingManager` manages all lights within the scene, storing them in a buffer compatible with Metal for efficient GPU access.
//  It includes functions to adjust light intensity and color dynamically.
//
//  Created by Wenyan Qin on 2024-11-09.
//

import Foundation
import Metal

/// Manages lights within the scene and maintains a buffer for GPU access to lighting data.
class LightingManager {
    private var lights: [LightData] = []         // List of all lights in the scene
    private var lightBuffer: MTLBuffer?          // Buffer for GPU access to light data
    private let device: MTLDevice                // Metal device used to create the buffer

    /// Initializes the `LightingManager` with the provided device.
    /// - Parameter device: The Metal device used to create the light buffer.
    init(device: MTLDevice) {
        self.device = device
        updateLightBuffer() // Initialize the light buffer
    }

    /// Provides access to the light buffer for use in render encoders.
    var buffer: MTLBuffer? {
        return lightBuffer
    }

    /// Adds a light to the manager and updates the buffer.
    /// - Parameter light: The light to be added.
    func addLight(_ light: LightData) {
        lights.append(light)
        updateLightBuffer()
    }

    /// Removes a light from the manager and updates the buffer.
    /// - Parameter light: The light to be removed.
    func removeLight(_ light: LightData) {
        lights.removeAll { $0 === light }
        updateLightBuffer()
    }

    /// Adjusts the intensity of all lights.
    /// - Parameter intensity: New intensity value to apply to each light.
    func adjustIntensity(_ intensity: Float) {
        for i in 0..<lights.count {
            lights[i].intensity = intensity
        }
        updateLightBuffer()
    }

    /// Sets a color for all lights.
    /// - Parameter color: New color to apply to each light.
    func setColor(_ color: SIMD3<Float>) {
        for i in 0..<lights.count {
            lights[i].color = color
        }
        updateLightBuffer()
    }

    /// Resets lights to their default color (white).
    func resetColor() {
        for i in 0..<lights.count {
            lights[i].color = SIMD3<Float>(1.0, 1.0, 1.0)
        }
        updateLightBuffer()
    }

    /// Updates the light buffer with the current lights in the scene.
    /// Ensures the buffer is correctly aligned for Metal's expectations.
    func updateLightBuffer() {
        guard !lights.isEmpty else {
            lightBuffer = nil // Clear the buffer if no lights exist
            return
        }

        // Ensure correct memory layout and alignment for Metal
        let dataSize = lights.count * MemoryLayout<LightData>.stride

        // Create a new buffer with shared storage mode for CPU-GPU access
        lightBuffer = device.makeBuffer(bytes: lights, length: dataSize, options: .storageModeShared)
    }
}

//
//  ProceduralGenerator.swift
//  NuwaEngine - AetherModules/Procedural/ProceduralGenerator.swift
//
//  Created by Wenyan Qin on 2024-11-08.
//
import Foundation
import Metal

/// Protocol for procedural generators, defining a method for procedural creation
protocol ProceduralGenerator {
    func generate(device: MTLDevice) -> Entity
}

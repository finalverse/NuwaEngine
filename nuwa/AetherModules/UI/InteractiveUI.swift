//
//  InteractiveUI.swift
//  NuwaEngine
//
//  Created by Wenyan Qin on 2024-11-08.
//

import Foundation
import MetalKit

/// Base class for interactive UI elements that are rendered in the 3D scene
class InteractiveUI {
    func update() {
        // Override to update UI state based on interaction or data
    }

    func draw(renderEncoder: MTLRenderCommandEncoder) {
        // Override to render the UI element
    }
}

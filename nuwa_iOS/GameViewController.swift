//
//  GameViewController.swift
//  nuwa iOS
//
//  Created by Wenyan Qin on 2024-11-05.
//

// Parent Transformation: parentTriangle is positioned to the right and rotated 45 degrees.
// Child Inheritance: childTriangle is positioned relative to parentTriangle, so it will move and rotate along with its parent.

import UIKit
import MetalKit

// Our iOS specific view controller
class GameViewController: UIViewController {
    var metalView: MTKView!
    var renderSystem: RenderSystem!
    var scene: Scene!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the Metal view
        metalView = MTKView(frame: self.view.bounds, device: MTLCreateSystemDefaultDevice())
        guard let device = metalView.device else {
            fatalError("Metal is not supported on this device")
        }
        
        // Set up RenderSystem and Scene
        renderSystem = RenderSystem(device: device)
        scene = Scene()
        
        // Create the parent triangle
        let parentTriangle = TriangleEntity(device: device)
        parentTriangle.node.position = SIMD3<Float>(0.2, 0.0, 0.0)      // Offset to the right
        parentTriangle.node.rotation = SIMD3<Float>(0.0, 0.0, .pi / 4)  // 45-degree rotation

        // Create the child triangle, attached to the parent
        let childTriangle = TriangleEntity(device: device)
        childTriangle.node.position = SIMD3<Float>(0.5, 0.0, 0.0)       // Offset from parent

        // Set up the hierarchy
        parentTriangle.node.addChild(childTriangle.node)

        // Add the entities to the scene
        scene.addEntity(parentTriangle)
        scene.addEntity(childTriangle)

        // Configure Metal view properties
        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(0.2, 0.2, 0.2, 1.0)
        metalView.framebufferOnly = true

        self.view.addSubview(metalView)
    }
}

// Extension to handle Metal view's rendering delegate methods
extension GameViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle size changes if needed
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        renderSystem.render(scene: scene, drawable: drawable)
    }
}

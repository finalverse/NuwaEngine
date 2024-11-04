//
//  GameViewController.swift
//  nuwa iOS
//
//  Created by Wenyan Qin on 2024-11-05.
//

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
        
        // Add a TriangleEntity to the scene
        let triangle = TriangleEntity(device: device)
        scene.addEntity(triangle)

        // Configure Metal view
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

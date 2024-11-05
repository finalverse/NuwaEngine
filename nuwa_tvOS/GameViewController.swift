//
//  GameViewController.swift
//  nuwa tvOS
//
//  Created by Wenyan Qin on 2024-11-05.
//

import UIKit
import MetalKit

// Our tvOS/iOS specific view controller
import UIKit
import MetalKit

class GameViewController: UIViewController {
    var metalView: MTKView!
    var renderSystem: RenderSystem!
    var scene: Scene!

    override func viewDidLoad() {
        super.viewDidLoad()

        metalView = MTKView(frame: self.view.bounds, device: MTLCreateSystemDefaultDevice())
        guard let device = metalView.device else {
            fatalError("Metal is not supported on this device")
        }

        renderSystem = RenderSystem(device: device)
        scene = Scene()

        // Set up the camera
        let camera = Camera()
        camera.aspectRatio = Float(metalView.drawableSize.width / metalView.drawableSize.height)
        renderSystem.camera = camera

        // Add entities to the scene
        let parentTriangle = TriangleEntity(device: device)
        parentTriangle.node.position = SIMD3<Float>(0.2, 0.0, 0.0)
        parentTriangle.node.rotation = SIMD3<Float>(0.0, 0.0, .pi / 4)

        let childTriangle = TriangleEntity(device: device)
        childTriangle.node.position = SIMD3<Float>(0.5, 0.0, 0.0)
        parentTriangle.node.addChild(childTriangle.node)

        scene.addEntity(parentTriangle)
        scene.addEntity(childTriangle)

        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(0.2, 0.2, 0.2, 1.0)
        metalView.framebufferOnly = true
        self.view.addSubview(metalView)
    }
}

extension GameViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle size changes if needed
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        renderSystem.render(scene: scene, drawable: drawable)
    }
}

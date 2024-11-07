//
//  GameViewController.swift
//  nuwa iOS
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  iOS-specific GameViewController for managing Metal view setup, rendering, and updates.

import UIKit
import MetalKit

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
        
        renderSystem = RenderSystem(device: device)
        scene = Scene()

        let camera = Camera()
        camera.position = SIMD3<Float>(0, 0, -5)
        camera.aspectRatio = Float(metalView.drawableSize.width / metalView.drawableSize.height)
        renderSystem.camera = camera

        addLightsAndEntities()
        
        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(0.2, 0.2, 0.2, 1.0)
        metalView.framebufferOnly = true
        self.view.addSubview(metalView)
    }
    
    private func addLightsAndEntities() {
        // Add lights
        renderSystem.addSceneLight(SceneLight(type: .ambient, color: SIMD3<Float>(1, 1, 1), intensity: 0.2))
        renderSystem.addSceneLight(SceneLight(type: .directional, color: SIMD3<Float>(1, 1, 1), intensity: 0.8, direction: SIMD3(1, -1, 0)))
        
        // Add a test entity (triangle)
        let triangle = TriangleEntity(device: metalView.device!)
        triangle.node.position = SIMD3<Float>(0.0, 0.0, 0.0)
        scene.addEntity(triangle)
    }
}

extension GameViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderSystem.camera?.aspectRatio = Float(size.width / size.height)
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        let deltaTime: Float = 1.0 / Float(view.preferredFramesPerSecond)
        renderSystem.update(scene: scene, deltaTime: deltaTime)
        renderSystem.render(scene: scene, drawable: drawable)
    }
}

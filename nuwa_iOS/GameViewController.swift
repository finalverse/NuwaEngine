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
    var camera: Camera!
    var cameraAngle: Float = 0.0  // Starting angle for the camera rotation
    var cameraTimer: Timer?       // Timer to handle camera updates

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the Metal view
        metalView = MTKView(frame: self.view.bounds, device: MTLCreateSystemDefaultDevice())
        guard let device = metalView.device else {
            fatalError("Metal is not supported on this device")
        }

        renderSystem = RenderSystem(device: device, viewSize: metalView.drawableSize)
        scene = Scene()
        
        // Initialize and configure the camera
        camera = Camera()
        camera.position = SIMD3<Float>(3, 3, 10)
        camera.lookAt(SIMD3<Float>(0, 0, 0))
        camera.aspectRatio = Float(metalView.drawableSize.width / metalView.drawableSize.height)
        renderSystem.camera = camera

        addLightsAndEntities()

        // Configure the Metal view for rendering
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.sampleCount = 1
        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(0.2, 0.2, 0.2, 1.0)
        metalView.framebufferOnly = true
        
        self.view.addSubview(metalView)
        
        // Start the camera animation timer for a 360-degree orbit
        startCameraAnimation()
    }
    
    /// Starts a timer to rotate the camera around the origin, giving a 360-degree view.
    func startCameraAnimation() {
        cameraTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Increment the camera angle
            self.cameraAngle += 0.01
            if self.cameraAngle >= 2 * .pi {  // Reset angle after a full rotation
                self.cameraAngle = 0
            }
            
            // Calculate new camera position on a circular path
            let radius: Float = 10.0
            let x = radius * cos(self.cameraAngle)
            let z = radius * sin(self.cameraAngle)
            
            // Update camera position and look-at target
            self.camera.position = SIMD3<Float>(x, 2.0, z) // Keep a slight height for better view
            self.camera.lookAt(SIMD3<Float>(0, 0, 0))       // Always look at the origin
            
            self.renderSystem.camera = self.camera
        }
    }

    private func addLightsAndEntities() {
        guard let device = metalView.device else {
            print("Error: Metal device is not available.")
            return
        }

        // Add lights
        renderSystem.addSceneLight(SceneLight(type: .ambient, color: SIMD3<Float>(1, 1, 1), intensity: 0.2))
        renderSystem.addSceneLight(SceneLight(type: .directional, color: SIMD3<Float>(1, 1, 1), intensity: 0.8, direction: SIMD3(1, -1, 0)))

        // Add grid and axis entities
        let gridEntity = GridEntity(device: device, gridSize: 10.0, gridSpacing: 0.5)
        scene.addEntity(gridEntity)
        
        let axisEntity = AxisEntity(device: device, axisLength: 2.0)
        scene.addEntity(axisEntity)

        // Add a test entity (triangle)
        let triangle = TriangleEntity(device: device)
        triangle.node.position = SIMD3<Float>(0.0, 0.0, 0.0)
        scene.addEntity(triangle)
    }
}

extension GameViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderSystem.updateDepthTexture(size: size)
        renderSystem.camera?.aspectRatio = Float(size.width / size.height)
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        let deltaTime: Float = 1.0 / Float(view.preferredFramesPerSecond)
        renderSystem.update(scene: scene, deltaTime: deltaTime)
        renderSystem.render(scene: scene, drawable: drawable)
    }
}

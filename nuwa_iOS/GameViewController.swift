//
//  GameViewController.swift
//  nuwa iOS
//
//  Handles Metal view setup, rendering, and updates for the NuwaEngine on iOS.
//

import UIKit
import MetalKit

class GameViewController: UIViewController {
    var metalView: MTKView!
    var renderSystem: RenderSystem!
    var scene: Scene!
    var camera: Camera!
    var cameraAngle: Float = 0.0
    var cameraTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the Metal view
        metalView = MTKView(frame: self.view.bounds, device: MTLCreateSystemDefaultDevice())
        guard let device = metalView.device else {
            fatalError("Metal is not supported on this device")
        }

        // Initialize render system and scene
        let shaderManager = ShaderManager(device: device)
        renderSystem = RenderSystem(device: device, viewSize: metalView.drawableSize, shaderManager: shaderManager)
        scene = Scene(device: device)
        
        // Set up camera
        camera = Camera()
        camera.position = SIMD3<Float>(3, 5, 8)
        camera.lookAt(SIMD3<Float>(0, 0, 0))
        camera.aspectRatio = Float(metalView.drawableSize.width / metalView.drawableSize.height)
        renderSystem.camera = camera

        // Add lights and entities
        addLightsAndEntities(device: device, shaderManager: shaderManager)

        // Configure the Metal view
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.sampleCount = 1
        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)  // Set background color to white
        metalView.framebufferOnly = true
        metalView.drawableSize = self.view.bounds.size
        self.view.addSubview(metalView)
        
        // Start the camera animation
        startCameraAnimation()
 
    }
    
    /// Starts a timer to animate the camera in a circular path around the origin.
    func startCameraAnimation() {
        cameraTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.cameraAngle += 0.01
            if self.cameraAngle >= 2 * .pi { self.cameraAngle = 0 }
            let radius: Float = 10.0
            let x = radius * cos(self.cameraAngle)
            let z = radius * sin(self.cameraAngle)
            self.camera.position = SIMD3<Float>(x, 2.0, z)
            self.camera.lookAt(SIMD3<Float>(0, 0, 0))
            self.renderSystem.camera = self.camera
        }
    }

    /// Adds lights and entities to the scene, initializing the lighting manager with appropriate settings.
    /// - Parameters:
    ///   - device: The Metal device used for buffer creation.
    ///   - shaderManager: The shader manager responsible for handling shaders.
    private func addLightsAndEntities(device: MTLDevice, shaderManager: ShaderManager) {
        // Initialize the lighting manager
        let lightingManager = LightingManager(device: device)
        
        // Define light properties and add them to the lighting manager
        let ambientLight = LightData(type: .ambient, color: SIMD3<Float>(1, 1, 1), intensity: 0.2, position: SIMD3<Float>(0, 0, 0), direction: SIMD3<Float>(0, -1, 0))
        let directionalLight = LightData(type: .directional, color: SIMD3<Float>(1, 1, 1), intensity: 0.8, position: SIMD3<Float>(0, 0, 0), direction: SIMD3<Float>(1, -1, 0))
        
        lightingManager.addLight(ambientLight)
        lightingManager.addLight(directionalLight)
        
        renderSystem.lightingManager = lightingManager

        // Pass the lighting manager to the scene
        scene.lightingManager = lightingManager

        // Add entities to the scene with lighting manager support
        //scene.addEntity(SkyPlaneEntity(device: device, shaderManager: shaderManager, lightingManager: lightingManager))
        //scene.addEntity(GridEntity(device: device, shaderManager: shaderManager, lightingManager: lightingManager, gridSize: 10.0, gridSpacing: 0.5))
        scene.addEntity(AxisEntity(device: device, shaderManager: shaderManager, lightingManager: lightingManager, axisLength: 2.0))
        scene.addEntity(TriangleEntity(device: device, shaderManager: shaderManager, lightingManager: lightingManager))
    }
}

extension GameViewController: MTKViewDelegate {
    /// Updates the view size for rendering when the drawable size changes.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderSystem.updateViewSize(size: size)
        renderSystem.camera?.aspectRatio = Float(size.width / size.height)
    }

    /// Renders the scene in the Metal view.
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        let deltaTime: Float = 1.0 / Float(view.preferredFramesPerSecond)
        renderSystem.update(scene: scene, deltaTime: deltaTime)
        renderSystem.render(scene: scene, drawable: drawable)
    }
}

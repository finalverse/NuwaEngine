//
//  GameViewController.swift
//  Nuwa macOS
//
//  GameViewController handles Metal view setup, rendering, and updates for macOS.

import Cocoa
import MetalKit

class GameViewController: NSViewController {
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
        
        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0) // Set background color to white
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.sampleCount = 1
        self.view.addSubview(metalView)

        // Initialize the render system and scene
        let shaderManager = ShaderManager(device: device)
        renderSystem = RenderSystem(device: device, viewSize: metalView.drawableSize, shaderManager: shaderManager)
        scene = Scene(device: device)
  
        // Set up the camera
        camera = Camera()
        camera.position = SIMD3<Float>(3, 5, 8)
        camera.lookAt(SIMD3<Float>(0, 0, 0))
        camera.aspectRatio = Float(metalView.drawableSize.width / metalView.drawableSize.height)
        renderSystem.camera = camera

        // Add lights and entities
        //addLightsAndEntities(device: device, shaderManager: shaderManager)
        addLights()
        addEntities(device: device, shaderManager: shaderManager)

        // Start the camera animation
        startCameraAnimation()
    
    }
    
    /// Sets up a timer to animate the camera in a circular motion around the scene.
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

    /// Adds entities to the scene.
    /// - Parameters:
    ///   - device: The Metal device used for creating buffers and resources.
    ///   - shaderManager: The shader manager used for managing shaders.
    private func addEntities(device: MTLDevice, shaderManager: ShaderManager) {
        guard let lightingManager = renderSystem.lightingManager else {
            fatalError("Error: LightingManager is not initialized.")
        }

        // Add a simple triangle entity to the scene
        let triangle = TriangleEntity(device: device, shaderManager: shaderManager, lightingManager: lightingManager)
        scene.addEntity(triangle)

        // Uncomment and add additional entities as needed
        /*
        // Add a sky plane entity
        let skyPlane = SkyPlaneEntity(device: device, shaderManager: shaderManager, lightingManager: renderSystem.lightingManager)
        scene.addEntity(skyPlane)

        // Add a grid entity for the ground
        let grid = GridEntity(device: device, shaderManager: shaderManager, lightingManager: renderSystem.lightingManager, gridSize: 10.0, gridSpacing: 0.5)
        scene.addEntity(grid)

        // Add axis indicators
        let axis = AxisEntity(device: device, shaderManager: shaderManager, lightingManager: renderSystem.lightingManager, axisLength: 2.0)
        scene.addEntity(axis)
        */
    }
    
    /// Adds ambient and directional lights to the scene using the `LightingManager`.
    /// - Requires: The `LightingManager` must be initialized before calling this function.
    func addLights() {
        // Ensure the Metal device is available
        guard let device = metalView.device else {
            print("Error: Metal device is unavailable.")
            return
        }

        // Initialize the lighting manager
        let lightingManager = renderSystem.lightingManager ?? LightingManager(device: device)


        // Create and configure a directional light
        let directionalLight = LightData(
            type: .directional,                     // Directional light type
            color: SIMD3<Float>(1.0, 1.0, 1.0),     // White light
            intensity: 0.8,                         // Moderate intensity
            position: SIMD3<Float>(0.0, 0.0, 0.0),  // Not used for directional lights
            direction: SIMD3<Float>(0.0, -1.0, 0.0) // Downward direction
        )
        lightingManager.addLight(directionalLight)

        // Create and configure an ambient light
        let ambientLight = LightData(
            type: .ambient,                         // Ambient light type
            color: SIMD3<Float>(0.5, 0.5, 0.5),     // Soft gray light
            intensity: 0.2,                         // Low intensity
            position: SIMD3<Float>(0.0, 0.0, 0.0),  // Not used for ambient lights
            direction: SIMD3<Float>(0.0, 0.0, 0.0)  // Not used for ambient lights
        )
        lightingManager.addLight(ambientLight)

        // Assign the lighting manager to the render system
        renderSystem.lightingManager = lightingManager
    }
}

extension GameViewController: MTKViewDelegate {
    /// Adjusts view size and aspect ratio when the drawable size changes.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderSystem.updateViewSize(size: size)
        renderSystem.camera?.aspectRatio = Float(size.width / size.height)
    }

    /// Called each frame to perform updates and render the scene.
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        let deltaTime: Float = 1.0 / Float(view.preferredFramesPerSecond)
        renderSystem.update(scene: scene, deltaTime: deltaTime)
        renderSystem.render(scene: scene, drawable: drawable)
    }
}

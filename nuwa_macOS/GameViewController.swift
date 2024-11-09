//
//  GameViewController.swift
//  nuwa macOS
//
//  Created by Wenyan Qin on 2024-11-05.
//
//  macOS-specific GameViewController for managing Metal view setup, rendering, and updates.

import Cocoa
import MetalKit

class GameViewController: NSViewController {
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

        // Configure the RenderSystem and Scene
        renderSystem = RenderSystem(device: device, viewSize: metalView.drawableSize)
        scene = Scene()
        
        // Initialize and configure the camera
        camera = Camera()
        camera.position = SIMD3<Float>(3, 5, 10)  // Start position; will update dynamically
        camera.lookAt(SIMD3<Float>(0, 0, 0))      // Look at the origin
        camera.aspectRatio = Float(metalView.drawableSize.width / metalView.drawableSize.height)
        renderSystem.camera = camera
        
        // Add lights, grid, and axis entities to the scene
        addLightsAndEntities()

        // Set up Metal view configurations
        metalView.delegate = self
        //metalView.clearColor = MTLClearColorMake(0.7, 0.7, 0.7, 1.0) // Light background for visibility
        metalView.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0) // Set background color to white
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.sampleCount = 1
        metalView.framebufferOnly = false
        
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

    override func viewDidLayout() {
        super.viewDidLayout()
        
        // Update Metal view and camera aspect ratio on window resize
        metalView.frame = self.view.bounds
        camera.aspectRatio = Float(view.bounds.width / view.bounds.height)
        renderSystem.updateDepthTexture(size: metalView.drawableSize)  // Update depth texture size
    }

    /// Adds lights, grid, and axis entities to the scene
    private func addLightsAndEntities() {
        // Add a large sky plane as the background
        let skyPlane = SkyPlaneEntity(device: metalView.device!)
        scene.addEntity(skyPlane)
        
        // Add ambient and directional lights
        renderSystem.addSceneLight(SceneLight(type: .ambient, color: SIMD3<Float>(1, 1, 1), intensity: 0.2))
        renderSystem.addSceneLight(SceneLight(type: .directional, color: SIMD3<Float>(1, 1, 1), intensity: 0.8, direction: SIMD3(1, -1, 0)))
        
        // Configure and add a grid entity for visual reference
        let gridSize: Float = 20.0
        let gridSpacing: Float = 0.5
        let gridEntity = GridEntity(device: metalView.device!, gridSize: gridSize, gridSpacing: gridSpacing)
        scene.addEntity(gridEntity)
        
        // Configure and add an axis entity for XYZ axis orientation
        let axisLength: Float = 2.0
        let axisEntity = AxisEntity(device: metalView.device!, axisLength: axisLength)
        scene.addEntity(axisEntity)
        
        // Add a test triangle entity at the origin
        let triangle = TriangleEntity(device: metalView.device!)
        triangle.node.position = SIMD3<Float>(0.0, 0.0, 0.0)
        scene.addEntity(triangle)
    }
}

extension GameViewController: MTKViewDelegate {
    /// Called when the drawable size changes, updating camera and depth texture
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspectRatio = Float(size.width / size.height)
        renderSystem.updateDepthTexture(size: size) // Update depth texture for new size
    }

    /// Draws the scene with each frame update
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        renderSystem.update(scene: scene, deltaTime: 1.0 / Float(view.preferredFramesPerSecond))
        renderSystem.render(scene: scene, drawable: drawable)
    }
}

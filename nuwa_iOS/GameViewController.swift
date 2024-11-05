//
//  GameViewController.swift
//  nuwa iOS
//
//  Created by Wenyan Qin on 2024-11-05.
//

// create ------------
//  - Parent Transformation: parentTriangle is positioned to the right and rotated 45 degrees.
//  - Child Inheritance: childTriangle is positioned relative to parentTriangle, so it will move and rotate along with its parent.
// update ------------
//  - instantiate the camera in GameViewController and assign it to RenderSystem.
// update ------
//  - Rotation Animation: parentTriangle now rotates continuously over 5 seconds.
//  - Update and Render Loop: We update the scene each frame, applying animations before rendering.

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
        
        // Initialize and assign the camera
        let camera = Camera()
        camera.aspectRatio = Float(metalView.drawableSize.width / metalView.drawableSize.height)
        renderSystem.camera = camera
        
        // Add ambient, directional, and point Nuwa lights
        let ambientSceneLight =
            NuwaLight(type: 0, // Ambient light
                      color: SIMD3<Float>(1, 1, 1),
                      intensity: 0.2,
                      position: SIMD3<Float>(0, 0, 0), // Ambient lights don't need position, so set to default
                      direction: SIMD3<Float>(0, 0, 0)) // Ambient lights don't have a direction

        let directionalSceneLight =
            NuwaLight(type: 1, // Directional light
                      color: SIMD3<Float>(1, 1, 1),
                      intensity: 0.8,
                      position: SIMD3<Float>(0, 0, 0), // Directional lights don't use position
                      direction: SIMD3<Float>(1, -1, 0)) // Set direction for directional light

        let pointSceneLight =
            NuwaLight(type: 2, // Point light
                      color: SIMD3<Float>(1, 0, 0),
                      intensity: 1.0,
                      position: SIMD3<Float>(0.5, 0.5, 2.0), // Position for the point light
                      direction: SIMD3<Float>(0, 0, 0)) // Point lights don't use direction

        // Add these Nuwa lights to the render system
        renderSystem.addSceneLight(ambientSceneLight)
        renderSystem.addSceneLight(directionalSceneLight)
        renderSystem.addSceneLight(pointSceneLight)
        
        // Create the parent triangle
        let parentTriangle = TriangleEntity(device: device)
        parentTriangle.node.position = SIMD3<Float>(0.2, 0.0, 0.0)      // Offset to the right
        //parentTriangle.node.rotation = SIMD3<Float>(0.0, 0.0, .pi / 4)  // 45-degree rotation
        parentTriangle.node.animator = Animator(type: .rotation(SIMD3<Float>(0, 0, .pi * 2), duration: 5.0)) // Rotates 360 degrees in 5 seconds


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
        
        let deltaTime: Float = 1.0 / Float(view.preferredFramesPerSecond)
        renderSystem.update(scene: scene, deltaTime: deltaTime)
        renderSystem.render(scene: scene, drawable: drawable)
    }
}



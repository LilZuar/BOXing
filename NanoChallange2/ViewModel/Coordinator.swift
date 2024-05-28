//
//  Coordinator.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 27/05/24.
//


import SwiftUI
import RealityKit
import ARKit
import Vision
import Combine

class Coordinator: NSObject, ARSessionDelegate {
    @Binding var timerValue: Int
    @Binding var destroyedBox: Int

    var parent: ARPageView
    weak var arView: ARView?
    private var subscriptions = Set<AnyCancellable>()
    private var boxModel: ModelEntity?
    private var hasCollided = false // Add a flag to track collision state
    private var count = 0
    let soundEffect = SoundPlayer()


    
    init(_ parent: ARPageView, timerValue: Binding<Int>, destroyedBox: Binding<Int>) {
        self.parent = parent
        self._timerValue = timerValue
        self._destroyedBox = destroyedBox
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        processHandPose(for: frame)
        
        if timerValue <= 0 {
            removeAllAnchors()
        }
    }

    // TODO: bisa taruh function" di bawah di modelView
    private func processHandPose(for frame: ARFrame) {
        let request = VNDetectHumanHandPoseRequest()
        
        // Perform Vision request
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing hand pose detection: \(error)")
            return
        }
        
        // Process Vision results
        if let observations = request.results{
            if timerValue <= 15 && timerValue > 0{
                processHandPoseObservations(observations)
            }
        }
    }
    
    private func processHandPoseObservations(_ observations: [VNHumanHandPoseObservation]) {
        guard let arView = arView else { return }

        // Remove previous hand entities
        for anchor in arView.scene.anchors {
            if anchor.name == "HandAnchor" {
                arView.scene.removeAnchor(anchor)
            }
        }
        
        for observation in observations {
            do {
                let recognizedPoints = try observation.recognizedPoints(.all)
                let handPoints = recognizedPoints.values.compactMap { $0 }
                
                guard handPoints.count > 0 else {
                    continue
                }
                
                // Create a hand entity
                let handEntity = makeHandEntity(from: handPoints)
                
                // Create an anchor entity
                let anchorEntity = AnchorEntity()
                anchorEntity.name = "HandAnchor"
                anchorEntity.addChild(handEntity)
                
                // Add the anchor entity to the scene
                arView.scene.addAnchor(anchorEntity)
                
                // Subscribe to collision events
                arView.scene.subscribe(to: CollisionEvents.Began.self, on: handEntity) { [weak self] event in
                    self?.handleCollision(event)
                }.store(in: &subscriptions)
                
            } catch {
                print("Error processing hand pose observation: \(error)")
            }
        }
    }

    private func makeHandEntity(from handPoints: [VNRecognizedPoint]) -> ModelEntity {
        // Convert hand points to SIMD3
        _ = handPoints.map { SIMD3<Float>(Float($0.location.x), Float($0.location.y), 0) }
        
        // Create a mesh representing the hand
        let mesh = MeshResource.generateSphere(radius: 0.02)
        
        // Create a material for the hand
        let material = SimpleMaterial(color: .red, isMetallic: false)
        
        // Create a model entity with the mesh and material
        let handEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // Generate collision shapes for the hand entity
        handEntity.generateCollisionShapes(recursive: true)
        
        return handEntity
    }

    func addBox() {
        guard let arView = arView else { return }
        
        // Create a box entity
        let boxMesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: .black, isMetallic: false)
        let boxModel = ModelEntity(mesh: boxMesh, materials: [material])
        boxModel.generateCollisionShapes(recursive: true) // Add collision shape
        
        let boxClone = boxModel.clone(recursive: true)
        
        // Position the box in front of the camera
        let randomX = Float.random(in: -0.2...0.2)
        let randomY = Float.random(in: 0.1...0.5)
        let boxPosition = SIMD3<Float>(randomX, randomY, -0.5)
        // Create an anchor entity for the box
        let anchorEntity = AnchorEntity(world: boxPosition)
        anchorEntity.addChild(boxClone)
        
        // Add the anchor entity to the scene
        arView.scene.addAnchor(anchorEntity)
        
        // Store a reference to the box model
        self.boxModel = boxClone
        
        // Subscribe to collision events
        arView.scene.subscribe(to: CollisionEvents.Began.self, on: boxClone) { [weak self] event in
            self?.handleCollision(event)
        }.store(in: &subscriptions)
        
        // Add rotation animation
        startRotating(entity: boxClone)
    }
    
    

    func startRotating(entity: ModelEntity) {
        // Create a timer to update the rotation
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak entity] timer in
            guard let entity = entity else {
                timer.invalidate()
                return
            }
            
            // Update the entity's rotation
            entity.transform.rotation *= simd_quatf(angle: .pi / 180.0, axis: [0, 1, 0])
        }
    }


    private func handleCollision(_ event: CollisionEvents.Began) {
        if !hasCollided && timerValue > 0, let boxModel = self.boxModel {
            hasCollided = true // Set the flag to true to indicate collision has been handled
            
            soundEffect.playEffect(soundName: "HitSound", soundExtension: "wav")

            count += 1
            
            // Change color on collision
            let intensity = min(1.0, Float(count) * 0.1)
            let newColor = UIColor(red: CGFloat(intensity), green: 0, blue: 0, alpha: 1)
            
            // Change color on collision
            boxModel.model?.materials = [SimpleMaterial(color: newColor, isMetallic: false)]
            
            
            // Check if collision count is 20
            if count == 20{
                soundEffect.playEffect(soundName: "ExplosionSound", soundExtension: "wav")
                explodeBox(boxModel)
                destroyedBox += 1
                count = 0
                addBox()
            
            }
            
            // Reset the flag after a short delay to allow for subsequent collisions
            DispatchQueue.main.asyncAfter(deadline: .now() + 1/10) {
                self.hasCollided = false
            }
        }
    }

    private func explodeBox(_ boxModel: ModelEntity) {
        guard let arView = arView else { return }

        // Remove the original box model
        boxModel.removeFromParent()

        // Create small fragments from the original box
        let fragmentCount = 10
        let fragmentSize: Float = 0.02
        let fragments: [ModelEntity] = (0..<fragmentCount).map { _ in
            let fragmentMesh = MeshResource.generateBox(size: fragmentSize)
            let fragmentMaterial = SimpleMaterial(color: .yellow, isMetallic: false)
            let fragment = ModelEntity(mesh: fragmentMesh, materials: [fragmentMaterial])
            
            // Add a dynamic physics body to each fragment
            fragment.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
            
            fragment.generateCollisionShapes(recursive: true)
            return fragment
        }
        
        // Create an anchor entity for the fragments
        let anchorEntity = AnchorEntity(world: boxModel.position)
        anchorEntity.name = "ExplosionAnchor"
        
        // Position fragments around the original box position
        for fragment in fragments {
            let offsetX = Float.random(in: -0.1...0.1)
            let offsetY = Float.random(in: -0.1...0.1)
            let offsetZ = Float.random(in: -0.1...0.1)
            fragment.position = boxModel.position + SIMD3<Float>(offsetX, offsetY, offsetZ)
            
            // Add fragment to the anchor entity
            anchorEntity.addChild(fragment)
        }
        
        // Add the explosion anchor to the scene
        arView.scene.addAnchor(anchorEntity)
        
        // Apply an impulse to each fragment to simulate explosion
        for fragment in fragments {
            let impulseDirection = SIMD3<Float>(
                Float.random(in: -1...1),
                Float.random(in: -1...1),
                Float.random(in: -1...1)
            )
            fragment.addForce(impulseDirection * 5, relativeTo: nil)
        }
    }
    
    func removeAllAnchors() {
        guard let arView = arView else { return }
        arView.scene.anchors.removeAll()
    }
        
}

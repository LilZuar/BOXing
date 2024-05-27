//
//  HandViewModel.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 23/05/24.
//

import SwiftUI
import RealityKit
import ARKit
import Vision
import Combine

class HandViewModel {
    var arView: ARView?
    var overlayView: UIView?
    var rectangleLayer: [CAShapeLayer] = []
    var subscriptions = Set<AnyCancellable>()
    
    init(arView: ARView, overlayView: UIView) {
        self.arView = arView
        self.overlayView = overlayView
    }

    func processHandPoseObservations(_ observations: [VNHumanHandPoseObservation]) {
        guard let arView = self.arView else { return }

        // Remove previous hand bounding box entities
        for anchor in arView.scene.anchors {
            if anchor.name == "HandBoundingBoxAnchor" {
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
                
                // Calculate the bounding box for the hand
                let boundingBox = handPoints.reduce(CGRect.null) { (rect, point) -> CGRect in
                    let pointRect = CGRect(x: CGFloat(point.location.x), y: CGFloat(point.location.y), width: 0.0, height: 0.0)
                    return rect.union(pointRect)
                }
                
                // Convert boundingBoxCenter to 3D space
                let boundingBoxCenter = SIMD3<Float>(Float(boundingBox.midX), Float(boundingBox.midY), -0.5) // Adjust z-position as needed
                
                // Create a box entity for the hand bounding box
                let boxMesh = MeshResource.generateBox(size: Float(boundingBox.width)) // Assuming bounding box is square
                let material = SimpleMaterial(color: .clear, isMetallic: false)
                let handBoxModel = ModelEntity(mesh: boxMesh, materials: [material])
                handBoxModel.position = boundingBoxCenter
                print("Hand box position: \(boundingBoxCenter)") // Print the position
                handBoxModel.generateCollisionShapes(recursive: true) // Add collision shape
                
                // Create an anchor entity for the hand bounding box
                let anchorEntity = AnchorEntity(world: boundingBoxCenter)
                anchorEntity.name = "HandBoundingBoxAnchor"
                anchorEntity.addChild(handBoxModel)
                
                // Add the anchor entity to the scene
                arView.scene.addAnchor(anchorEntity)
                
                // Subscribe to collision events
                arView.scene.subscribe(to: CollisionEvents.Began.self, on: handBoxModel) { [weak self] event in
                    self?.handleCollision(event)
                }.store(in: &subscriptions)
                
                // Draw rectangle around the hand in the overlay view
                updateBoundingBoxes([boundingBox])
                
            } catch {
                print("Error processing hand pose observation: \(error)")
            }
        }
    }

    private func updateBoundingBoxes(_ boundingBoxes: [CGRect]) {
        guard let overlayView = self.overlayView else { return }
        
        // Ensure there are enough CAShapeLayer instances to display the bounding boxes
        while rectangleLayer.count < boundingBoxes.count {
            let layer = CAShapeLayer()
            layer.strokeColor = UIColor.red.cgColor
            layer.lineWidth = 2.0
            layer.fillColor = UIColor.clear.cgColor
            overlayView.layer.addSublayer(layer)
            rectangleLayer.append(layer)
        }
        
        for (index, boundingBox) in boundingBoxes.enumerated() {
            let convertedBoundingBox = overlayView.layer.convert(boundingBox, from: overlayView.layer.superlayer)

            // Adjust the x and y positions to match the view's coordinate system
            let viewBoundingBox = CGRect(
                x: overlayView.bounds.width - convertedBoundingBox.origin.x - convertedBoundingBox.width,
                y: convertedBoundingBox.origin.y,
                width: boundingBox.width,
                height: boundingBox.height
            )
            
            let path = UIBezierPath(rect: viewBoundingBox)
            rectangleLayer[index].path = path.cgPath
        }
        
        // Clear remaining layers if there are fewer bounding boxes than existing layers
        for index in boundingBoxes.count..<rectangleLayer.count {
            rectangleLayer[index].path = nil
        }
    }

    private func handleCollision(_ event: CollisionEvents.Began) {
        // Handle collision
    }
}

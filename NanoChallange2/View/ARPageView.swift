//
//  ARPageView.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 26/05/24.
//
import SwiftUI
import RealityKit
import ARKit
import Vision
import Combine

struct ARPageView: UIViewRepresentable {
    @Binding var timerValue: Int
    @Binding var destroyedBox: Int

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure ARView
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)
        
        // Set the delegate to receive ARFrame updates
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator
        
        // Add a box to the scene
        context.coordinator.addBox()
        
        
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, timerValue: $timerValue, destroyedBox: $destroyedBox)
    }
    
    // TODO: bisa taruh di folder model?
    
}

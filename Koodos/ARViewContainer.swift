//
//  ARViewContainer.swift
//  Koodos
//
//  Created by Dimas on 25/03/23.
//

import SwiftUI
import RealityKit


struct ARViewContainer: UIViewRepresentable {
    
    /// Kudos images that will be rendered
//    let cards: [ImageFirebase]
    let cards: [Image]

    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let mesh: MeshResource = .generatePlane(width: 1.1, depth: 1.45, cornerRadius: 0.03)
        
        let materialView = MaterialContainerView(cards: cards)
        let renderer = ImageRenderer(content: materialView)

        guard let uiImage = renderer.uiImage else { return arView }
        
        let texture = try! TextureResource.generate(from: uiImage.cgImage!, options: .init(semantic: .normal))
        
        var material = SimpleMaterial()
        material.color = .init(tint: .white, texture: .init(texture))
        material.metallic = .float(0.25)
        material.roughness = .float(0.7)

        let materialModel = ModelEntity(mesh: mesh, materials: [material])
        materialModel.transform = Transform(pitch: .pi/2)
        materialModel.position.y = 1.555
        materialModel.position.z = 0.045
        
        let floorAnchor = AnchorEntity(plane: .horizontal,
                                       classification: .floor,
                                       minimumBounds: [0.9, 0.9])
        
        arView.scene.addAnchor(floorAnchor)
        
        let kudosBoard = try! Entity.loadModel(named: "whiteboard")
        floorAnchor.addChild(kudosBoard)
        floorAnchor.addChild(materialModel)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

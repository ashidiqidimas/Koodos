//
//  ARContentView.swift
//  Koodos
//
//  Created by Rizki Samudra on 26/03/23.
//

import Foundation
import SwiftUI
import AVFoundation

struct ARContentView: View {
    @StateObject var cameraManager = CameraManager()

//    let cards: [ImageFirebase]
    let cards: [Image]

    var body: some View {
        VStack{
            if cameraManager.permissionGranted {
                ARViewContainer(cards: cards) // pass the images to be displayed on the board here
            }
        }.onAppear {
            cameraManager.requestPermission()
        }
        .onReceive(cameraManager.$permissionGranted, perform: { (granted) in
            if granted {
                //show image picker controller
            }
        })
        
    }
       
}


struct ARContentView_Previews: PreviewProvider {
    static var previews: some View {
        ARContentView(cards: [])
    }
}

class CameraManager : ObservableObject {
    @Published var permissionGranted = false
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            DispatchQueue.main.async {
                self.permissionGranted = accessGranted
            }
        })
    }
}

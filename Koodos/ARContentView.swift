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
    @Environment(\.dismiss) var dismiss

//    let cards: [ImageFirebase]
    let cards: [Image]

//    var body: some View {
//        VStack{
//            if cameraManager.permissionGranted {
//                ARViewContainer(cards: cards) // pass the images to be displayed on the board here
//            }
//        }.onAppear {
//            cameraManager.requestPermission()
//        }
//        .onReceive(cameraManager.$permissionGranted, perform: { (granted) in
//            if granted {
//                //show image picker controller
//            }
//        })
//
//    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
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
                .preferredColorScheme(.light)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .toolbar(.hidden, for: .navigationBar)
                
                Button {
                    dismiss.callAsFunction()
                } label: {
                    HStack(spacing: 8) {
                        Text("Back")
                    }
                    .padding(
                        EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
                    )
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                }
                .position(x: 54, y: 26)
                .ignoresSafeArea(.keyboard)
            }
        }
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

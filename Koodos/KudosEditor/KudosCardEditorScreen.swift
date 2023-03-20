//
//  KudosEditorScreen.swift
//  Koodos
//
//  Created by Dimas on 20/03/23.
//

import SwiftUI

struct KudosEditorScreen: View {
    var body: some View {
        GeometryReader { geo in
            KudosEditorControllerRepresentable()
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

struct KudosEditorControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        KudosEditorViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
}

struct KudosEditorScreen_Previews: PreviewProvider {
    static var previews: some View {
        KudosEditorScreen()
            .preferredColorScheme(.dark)
    }
}

// TODO: move to KudosCard

class KudosEditorViewController: UIViewController {
    
    override func viewDidLoad() {
        
    }
    
}

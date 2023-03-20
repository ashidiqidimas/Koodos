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
    
    // MARK: - Properties
    
    /// Used to store the old location of an UILabel before become the first responder
    /// so we can animate it back to its original position when we has finished editing.
    private var oldLocation = CGPoint(x: 0, y: 0)
    
    /// The location when the drag started. It used for calculating the relative drag location when scaling
    private var dragStartLocation = CGPoint(x: 0, y: 0)
    
    /// Old scale of the view that is being interacted.
    private var oldScale: CGFloat = 1
    
    private var isKeyboardShown = false
    
    /// Returns true if the UILabel is just added to the view
    private var isNewTextView = false
    
    private var isFromOutsideTrashView = true
    
    private var keyboardAnimationDuration: Double?
    private var keyboardAnimationCurve: Int?
    
    // MARK: Views
    
    private var kudosCard: UIView = {
        let kudosCard = UIView(frame: .zero)
        kudosCard.layer.cornerRadius = 24
        kudosCard.backgroundColor = .systemPink
        kudosCard.clipsToBounds = true
        
        return kudosCard
    }()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
    }
    
    func setupSubviews() {
        setupKudosCard()
        
        setupConstraints()
    }
    
    func setupKudosCard() {
        view.addSubview(kudosCard)
        
        let cardSize = CGSize(
            width: view.frame.width,
            height: view.frame.width * 16/9
        )
        kudosCard.frame.size = cardSize
        
    }
    
    func setupConstraints() {
        
    }
    
}

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
    
    private var bottomToolbarView: UIView = {
        let bottomToolbarView = UIView()
        bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
        bottomToolbarView.layer.zPosition = 1
        
        return bottomToolbarView
    }()
    
    private var toggleColorsPalletesButton: UIButton = {
        var config = UIButton.Configuration.borderedProminent()
        config.background.strokeColor = .init(white: 0.95, alpha: 1)
        config.background.strokeWidth = 2
        config.baseBackgroundColor = .systemPink
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var colorPalletesContainer: UIView = {
        let colors: [UIColor] = [
            .white,
            .orange,
            .yellow,
            .green,
            .systemTeal,
            .cyan,
            .systemIndigo,
            .systemPink,
        ]

        let frame = CGRect(x: 0, y: 0, width: 44, height: 416)
        let colorPalletesContainer = UIView(frame: frame)
        colorPalletesContainer.translatesAutoresizingMaskIntoConstraints = false
        colorPalletesContainer.isHidden = true
        
        for (index, color) in colors.enumerated() {
            var config = UIButton.Configuration.borderedProminent()
            config.background.strokeColor = .init(white: 0.95, alpha: 1)
            config.background.strokeWidth = 2
            config.baseBackgroundColor = color
            config.cornerStyle = .capsule
            
            let size = CGSize(width: 44, height: 44)
            let origin = CGPoint(
                x: 0,
                y: 416
            )
            
            let button = UIButton(configuration: config)
            button.frame = .init(origin: origin, size: size)
            button.backgroundColor = color
            button.layer.cornerRadius = .infinity
            
            colorPalletesContainer.addSubview(button)
        }
        
        return colorPalletesContainer
    }()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
    }
    
    func setupSubviews() {
        view.addSubview(kudosCard)
        view.addSubview(bottomToolbarView)
        
        bottomToolbarView.addSubview(toggleColorsPalletesButton)
        view.addSubview(colorPalletesContainer)
        
        setupKudosCard()
        setupConstraints()
    }
    
    func setupKudosCard() {
        toggleColorsPalletesButton.addTarget(
            self,
            action: #selector(toggleColorsPalettesPressed),
            for: .touchUpInside
        )
        
        let cardSize = CGSize(
            width: view.frame.width,
            height: view.frame.width * 16/9
        )
        kudosCard.frame.size = cardSize
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            bottomToolbarView.heightAnchor.constraint(
                equalToConstant: 44
            ),
            bottomToolbarView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            bottomToolbarView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -8
            ),
            bottomToolbarView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            
            toggleColorsPalletesButton.widthAnchor.constraint(
                equalTo: toggleColorsPalletesButton.heightAnchor
            ),
            toggleColorsPalletesButton.topAnchor.constraint(
                equalTo: bottomToolbarView.topAnchor
            ),
            toggleColorsPalletesButton.leadingAnchor.constraint(
                equalTo: bottomToolbarView.leadingAnchor
            ),
            toggleColorsPalletesButton.bottomAnchor.constraint(
                equalTo: bottomToolbarView.bottomAnchor
            ),
            
            colorPalletesContainer.centerXAnchor.constraint(
                equalTo: toggleColorsPalletesButton.centerXAnchor
            ),
            colorPalletesContainer.heightAnchor.constraint(
                equalToConstant: 400
            ),
            colorPalletesContainer.widthAnchor.constraint(
                equalTo: toggleColorsPalletesButton.widthAnchor
            ),
            colorPalletesContainer.bottomAnchor.constraint(
                equalTo: bottomToolbarView.topAnchor,
                constant: -16
            ),
        ])
    }
    
}

extension KudosEditorViewController {
    
    // MARK: Button Targets
    
    @objc func toggleColorsPalettesPressed(forceHide: Bool = false) {
        
        if colorPalletesContainer.isHidden && !forceHide {
            colorPalletesContainer.isHidden.toggle()
            
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options:  .curveEaseOut
            ) {
                for case let (index, button as UIButton) in self.colorPalletesContainer.subviews.enumerated() {
                    let origin = CGPoint(
                        x: 0,
                        y: index * 50
                    )
                    button.frame.origin = origin
                }
            }
        } else {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options:  .curveEaseOut
            ) {
                for case let button as UIButton in self.colorPalletesContainer.subviews{
                    let origin = CGPoint(
                        x: 0,
                        y: 416
                    )
                    button.frame.origin = origin
                }
            } completion: { _ in
                self.colorPalletesContainer.isHidden.toggle()
            }
        }
        
    }
    
}

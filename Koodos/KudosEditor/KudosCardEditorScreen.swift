//
//  KudosEditorScreen.swift
//  Koodos
//
//  Created by Dimas on 20/03/23.
//

import SwiftUI
import UIKit
import PencilKit

struct KudosEditorScreen: View {
    
    @ObservedObject var viewModel: KoodosViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geo in
            ZStack {
                KudosEditorControllerRepresentable(
                    viewModel: viewModel
                )
                .preferredColorScheme(.light)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .toolbar(.hidden, for: .navigationBar)
                
                Button {
                    dismiss.callAsFunction()
                } label: {
                    HStack(spacing: 8) {
                        Text("Cancel")
                    }
                    .padding(
                        EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
                    )
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                }
                .position(x: geo.size.width - 54, y: 26)
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}

struct KudosEditorControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: KoodosViewModel

    func makeUIViewController(context: Context) -> some UIViewController {
//        KudosEditorViewController()
        let kudosEditorViewController = KudosEditorViewController()
        kudosEditorViewController.viewModel = viewModel
        return kudosEditorViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
}

struct KudosEditorScreen_Previews: PreviewProvider {
    static var previews: some View {
        KudosEditorScreen(viewModel: KoodosViewModel())
    }
}

// TODO: move to KudosCard

class KudosEditorViewController: UIViewController {
    
    var viewModel: KoodosViewModel? = nil

    // MARK: - Properties
    
    private var textViews: [UITextView] = [] {
        didSet {
            if textViews.isEmpty {
                hintText.isHidden = true
            } else {
                hintText.isHidden = false
            }
        }
    }
    
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
    
    private var currentCard = Card()
    
    //    private var drawingPoints: [Int: [CGFloat]] = [:]
    
    // MARK: Views
    
    private var hintText: UILabel = {
        let hintText = UILabel()
        hintText.text = "Tap to add your message"
        hintText.translatesAutoresizingMaskIntoConstraints = false
        hintText.font = .systemFont(ofSize: 20)
        
        return hintText
    }()
    
    private var kudosCard: UIView = {
        let kudosCard = UIView(frame: .zero)
        kudosCard.translatesAutoresizingMaskIntoConstraints = false
        kudosCard.layer.cornerRadius = 24
        kudosCard.clipsToBounds = true
        
        return kudosCard
    }()
    
    private var bottomToolbarView: UIView = {
        let bottomToolbarView = UIView()
        bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
        bottomToolbarView.layer.zPosition = 1
        
        return bottomToolbarView
    }()
    
    private var canvasView: PKCanvasView = {
        var canvas = PKCanvasView()
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isUserInteractionEnabled = false
        let inkColor = PKInkingTool.convertColor(
            CardColor.colors.first!.text,
            from: .light,
            to: .dark
        )
        canvas.tool = PKInkingTool(.pen, color: inkColor, width: 3)
        return canvas
    }()
    
    private var toggleColorsPalletesButton: UIButton = {
        var config = UIButton.Configuration.borderedProminent()
        config.background.strokeColor = .init(white: 0.95, alpha: 1)
        config.background.strokeWidth = 2
        config.baseBackgroundColor = CardColor.colors.first!.background
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.imageView?.layer.opacity = 0
        
        return button
    }()
    
    private var colorPalletesContainer: UIView = {
        let colors: [CardColor] = CardColor.colors
        
        let frame = CGRect(x: 0, y: 0, width: 50, height: 448)
        let colorPalletesContainer = UIView(frame: frame)
        colorPalletesContainer.translatesAutoresizingMaskIntoConstraints = false
        colorPalletesContainer.isHidden = true
        
        for (index, color) in colors.reversed().enumerated() {
            var config = UIButton.Configuration.borderedProminent()
            config.background.strokeColor = .init(white: 0.95, alpha: 1)
            config.background.strokeWidth = color.background == colors[0].background ? 6 : 2
            config.baseBackgroundColor = color.background
            config.cornerStyle = .capsule
            
            let size = CGSize(width: 50, height: 50)
            let origin = CGPoint(
                x: 0,
                y: 448
            )
            
            let button = UIButton(configuration: config)
            button.frame = .init(origin: origin, size: size)
            button.backgroundColor = color.background
            button.layer.cornerRadius = .infinity
            
            colorPalletesContainer.addSubview(button)
        }
        
        return colorPalletesContainer
    }()
    
    private var randomizedCardButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = .init(systemName: "dice.fill")?.withTintColor(
            .textSecondary,
            renderingMode: .alwaysOriginal
        )
        config.baseBackgroundColor = .backgroundSecondary
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var emojiPicker: UIStackView = {
        var stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        
        let imageStrings = Card.emojis.map { "\($0)-compact" }

        for imageString in imageStrings {
            let image = UIImage(named: imageString)
            
            var config = UIButton.Configuration.filled()
            config.image = image
            config.cornerStyle = .medium
            if imageString == imageStrings.first {
                config.baseBackgroundColor = .backgroundSecondary
            } else {
                config.baseBackgroundColor = .clear
            }
            
            let emojiButton = UIButton(configuration: config)
            emojiButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            emojiButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            stack.addArrangedSubview(emojiButton)
        }
        
        stack.transform = .init(
            translationX: 0,
            y: 100
        )
        stack.isHidden = true
        
        return stack
    }()
    
    private var titlePicker: UIStackView = {
        var stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 20
        
        for title in Card.titles {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.rounded(ofSize: 12, weight: .bold)
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.textAlignment = .left
            button.setTitleColor(.textPrimary, for: .normal)
            
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            stack.addArrangedSubview(button)
        }
        
        stack.transform = .init(
            translationX: 0,
            y: 100
        )
        stack.isHidden = true
        
        return stack
    }()
    
    @objc private var activateDrawModeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = .init(systemName: "scribble.variable")?.withTintColor(.textSecondary, renderingMode: .alwaysOriginal)
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .backgroundSecondary
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var cardEmojiButton: UIButton = {
        let image = UIImage(named: "emoji-star")
        
        let imageButton = UIButton()
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.setImage(image, for: .normal)
        
        return imageButton
    }()
    
    private var cardDivider: UIView = {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }()
    
    private var cardTitleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("You Are\nAwesome!", for: .normal)
        button.titleLabel?.font = UIFont.rounded(ofSize: 32, weight: .bold)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .left
        return button
    }()
    
    private var trashView: UIImageView = {
        let image = UIImage(
            systemName: "trash.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(
                paletteColors: [.red, .init(red: 255/255, green: 236/255, blue: 238/255, alpha: 1)]
            )
        )
        let trashView = UIImageView(image: image)
        trashView.translatesAutoresizingMaskIntoConstraints = false
        trashView.isHidden = true
        
        return trashView
    }()
    
    private var CTAButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.title = "Share"
        config.imagePadding = 4
        config.image = .init(systemName: "paperplane.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        config.baseBackgroundColor = .label
        config.baseForegroundColor = .systemBackground
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupSubviews() {
        view.addSubview(kudosCard)
        kudosCard.addSubview(trashView)
        kudosCard.addSubview(canvasView)
        kudosCard.addSubview(cardEmojiButton)
        kudosCard.addSubview(cardTitleButton)
        kudosCard.addSubview(cardDivider)
        view.addSubview(bottomToolbarView)
        bottomToolbarView.addSubview(randomizedCardButton)
        bottomToolbarView.addSubview(activateDrawModeButton)
        bottomToolbarView.addSubview(CTAButton)
        view.addSubview(emojiPicker)
        view.addSubview(titlePicker)
        view.addSubview(hintText)
        
        bottomToolbarView.addSubview(toggleColorsPalletesButton)
        view.addSubview(colorPalletesContainer)
        
        setupKudosCard()
        setupTitleOptions()
        setupColorPalletesContainer()
        setupToggleColorsPalletesButton()
        setupDrawButton()
        setupDoneDrawingButton()
        setupCardTitleButton()
        setupCardEmojiButton()
        setupEmojiButton()
        setupRandomizedCardPressed()
        setupConstraints()
    }
    
    func setupKudosCard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnCard))
        kudosCard.addGestureRecognizer(tapGesture)
        
        updateCard()
    }
    
    func updateCard(updateBackground: Bool = true) {
        if updateBackground {
            kudosCard.backgroundColor = currentCard.color.background
            cardDivider.backgroundColor = currentCard.color.divider
        }
        cardTitleButton.setTitleColor(currentCard.color.text, for: .normal)
        cardTitleButton.setTitle(currentCard.title, for: .normal)
        cardEmojiButton.setImage(UIImage(named: currentCard.emoji), for: .normal)
        toggleColorsPalletesButton.configuration?.baseBackgroundColor = currentCard.color.background
        
        for case let colorButton as UIButton in colorPalletesContainer.subviews {
            let isSelected = colorButton.backgroundColor == currentCard.color.background
            colorButton.configuration?.background.strokeWidth = isSelected ? 6 : 2
        }
        
        for case let emojiButton as UIButton in emojiPicker.arrangedSubviews {
            if emojiButton.configuration?.image == UIImage(named: "\(currentCard.emoji)-compact") {
                emojiButton.configuration?.baseBackgroundColor = .backgroundSecondary
            } else {
                emojiButton.configuration?.baseBackgroundColor = .clear
            }
        }
        
        for textView in textViews {
            textView.textColor = currentCard.color.text
        }
    }
    
    func setupRandomizedCardPressed() {
        randomizedCardButton.addTarget(
            self,
            action: #selector(randomizedCardPressed),
            for: .touchUpInside
        )
    }
    
    func setupToggleColorsPalletesButton() {
        toggleColorsPalletesButton.addTarget(
            self,
            action: #selector(toggleColorsPalettesPressed),
            for: .touchUpInside
        )
    }
    
    func setupCardEmojiButton() {
        cardEmojiButton.addTarget(
            self,
            action: #selector(cardEmojiPressed),
            for: .touchUpInside
        )
    }
    
    func setupCardTitleButton() {
        cardTitleButton.addTarget(
            self,
            action: #selector(cardTitlePressed),
            for: .touchUpInside
        )
    }
    
    func setupEmojiButton() {
        for case let button as UIButton in emojiPicker.subviews{
            button.addTarget(
                self,
                action: #selector(emojiPressed),
                for: .touchUpInside
            )
        }
    }
    
    func setupDrawButton() {
        activateDrawModeButton.addTarget(
            self,
            action: #selector(activateDrawModePressed),
            for: .touchUpInside
        )
    }
    
    func setupDoneDrawingButton() {
        CTAButton.addTarget(
            self,
            action: #selector(CTAButtonPressed),
            for: .touchUpInside
        )
    }
    
    func setupColorPalletesContainer() {
        for case let colorButton as UIButton in colorPalletesContainer.subviews {
            colorButton.addTarget(
                self,
                action: #selector(colorOptionPressed(sender:)),
                for: .touchUpInside
            )
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            hintText.centerXAnchor.constraint(equalTo: kudosCard.centerXAnchor),
            hintText.centerYAnchor.constraint(equalTo: kudosCard.centerYAnchor),
            
            cardEmojiButton.topAnchor.constraint(
                equalTo: kudosCard.topAnchor,
                constant: 48
            ),
            cardEmojiButton.leadingAnchor.constraint(
                equalTo: kudosCard.leadingAnchor,
                constant: 32
            ),
            cardEmojiButton.widthAnchor.constraint(
                equalToConstant: 100
            ),
            cardEmojiButton.heightAnchor.constraint(
                equalTo: cardEmojiButton.widthAnchor
            ),
            
            cardTitleButton.leadingAnchor.constraint(
                equalTo: cardEmojiButton.trailingAnchor,
                constant: 32
            ),
            cardTitleButton.centerYAnchor.constraint(
                equalTo: cardEmojiButton.centerYAnchor
            ),
            cardTitleButton.trailingAnchor.constraint(
                equalTo: kudosCard.trailingAnchor,
                constant: -32
            ),
            cardTitleButton.heightAnchor.constraint(
                equalToConstant: 140
            ),
            
            cardDivider.topAnchor.constraint(
                equalTo: cardEmojiButton.bottomAnchor,
                constant: 24
            ),
            cardDivider.leadingAnchor.constraint(
                equalTo: cardEmojiButton.leadingAnchor
            ),
            cardDivider.trailingAnchor.constraint(
                equalTo: cardTitleButton.trailingAnchor
            ),
            cardDivider.heightAnchor.constraint(equalToConstant: 1.5),
            
            emojiPicker.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -8
            ),
            emojiPicker.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            titlePicker.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -8
            ),
            titlePicker.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            
            trashView.heightAnchor.constraint(equalToConstant: 64),
            trashView.widthAnchor.constraint(equalToConstant: 64),
            trashView.bottomAnchor.constraint(equalTo: kudosCard.bottomAnchor, constant: -8),
            trashView.centerXAnchor.constraint(equalTo: kudosCard.centerXAnchor),
            
            kudosCard.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            kudosCard.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 8
            ),
            kudosCard.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -8
            ),
            kudosCard.heightAnchor.constraint(equalTo: kudosCard.widthAnchor, multiplier: 16 / 9),
            
            canvasView.topAnchor.constraint(
                equalTo: kudosCard.topAnchor
            ),
            canvasView.leadingAnchor.constraint(
                equalTo: kudosCard.leadingAnchor
            ),
            canvasView.bottomAnchor.constraint(
                equalTo: kudosCard.bottomAnchor
            ),
            canvasView.trailingAnchor.constraint(
                equalTo: kudosCard.trailingAnchor
            ),
            
            bottomToolbarView.heightAnchor.constraint(
                equalToConstant: 50
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
                equalToConstant: 448
            ),
            colorPalletesContainer.widthAnchor.constraint(
                equalTo: toggleColorsPalletesButton.widthAnchor
            ),
            colorPalletesContainer.bottomAnchor.constraint(
                equalTo: bottomToolbarView.topAnchor,
                constant: -42
            ),
            
            randomizedCardButton.topAnchor.constraint(
                equalTo: bottomToolbarView.topAnchor
            ),
            randomizedCardButton.leadingAnchor.constraint(
                equalTo: toggleColorsPalletesButton.trailingAnchor, constant: 8
            ),
            randomizedCardButton.bottomAnchor.constraint(
                equalTo: bottomToolbarView.bottomAnchor
            ),
            randomizedCardButton.widthAnchor.constraint(
                equalTo: randomizedCardButton.heightAnchor
            ),

            activateDrawModeButton.topAnchor.constraint(
                equalTo: bottomToolbarView.topAnchor
            ),
            activateDrawModeButton.leadingAnchor.constraint(
                equalTo: randomizedCardButton.trailingAnchor, constant: 8
            ),
            activateDrawModeButton.bottomAnchor.constraint(
                equalTo: bottomToolbarView.bottomAnchor
            ),
            activateDrawModeButton.widthAnchor.constraint(
                equalTo: randomizedCardButton.heightAnchor
            ),
            
            CTAButton.topAnchor.constraint(equalTo: bottomToolbarView.topAnchor),
            CTAButton.bottomAnchor.constraint(equalTo: bottomToolbarView.bottomAnchor),
            CTAButton.trailingAnchor.constraint(equalTo: bottomToolbarView.trailingAnchor),
            CTAButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
}

// MARK: - Button Targets

extension KudosEditorViewController {
        
    @objc func toggleColorsPalettesPressed(forceHide: Bool = false) {
        
        if !colorPalletesContainer.isHidden || forceHide {
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
                self.colorPalletesContainer.isHidden = true
            }
        } else {
            colorPalletesContainer.isHidden.toggle()
            
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options:  .curveEaseOut
            ) {
                for case let (index, button as UIButton) in self.colorPalletesContainer.subviews.enumerated() {
                    let origin = CGPoint(
                        x: 0,
                        y: index * 56
                    )
                    button.frame.origin = origin
                }
            }
        }
    }
    
    @objc func colorOptionPressed(sender: UIButton) {
        // Reset all color buttons stroke width
        for case let colorButton as UIButton in colorPalletesContainer.subviews {
            colorButton.configuration?.background.strokeWidth = 2
        }
        
        if let backgroundColor = sender.backgroundColor {
            let cardColor = CardColor.colors.first(where: { $0.background == backgroundColor} )
            currentCard.color = cardColor!
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) { [self] in
                if canvasView.isUserInteractionEnabled {
                    let textColor = currentCard.color.pen
                    canvasView.tool = PKInkingTool(.pen, color: textColor, width: 2)
                    updateCard(updateBackground: false)
                } else {
                    updateCard()
                }
                sender.configuration?.background.strokeWidth = 6
                toggleColorsPalletesButton.configuration?.baseBackgroundColor = backgroundColor
            } completion: { [self] _ in
                toggleColorsPalettesPressed(forceHide: true)
            }
        }
    }
    
    @objc func activateDrawModePressed(_ sender: UIButton) {
        canvasView.tool = PKInkingTool(.pen, color: currentCard.color.pen, width: 3)
        UIView.animateKeyframes(withDuration: 0.25, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2) { [self] in
                toggleColorsPalletesButton.configuration?.image = UIImage(systemName: "pencil")
                randomizedCardButton.layer.opacity = 0
                activateDrawModeButton.layer.opacity = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) { [self] in
                toggleColorsPalletesButton.imageView?.layer.opacity = 1
                CTAButton.configuration?.title = "Done"
                CTAButton.configuration?.image = nil
                CTAButton.configuration?.baseBackgroundColor = .backgroundSecondary
                CTAButton.configuration?.baseForegroundColor = .textSecondary
            }
        } completion: { [self] _ in
            randomizedCardButton.isHidden = true
            activateDrawModeButton.isHidden = true
            canvasView.isUserInteractionEnabled = true
        }
        
    }
    
    @objc func CTAButtonPressed(_ sender: UIButton) {
        if sender.configuration?.title == "Done" {
            doneDrawing()
        } else {
            shareImagePressed()
        }
    }
    
    @objc func cardEmojiPressed(_ sender: UIButton) {
        if emojiPicker.isHidden {
            showEmojiPicker()
        } else {
            hideEmojiPicker()
        }
    }
    
    @objc func shareImagePressed() {
        let image = RenderImage.renderImage(in: kudosCard)
        
        // image is an UIImage
        // Put the logic for uploading the image here
        self.viewModel?.upload(image: image)
    }
    
    @objc private func randomizedCardPressed(_ sender: UIButton) {
        currentCard = Card.random()
        updateCard()
    }
    
    @objc func emojiPressed(_ sender: UIButton) {
        if let selectedImage = sender.imageView?.image {
            for case let imageButton as UIButton in emojiPicker.subviews {
                if selectedImage.isEqualToImage(imageButton.imageView!.image!) {
                    imageButton.configuration?.baseBackgroundColor = .backgroundSecondary
                } else {
                    imageButton.configuration?.baseBackgroundColor = .clear
                }
            }
            
            if let imageString = selectedImage.assetName {
                let imageStringNoCompact = imageString.dropLast(8)
                let image = UIImage(named: String(imageStringNoCompact))
                cardEmojiButton.setImage(image, for: .normal)
                currentCard.emoji = String(imageStringNoCompact)
                hideEmojiPicker()
            }
        }
    }
    
    private func setupTitleOptions() {
        for case let button as UIButton in titlePicker.arrangedSubviews {
            button.addTarget(
                self,
                action: #selector(titleOptionPressed),
                for: .touchUpInside
            )
        }
    }
    
    private func showEmojiPicker() {
        emojiPicker.isHidden = false
        UIView.animateKeyframes(
            withDuration: 0.25,
            delay: 0
        ) {
            UIView.addKeyframe(
                withRelativeStartTime: 0,
                relativeDuration: 1/2
            ) { [self] in
                bottomToolbarView.transform = .init(
                    translationX: 0,
                    y: 100
                )
            }
            UIView.addKeyframe(
                withRelativeStartTime: 1/2,
                relativeDuration: 1/2
            ) { [self] in
                emojiPicker.transform = .identity
            }
        } completion: { _ in
            self.bottomToolbarView.isHidden = true
        }
    }

    private func hideEmojiPicker() {
        bottomToolbarView.isHidden = false
        UIView.animateKeyframes(
            withDuration: 0.25,
            delay: 0
        ) {
            UIView.addKeyframe(
                withRelativeStartTime: 0,
                relativeDuration: 1/2
            ) { [self] in
                emojiPicker.transform = .init(
                    translationX: 0,
                    y: 100
                )
            }
            UIView.addKeyframe(
                withRelativeStartTime: 1/2,
                relativeDuration: 1/2
            ) { [self] in
                bottomToolbarView.transform = .identity
            }
        } completion: { _ in
            self.emojiPicker.isHidden = true
        }
    }
    
    func doneDrawing() {
        randomizedCardButton.isHidden = false
        activateDrawModeButton.isHidden = false
        
        UIView.animateKeyframes(withDuration: 0.25, delay: 0) {
            UIView.addKeyframe(
                withRelativeStartTime: 0,
                relativeDuration: 1
            ) { [self] in
                CTAButton.configuration?.baseBackgroundColor = .textPrimary
                CTAButton.configuration?.baseForegroundColor = .white
            }
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) { [self] in
                randomizedCardButton.layer.opacity = 1
                activateDrawModeButton.layer.opacity = 1
                toggleColorsPalletesButton.imageView?.layer.opacity = 0
                CTAButton.configuration?.title = "Share"
                CTAButton.configuration?.image = UIImage(systemName: "paperplane.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                CTAButton.configuration?.baseBackgroundColor = .textPrimary
                CTAButton.configuration?.baseForegroundColor = .white
                
                let cardColor = CardColor.colors.first {
                    $0.background == kudosCard.backgroundColor
                }
                currentCard.color = cardColor!
                
                updateCard(updateBackground: false)
            }
        } completion: { [self] _ in
            canvasView.isUserInteractionEnabled = false
        }
    }
    
    @objc func cardTitlePressed(_ sender: UIButton) {
        if titlePicker.isHidden {
            showTitlePicker()
        } else {
            hideTitlePicker()
        }
    }
    
    @objc func titleOptionPressed(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            currentCard.title = title
            cardTitleButton.setTitle(title, for: .normal)
            hideTitlePicker()
        }
    }
    
    func showTitlePicker() {
        titlePicker.isHidden = false
        UIView.animateKeyframes(
            withDuration: 0.25,
            delay: 0
        ) {
            UIView.addKeyframe(
                withRelativeStartTime: 0,
                relativeDuration: 1/2
            ) { [self] in
                bottomToolbarView.transform = .init(
                    translationX: 0,
                    y: 100
                )
            }
            UIView.addKeyframe(
                withRelativeStartTime: 1/2,
                relativeDuration: 1/2
            ) { [self] in
                titlePicker.transform = .identity
            }
        } completion: { _ in
            self.bottomToolbarView.isHidden = true
        }
    }
    
    func hideTitlePicker() {
        bottomToolbarView.isHidden = false
        UIView.animateKeyframes(
            withDuration: 0.25,
            delay: 0
        ) {
            UIView.addKeyframe(
                withRelativeStartTime: 0,
                relativeDuration: 1/2
            ) { [self] in
                titlePicker.transform = .init(
                    translationX: 0,
                    y: 100
                )
            }
            UIView.addKeyframe(
                withRelativeStartTime: 1/2,
                relativeDuration: 1/2
            ) { [self] in
                bottomToolbarView.transform = .identity
            }
        } completion: { _ in
            self.titlePicker.isHidden = true
        }
    }
    
}

// MARK: - Gestures

extension KudosEditorViewController {
    
    @objc private func tapOnCard(_ gesture: UITapGestureRecognizer) {
        if isKeyboardShown {
            view.endEditing(true)
            return
        }

        let location = gesture.location(in: kudosCard)
        
        if kudosCard.frame.contains(location) {
            addText(at: location)
        }
    }
    
    @objc private func userDragged(gesture: UIPanGestureRecognizer){
        guard let gestureView = gesture.view else { return }
        
        let loc = gesture.location(in: kudosCard)
        
        if isKeyboardShown {
            view.endEditing(true)
        }
        
        if gesture.state == .began {
            let locationInView = gesture.location(in: gestureView)
            oldScale = gestureView.transform.scale
            
            dragStartLocation = locationInView
            triggerHaptic()
            trashView.isHidden = false
        } else if gesture.state == .changed {
            gestureView.frame.origin.x = loc.x - (dragStartLocation.x * gestureView.transform.scale)
            gestureView.frame.origin.y = loc.y - (dragStartLocation.y * gestureView.transform.scale)
            gestureView.transform = CGAffineTransform(scaleX: oldScale, y: oldScale)
            gestureView.updateConstraints()
       
            if trashView.frame.contains(loc) {
                if isFromOutsideTrashView {
                    triggerHaptic()
                    isFromOutsideTrashView = false
                    
                    UIView.animate(withDuration: 0.1) {
                        self.trashView.transform = .init(scaleX: 1.25, y: 1.25)
                    }
                }
                
                gestureView.center = trashView.center
                gestureView.transform = CGAffineTransformMakeScale(0.25, 0.25)
            } else {
                isFromOutsideTrashView = true
                UIView.animate(withDuration: 0.1) { [self] in
                    trashView.transform = .identity
                    gestureView.transform = CGAffineTransform.init(scaleX: oldScale, y: oldScale)
                }
            }
            
        } else if gesture.state == .ended {
            trashView.isHidden = true
            
            if trashView.frame.contains(loc) {
                removeView(gestureView)
            }
        }
    }
    
    @objc private func didPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        
        gestureView.transform = gestureView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }
    
}

// MARK: - Handling Text

extension KudosEditorViewController: UITextViewDelegate {
    func addText(at location: CGPoint) {
        isNewTextView = true
        
        let newTextView = UITextView(frame: .zero)
        newTextView.isScrollEnabled = false
        newTextView.textColor = currentCard.color.text
        newTextView.font = .systemFont(ofSize: 24)
        newTextView.center = location
        newTextView.backgroundColor = .none
        newTextView.layer.cornerRadius = 6
        
        newTextView.delegate = self
        
        let size = newTextView.sizeThatFits(
            CGSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        
        newTextView.frame.size = size
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(userDragged(gesture:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        
        newTextView.addGestureRecognizer(dragGesture)
        newTextView.addGestureRecognizer(pinchGesture)
        newTextView.isUserInteractionEnabled = true

        kudosCard.addSubview(newTextView)
        textViews.append(newTextView)
        
        newTextView.becomeFirstResponder()
    }
    
    // Move a textView to the top when is the first responder
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        triggerHaptic()
        hintText.isHidden = true
        
        oldScale = textView.transform.scale
        oldLocation = textView.center
        
        UIView.animate(
            withDuration: isNewTextView ? 0 : keyboardAnimationDuration ?? 0.9,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: UInt(keyboardAnimationCurve ?? 0))
        ) {
            textView.center = .init(x: (self.view.window?.windowScene?.screen.bounds.width ?? 200)/2, y: 300)
        }
        
        return true
    }
    
    // Resize textView dynamically to its content
    func textViewDidChange(_ textView: UITextView) {
        resizeTextViewToFit(textView)
    }
    
    // Return a textView to its previous location before
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        guard textView.hasText else {
            removeView(textView)
            return true
        }
        
        textView.text = removedTrailingSpace(string: textView.text)
        resizeTextViewToFit(textView)
        
        if !isNewTextView {
            UIView.animate(
                withDuration: isNewTextView ? 0 : keyboardAnimationDuration ?? 0.9,
                delay: 0,
                options: UIView.AnimationOptions(rawValue: UInt(keyboardAnimationCurve ?? 0))
            ) {
                textView.center = self.oldLocation
            }
        }
        
        return true
    }
    
    func removedTrailingSpace(string: String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func removeView(_ view: UIView) {
        trashView.isHidden = true
        triggerHaptic()
        UIView.animate(withDuration: 0.15) {
            view.alpha = 0
        } completion: { _ in
            self.textViews.removeAll(where: {$0 == view})
            view.removeFromSuperview()
        }
    }
    
    func resizeTextViewToFit(_ textView: UITextView) {
        let oldCenter = textView.center
        let newSize = textView.sizeThatFits(
            CGSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        textView.frame.size = CGSize(
            width: newSize.width * oldScale,
            height: newSize.height * oldScale
        )
        textView.center = oldCenter
    }
    
}

// MARK: - Others

extension KudosEditorViewController {
    func triggerHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    @objc func keyboardWillAppear() {
        isKeyboardShown = true
        toggleColorsPalettesPressed(forceHide: true)
    }

    @objc func keyboardWillDisappear(notification: NSNotification) {
        isKeyboardShown = false
        isNewTextView = false
        
        let userInfo = notification.userInfo
        let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        let animationCurve = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
        keyboardAnimationDuration = duration
        keyboardAnimationCurve = animationCurve
    }
    
}

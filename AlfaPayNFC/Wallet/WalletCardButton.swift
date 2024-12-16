//
//  WalletCardButton.swift
//  AlfaPayNFC
//
//  Created by Nikita Kuzmin on 16.12.2024.
//

import UIKit

final class WalletCardButton: UIButton {
    
    // MARK: - Properties
    
    private var animator: UIViewPropertyAnimator?
    private let delegate: WalletCustomViewDelegate?
    private let feedbackGenerator = UIImpactFeedbackGenerator()
    
    override var isHighlighted: Bool {
        didSet { super.isHighlighted = false }
    }
    
    // MARK: - Initialization
    
    init(
        delegate: WalletCustomViewDelegate? = nil,
        backgroundImage: UIImage = .card
    ) {
        self.delegate = delegate
        super.init(frame: .zero)
        setBackgroundImage(backgroundImage, for: [])
        setup()
        setupShadows()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WalletCardButton {
    func setup() {
        // Добавляем таргет на событие "нажатие"
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    @objc
    func touchDown() {
        feedbackGenerator.prepare()
        animate(scale: CGAffineTransform(scaleX: 0.9, y: 0.9))
    }

    @objc
    private func touchUp() {
        feedbackGenerator.impactOccurred()
        animate(scale: .identity)
    }

    @objc 
    private func buttonTapped() {
        delegate?.handleWalletButtonTapped()
    }
    
    func animate(scale: CGAffineTransform) {
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut) {
            self.transform = scale
        }
        animator?.startAnimation()
    }
    
    func setupShadows() {
        layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 10
    }
}

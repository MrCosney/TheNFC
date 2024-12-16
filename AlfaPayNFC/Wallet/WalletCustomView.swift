//
//  WalletCustomView.swift
//  AlfaPayNFC
//
//  Created by Nikita Kuzmin on 16.12.2024.
//

import UIKit

protocol WalletCustomViewDelegate: AnyObject {
    func handleWalletButtonTapped()
}

final class WalletCustomView: UIView {
    private enum Constants {
        static let mainGradientColor: UIColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        static let secondaryGradientColor: UIColor = #colorLiteral(red: 0.4941176471, green: 0.003921568627, blue: 0, alpha: 1)
        static let APayLogoSize: CGSize = CGSize(width: 135, height: 32)
    }

    // MARK: - Properties
    
    private let delegate: WalletCustomViewDelegate?

    // MARK: - Subviews
    
    private(set) lazy var cardButton = WalletCardButton(delegate: delegate)
    
    private(set) lazy var logoImageView = UIImageView(image: .aPayLogo)
    
    private let cardStackView = WalletCardStackView()
    
    private var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "Нажмите на карту для оплаты"
        view.textAlignment = .center
        view.textColor = .white
        return view
    }()
    
    private var balanceButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Показать баланс"
        config.baseBackgroundColor = .white.withAlphaComponent(0.15)
        config.image = UIImage(systemName: "eye.fill")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.contentInsets = .init(top: 10, leading: 14, bottom: 10, trailing: 14)
        config.baseForegroundColor = .white
        return UIButton(configuration: config)
    }()

    private(set) lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.colors = [Constants.mainGradientColor.cgColor, Constants.secondaryGradientColor.cgColor]
        layer.locations = [0.0, 1.0]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }()
    
    // MARK: - Initialization
    
    init(delegate: WalletCustomViewDelegate?) {
        self.delegate = delegate
        super.init(frame: UIScreen.main.bounds)
        
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

// MARK: - Private

private extension WalletCustomView {
    func addSubviews() {
        layer.addSublayer(gradientLayer)
        addSubview(logoImageView)
        addSubview(cardButton)
        addSubview(balanceButton)
        addSubview(titleLabel)
        addSubview(cardStackView)
    }
    
    func makeConstraints() {
        cardButton.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        balanceButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.heightAnchor.constraint(equalToConstant: Constants.APayLogoSize.height),
            logoImageView.widthAnchor.constraint(equalToConstant: Constants.APayLogoSize.width),
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 80),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            cardButton.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            cardButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardButton.heightAnchor.constraint(equalToConstant: 180),
            cardButton.widthAnchor.constraint(equalToConstant: 300),
                        
            balanceButton.topAnchor.constraint(equalTo: cardButton.bottomAnchor, constant: 20),
            balanceButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: balanceButton.bottomAnchor, constant: 80),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            cardStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -150),
            cardStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardStackView.heightAnchor.constraint(equalToConstant: 240),
            cardStackView.widthAnchor.constraint(equalToConstant: 300),
        ])
    }
}

//
//  CardStackView.swift
//  AlfaPayNFC
//
//  Created by Nikita Kuzmin on 16.12.2024.
//

import UIKit

final class WalletCardStackView: UIView {
    
    // MARK: - Properties
    
    private let firstCard = WalletCardButton()
    private let secondCard = WalletCardButton(backgroundImage: .whiteCard)
    private let thirdCard = WalletCardButton(backgroundImage: .blackCard)
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        addSubviews()
        makeConstaints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private

private extension WalletCardStackView {
    func addSubviews() {
        addSubview(firstCard)
        addSubview(secondCard)
        addSubview(thirdCard)
    }
    
    func makeConstaints() {
        firstCard.translatesAutoresizingMaskIntoConstraints = false
        secondCard.translatesAutoresizingMaskIntoConstraints = false
        thirdCard.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            firstCard.topAnchor.constraint(equalTo: topAnchor),
            firstCard.trailingAnchor.constraint(equalTo: trailingAnchor),
            firstCard.heightAnchor.constraint(equalToConstant: 180),
            
            secondCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            secondCard.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            secondCard.trailingAnchor.constraint(equalTo: trailingAnchor),
            secondCard.heightAnchor.constraint(equalToConstant: 180),
            
            thirdCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            thirdCard.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            thirdCard.trailingAnchor.constraint(equalTo: trailingAnchor),
            secondCard.heightAnchor.constraint(equalToConstant: 180),
        ])
    }
}

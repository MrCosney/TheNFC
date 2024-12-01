//
//  MainContentView.swift
//  NFCBro
//
//  Created by Nikita Kuzmin on 01.12.2024.
//

import UIKit
import AVFoundation

protocol MainContentViewDelegate: AnyObject {
    func didTapButton()
}

final class MainContentView: UIView {
    // MARK: - Properties
    
    private let delegate: MainContentViewDelegate?
    
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Subviews
    
    private(set) var textLabel: UILabel = {
        let view = UILabel()
        view.text = "Наведи камеру на QR-код 📸"
        view.textAlignment = .center
        view.textColor = .black
        view.font = .boldSystemFont(ofSize: 16)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) var qrStingTextLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = .white
        view.numberOfLines = .zero
        view.font = .monospacedSystemFont(ofSize: 13, weight: .semibold)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "logo"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var mainButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Сканировать"
        config.baseBackgroundColor = .black
        let view = UIButton(configuration: config)
        view.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) var scannerContainerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 35
        return view
    }()
    
    // MARK: - Initialization
    
    init(frame: CGRect, delegate: MainContentViewDelegate?) {
        self.delegate = delegate
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func setupVideoLayer(with session: AVCaptureSession?) {
        if let previewLayer {
            scannerContainerView.layer.addSublayer(previewLayer)
            return
        }
        
        guard let session, previewLayer == nil else { return }
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = scannerContainerView.bounds
        
        scannerContainerView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }
    
    func handleSuccessRecognition() {
        textLabel.isHidden = true
        previewLayer?.removeFromSuperlayer()
    }
    
    func updateLastQRString(_ string: String) {
        qrStingTextLabel.text = "🔎 Последний QR-код 🔎\n\(string)"
    }
}


// MARK: - Private

private extension MainContentView {
    @objc
    func buttonTapped() {
        textLabel.isHidden = false
        delegate?.didTapButton()
    }
    
    func addSubviews() {
        addSubview(scannerContainerView)
        addSubview(textLabel)
        addSubview(mainButton)
        scannerContainerView.addSubview(imageView)
        scannerContainerView.addSubview(qrStingTextLabel)
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scannerContainerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            scannerContainerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 30),
            scannerContainerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -30),
            scannerContainerView.heightAnchor.constraint(equalToConstant: frame.height / 2),
            
            
            imageView.topAnchor.constraint(equalTo: scannerContainerView.topAnchor, constant: 75),
            imageView.centerXAnchor.constraint(equalTo: scannerContainerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            
            textLabel.topAnchor.constraint(equalTo: scannerContainerView.bottomAnchor, constant: 10),
            textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30),
            textLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30),
            
            qrStingTextLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            qrStingTextLabel.leftAnchor.constraint(equalTo: scannerContainerView.leftAnchor, constant: 24),
            qrStingTextLabel.rightAnchor.constraint(equalTo: scannerContainerView.rightAnchor, constant: -24),
            qrStingTextLabel.bottomAnchor.constraint(equalTo: scannerContainerView.bottomAnchor, constant: -24),
            
            mainButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            mainButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 50),
            mainButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -50),
            mainButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

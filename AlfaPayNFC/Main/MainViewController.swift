//
//  ViewController.swift
//  NFCBro
//
//  Created by Nikita Kuzmin on 29.10.2024.
//

import UIKit
import CoreNFC
import AVFoundation

final class MainViewController: UIViewController {
    // MARK: - Properties

    private var captureSession: AVCaptureSession?
    private let feedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private var textToWriteInTag: String = .empty
    
    private(set) lazy var contentView = MainContentView(
        frame: UIScreen.main.bounds,
        delegate: self
    )
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCaptureSession()
    }
}

// MARK: - MainContentViewDelegate

extension MainViewController: MainContentViewDelegate {
    func didTapButton() {
        feedbackGenerator.impactOccurred()
        captureSession?.stopRunning()
        contentView.setupVideoLayer(with: captureSession)
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension MainViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let qrCodeString = object.stringValue,
            !qrCodeString.isEmpty
        else {
            return
        }
        handleSuccessRecognition()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            textToWriteInTag = stringValue
            contentView.updateLastQRString(stringValue)
            showAlert(
                title: "QR-Код распознан 🔥",
                message: "Данные в коде: \(stringValue)",
                action: UIAlertAction(
                    title: "Записать в метку 💾",
                    style: .destructive,
                    handler: { [weak self] _ in
                        self?.pushWalletController()
                    }
                )
            )
        }
    }
}


// MARK: - Private

private extension MainViewController {
    var codeTypes: [AVMetadataObject.ObjectType] {
        [
            .upce,
            .code39,
            .code39Mod43,
            .code93,
            .code128,
            .ean8,
            .ean13,
            .aztec,
            .pdf417,
            .itf14,
            .dataMatrix,
            .interleaved2of5,
            .qr,
        ]
    }
    
    func pushWalletController() {
        let walletVC = WalletController(textToWriteInTag: textToWriteInTag)
        navigationController?.pushViewController(walletVC, animated: true)
    }
    
    func createCaptureSession() {
        guard
            let avCaptureDeviceType = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: avCaptureDeviceType)
        else {
            showErrorAlert(message: "Нужен доступ к камере 📸")
            return
        }
        let session = AVCaptureSession()
        session.addInput(input)
    
        let metadataOutput = AVCaptureMetadataOutput()
        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = codeTypes
        
        captureSession = session
    }
    
    func handleSuccessRecognition() {
        captureSession?.stopRunning()
        feedbackGenerator.impactOccurred()
        contentView.handleSuccessRecognition()
    }
    
    func showAlert(
        title: String,
        message: String,
        action: UIAlertAction
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "🫡", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

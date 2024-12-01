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
    
    private var NFCReaderSession: NFCNDEFReaderSession?
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
                        self?.startReaderSession()
                    }
                )
            )
        }
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension MainViewController: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
    
        session.connect(to: tag) { [weak self] error in
            guard let self else { return }
            if error != nil {
                showErrorAlert(message: String(describing: error))
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus { status, value, error in
                switch status {
                case .notSupported:
                    print("Доступ notSupported")
                    session.alertMessage = "Не поддерживаем"
                case .readOnly:
                    print("Доступ readOnly")
                    session.alertMessage = "Таг доступен только для записи"
                case .readWrite:
                    print("Text to write in tag: \(self.textToWriteInTag)")
                    let payload = [
                        NFCNDEFPayload(
                            format: .nfcWellKnown,
                            type: "T".data(using: .utf8)!,
                            identifier: Data.init(count: 0),
                            payload: self.textToWriteInTag.data(using: .utf8)!
                        )]
                    tag.writeNDEF(.init(records: payload)) { error in
                        if nil != error {
                            session.alertMessage = String(describing: error?.localizedDescription)
                        } else {
                            session.alertMessage = "Текст успешно записан на метку🚀"
                        }
                        session.invalidate()
                    }
                    
                @unknown default:
                    session.alertMessage = "Неизвестная ошибка"
                    session.invalidate()
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) { }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {}
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
    
    func startReaderSession() {
        NFCReaderSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        NFCReaderSession?.alertMessage = "Приложите телефон к терминалу 📲"
        NFCReaderSession?.begin()
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

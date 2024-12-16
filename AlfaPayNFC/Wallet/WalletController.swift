//
//  WalletController.swift
//  AlfaPayNFC
//
//  Created by Nikita Kuzmin on 16.12.2024.
//

import CoreNFC
import UIKit
import AVFoundation

final class WalletController: UIViewController {
    
    // MARK: - Properties

    private var NFCReaderSession: NFCNDEFReaderSession?
    
    private let textToWriteInTag: String
    
    private(set) lazy var contentView = WalletCustomView(delegate: self)
    private var successSound: SystemSoundID = 0
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSuccessSound()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Initialization
    
    init(textToWriteInTag: String) {
        self.textToWriteInTag = textToWriteInTag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if successSound != 0 {
            AudioServicesDisposeSystemSoundID(successSound)
        }
    }
}


// MARK: - NFCNDEFReaderSessionDelegate

extension WalletController: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
    
        session.connect(to: tag) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
                session.invalidate()
                return
            }
            self.writeDataToTag(session: session, tag: tag)
        }
    }
    
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    }
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) { }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {}
}

// MARK: - WalletCustomViewDelegate

extension WalletController: WalletCustomViewDelegate {
    func handleWalletButtonTapped() {
        NFCReaderSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        NFCReaderSession?.alertMessage = "Приложите телефон к терминалу 📲"
        NFCReaderSession?.begin()
    }
    
    func handleBalanceButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Private

private extension WalletController {
    func loadSuccessSound() {
        if let soundURL = Bundle.main.url(forResource: "success", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &successSound)
        } else {
            print("Не удалось загрузить звуковой файл 'success.wav'")
        }
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
    
    func writeDataToTag(session: NFCNDEFReaderSession, tag: NFCNDEFTag) {
        tag.queryNDEFStatus { status, capacity, error in
            if let error = error {
                session.alertMessage = "Ошибка чтения статуса NDEF: \(error.localizedDescription)"
                session.invalidate()
                return
            }
            switch status {
            case .notSupported:
                print("Доступ notSupported")
                session.alertMessage = "Метка не поддерживает NDEF"
                session.invalidate()
            case .readOnly:
                print("Доступ readOnly")
                session.alertMessage = "Метка доступна только для чтения"
                session.invalidate()
            case .readWrite:
                print("Text to write in tag: \(self.textToWriteInTag)")
                // Проверяем, что метка имеет достаточную емкость
                guard let textData = self.textToWriteInTag.data(using: .utf8) else {
                    session.alertMessage = "Ошибка кодирования текста"
                    session.invalidate()
                    return
                }
                if textData.count > capacity {
                    session.alertMessage = "Сообщение слишком большое для записи на метку"
                    session.invalidate()
                    return
                }
                // Создаем NDEF-запись с явной кодировкой UTF-8
                if let payload = self.createTextPayload(text: self.textToWriteInTag) {
                    let message = NFCNDEFMessage(records: [payload])
                    tag.writeNDEF(message) { error in
                        if let error = error {
                            session.alertMessage = "Ошибка записи: \(error.localizedDescription)"
                        } else {
                            session.alertMessage = "Текст успешно записан на метку 🚀"
                            AudioServicesPlaySystemSound(self.successSound) // Проигрываем звук
                        }
                        session.invalidate()
                    }
                } else {
                    session.alertMessage = "Не удалось создать NDEF-запись"
                    session.invalidate()
                }
            @unknown default:
                session.alertMessage = "Неизвестный статус NDEF"
                session.invalidate()
            }
        }
    }
    
    func createTextPayload(text: String) -> NFCNDEFPayload? {
        let languageCode = "en"
        guard
            let languageCodeData = languageCode.data(using: .ascii),
            let textData = text.data(using: .utf8)
        else {
            return nil
        }
        var payload = Data()
        let statusByte = UInt8(languageCodeData.count & 0x3F)
        payload.append(statusByte)
        payload.append(languageCodeData)
        payload.append(textData)
        return NFCNDEFPayload(
            format: .nfcWellKnown,
            type: "T".data(using: .ascii)!,
            identifier: Data(),
            payload: payload
        )
    }
}

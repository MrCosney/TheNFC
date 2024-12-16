//
//  WalletController.swift
//  AlfaPayNFC
//
//  Created by Nikita Kuzmin on 16.12.2024.
//

import CoreNFC
import UIKit

final class WalletController: UIViewController {

    private var NFCReaderSession: NFCNDEFReaderSession?
    
    private let textToWriteInTag: String
    
    private(set) lazy var contentView = WalletCustomView(delegate: self)
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(textToWriteInTag: String) {
        self.textToWriteInTag = textToWriteInTag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}


// MARK: - NFCNDEFReaderSessionDelegate

extension WalletController: NFCNDEFReaderSessionDelegate {
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
    
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    }
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) { }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {}
}

extension WalletController: WalletCustomViewDelegate {
    func handleWalletButtonTapped() {
        NFCReaderSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        NFCReaderSession?.alertMessage = "Приложите телефон к терминалу 📲"
        NFCReaderSession?.begin()
    }
}

// MARK: - Private

private extension WalletController {
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

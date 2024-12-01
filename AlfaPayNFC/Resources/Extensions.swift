//
//  Extensions.swift
//  NFCBro
//
//  Created by Nikita Kuzmin on 01.12.2024.
//

import UIKit

extension UIAlertController{
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.tintColor = .black
    }
 }

// MARK: - String+Extension

extension String {
    static var empty: String { "" }
}

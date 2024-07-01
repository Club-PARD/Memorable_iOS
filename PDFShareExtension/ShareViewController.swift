//
//  ShareViewController.swift
//  PDFShareExtension
//
//  Created by 김현기 on 6/30/24.
//

import MobileCoreServices
import SnapKit
import Social
import Then
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        presentAlertController()
    }

    // MARK: - PDF Methods

    // MARK: - URL Scheme Method

    // MARK: - General Settings

    func presentAlertController() {
        let alertController = UIAlertController(title: "Memorable로 열기", message: "이 PDF를 Memorable 앱에서 열겠습니까?", preferredStyle: .alert)

        let openAction = UIAlertAction(title: "열기", style: .default) { [weak self] _ in
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }

        alertController.addAction(openAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
}

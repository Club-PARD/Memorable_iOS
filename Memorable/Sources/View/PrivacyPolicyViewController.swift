//
//  PrivacyPolicy.swift
//  Memorable
//
//  Created by 김현기 on 7/10/24.
//

import PDFKit
import SnapKit
import Then
import UIKit

class PrivacyPolicyViewController: UIViewController {
    private lazy var pdfView = PDFView().then {
        $0.autoScales = true
        $0.displayMode = .singlePageContinuous
        $0.displayDirection = .vertical
    }

    var pdfData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MemorableColor.White

        view.addSubview(pdfView)

        pdfView.snp.makeConstraints { make in
            make.top.trailing.leading.bottom.equalToSuperview()
        }

        loadPDF()
    }

    private func loadPDF() {
        guard let url = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "pdf") else { return }
        print("PDF URL: \(url)")

        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }
}

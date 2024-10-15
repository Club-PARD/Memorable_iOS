//
//  ShareViewController.swift
//  PDFShareExtension
//
//  Created by 김현기 on 6/30/24.
//

import MobileCoreServices
import PDFKit
import UIKit
import UniformTypeIdentifiers
import Vision

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        handleSharedItems()
    }

    private func getExistingCategories() -> [String] {
        let userDefaults = UserDefaults(suiteName: "group.io.pard.Memorable24")
        return userDefaults?.stringArray(forKey: "ExistingCategories") ?? []
    }

    func handleSharedItems() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return
        }

        for item in extensionItems {
            guard let attachments = item.attachments else {
                continue
            }

            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.pdf.identifier, options: nil) { [weak self] url, error in
                        if let pdfURL = url as? URL {
                            self?.extractAndSaveFromPDF(pdfURL)
                        } else {
                            print("Failed to load PDF: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] url, error in
                        if let imageURL = url as? URL {
                            self?.extractAndSaveFromImage(imageURL)
                        } else {
                            print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
            }
        }
    }

    func extractAndSaveFromPDF(_ pdfURL: URL) {
        let fileName = pdfURL.lastPathComponent
        extractTextFromPDF(url: pdfURL) { extractedText in
            self.saveAndShowNameAlert(fileName: fileName, fileType: "PDF", extractedText: extractedText)
        }
    }

    func extractAndSaveFromImage(_ imageURL: URL) {
        let fileName = imageURL.lastPathComponent
        extractTextFromImage(url: imageURL) { extractedText in
            self.saveAndShowNameAlert(fileName: fileName, fileType: "Image", extractedText: extractedText)
        }
    }

    func extractTextFromPDF(url: URL, completion: @escaping (String) -> Void) {
        guard let pdfDocument = PDFDocument(url: url) else {
            completion("")
            return
        }

        var extractedText = ""
        let pageCount = pdfDocument.pageCount
        let batchSize = 5 // Adjust based on testing

        func processBatch(startIndex: Int) {
            let endIndex = min(startIndex + batchSize, pageCount)
            let dispatchGroup = DispatchGroup()

            for pageIndex in startIndex ..< endIndex {
                if let page = pdfDocument.page(at: pageIndex) {
                    if let pageText = page.string {
                        extractedText += pageText
                    }

                    let pageImage = page.thumbnail(of: page.bounds(for: .mediaBox).size, for: .mediaBox)
                    dispatchGroup.enter()
                    recognizeTextInImage(image: pageImage) { recognizedText in
                        extractedText += recognizedText
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                if endIndex < pageCount {
                    processBatch(startIndex: endIndex)
                } else {
                    completion(extractedText)
                }
            }
        }

        processBatch(startIndex: 0)
    }

    func extractTextFromImage(url: URL, completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            guard let image = UIImage(contentsOfFile: url.path) else {
                DispatchQueue.main.async { completion("") }
                return
            }

            let downsampledImage = self.downsampleImage(image, to: CGSize(width: 1024, height: 1024))

            self.recognizeTextInImage(image: downsampledImage) { recognizedText in
                DispatchQueue.main.async { completion(recognizedText) }
            }
        }
    }

    func downsampleImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func recognizeTextInImage(image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            let result = recognizedStrings.joined(separator: "\n")
            completion(result)
        }
        request.recognitionLanguages = ["ko", "en"]

        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error)")
            completion("")
        }
    }

    func saveAndShowNameAlert(fileName: String, fileType: String, extractedText: String) {
        DispatchQueue.main.async {
            self.showNameAlert(fileName: fileName, extractedText: extractedText)
        }
    }

    func showNameAlert(fileName: String, extractedText: String) {
        let nameAlertController = UIAlertController(title: "이름 설정하기", message: "해당 학습지의 이름을 설정해 주세요", preferredStyle: .alert)
        nameAlertController.addTextField { textField in
            textField.placeholder = fileName
            textField.text = fileName
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
        }
        let nameConfirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let sheetName = nameAlertController.textFields?.first?.text, !sheetName.isEmpty else { return }
            self?.showCategoryAlert(sheetName: sheetName, extractedText: extractedText)
        }
        let nameCancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }

        nameAlertController.addAction(nameConfirmAction)
        nameAlertController.addAction(nameCancelAction)

        present(nameAlertController, animated: true, completion: nil)
    }

    func showCategoryAlert(sheetName: String, extractedText: String) {
        let existingCategories = getExistingCategories()
        let categoryAlertController = UIAlertController(title: "카테고리 설정하기", message: "학습지의 카테고리를 설정해 주세요", preferredStyle: .alert)

        for category in existingCategories {
            let action = UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.openMemorableApp(with: sheetName, category: category, extractedText: extractedText)
            }
            categoryAlertController.addAction(action)
        }

        categoryAlertController.addTextField { textField in
            textField.placeholder = "새 카테고리"
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
        }

        let categoryConfirmAction = UIAlertAction(title: "새 카테고리 추가", style: .default) { [weak self] _ in
            guard let category = categoryAlertController.textFields?.first?.text, !category.isEmpty else { return }
            self?.openMemorableApp(with: sheetName, category: category, extractedText: extractedText)
        }

        let categoryCancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            self?.showNameAlert(fileName: sheetName, extractedText: extractedText)
        }

        categoryAlertController.addAction(categoryConfirmAction)
        categoryAlertController.addAction(categoryCancelAction)

        present(categoryAlertController, animated: true, completion: nil)
    }

    func openMemorableApp(with sheetName: String, category: String, extractedText: String) {
        // Save data to UserDefaults or other storage for use in SceneDelegate
        let userDefaults = UserDefaults(suiteName: "group.io.pard.Memorable24")
        userDefaults?.set(sheetName, forKey: "sheetName")
        userDefaults?.set(category, forKey: "sheetCategory")
        userDefaults?.set(extractedText, forKey: "sheetText")
        userDefaults?.synchronize()

        // Construct URL with query parameters
        var components = URLComponents()
        components.scheme = "memorable"
        components.host = "worksheet"
        components.queryItems = [
            URLQueryItem(name: "name", value: sheetName),
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "text", value: extractedText)
        ]

        guard let url = components.url else {
            print("Invalid URL")
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        // 먼저 extensionContext를 완료합니다.
        extensionContext?.completeRequest(returningItems: nil, completionHandler: { [weak self] _ in
            // 그 다음 URL을 엽니다.
            print("Generated URL: \(url)")
            self?.openURL(url)
        })
    }

    @objc func openURL(_ url: URL) {
        print("Generated URL: \(url)")
        let selector = sel_registerName("openURL:")
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.perform(selector, with: url)
                break
            }
            responder = responder?.next
        }

        // URL을 열지 못한 경우를 대비해 extensionContext를 여기서 완료합니다.
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}

//
//  Document.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/27/24.
//

import Foundation

struct Document {
    let fileName: String
    let fileType: String
    let category: String
    var bookmark: Bool
    let date: Date
}

func makeDate(year: Int, month: Int, day: Int) -> Date {
    let calendar = Calendar.current
    let components = DateComponents(year: year, month: month, day: day)
    return calendar.date(from: components) ?? Date()
}

//import Foundation
//
//enum DocumentType: String, Decodable {
//    case worksheet
//    case test
//    case correctionNote
//}
//
//struct Document: Decodable {
//    let id: Int
//    let name: String
//    let category: String
//    var bookmark: Bool
//    let date: Date
//    let documentType: DocumentType
//    let keywords: [String]?
//    let questions: [String]?
//    let answers: [String]
//    let content: String?
//    let wrongAnswers: [String]?
//}
//
//func makeDate(year: Int, month: Int, day: Int) -> Date {
//    let calendar = Calendar.current
//    let components = DateComponents(year: year, month: month, day: day)
//    return calendar.date(from: components) ?? Date()
//}
//


//import Foundation
//
//// JSON 데이터 (예시)
//let jsonData = """
//[
//  {
//    "id": 1,
//    "name": "Alice",
//    "favor": "Reading",
//    "files": [
//      {
//        "id": 1,
//        "fileName": "File 1",
//        "worksheets": [
//          {
//            "id": 1,
//            "content": "Worksheet 1"
//          }
//        ],
//        "tests": [
//          {
//            "id": 1,
//            "content": "Test 1"
//          }
//        ],
//        "correctionNotes": []
//      },
//      {
//        "id": 2,
//        "fileName": "File 2",
//        "worksheets": [
//          {
//            "id": 1,
//            "content": "Worksheet 1"
//          }
//        ],
//        "tests": [],
//        "correctionNotes": []
//      }
//    ]
//  }
//]
//""".data(using: .utf8)!
//
//struct FileData: Decodable {
//    let id: Int
//    let fileName: String
//    let worksheets: [WorksheetData]
//    let tests: [TestData]
//    let correctionNotes: [CorrectionNoteData]
//}
//
//struct WorksheetData: Decodable {
//    let id: Int
//    let content: String
//}
//
//struct TestData: Decodable {
//    let id: Int
//    let content: String
//}
//
//struct CorrectionNoteData: Decodable {
//    let id: Int
//    let content: String
//}
//
//struct UserData: Decodable {
//    let id: Int
//    let name: String
//    let favor: String
//    let files: [FileData]
//}
//
//do {
//    let users = try JSONDecoder().decode([UserData].self, from: jsonData)
//    
//    var documents: [Document] = []
//
//    for user in users {
//        for file in user.files {
//            for worksheet in file.worksheets {
//                let document = Document(
//                    id: worksheet.id,
//                    name: file.fileName,
//                    category: "Worksheet",
//                    bookmark: false,
//                    date: Date(), // Adjust date parsing as needed
//                    documentType: .worksheet,
//                    keywords: [], // Add actual keywords if available
//                    questions: nil,
//                    answers: [],
//                    content: worksheet.content,
//                    wrongAnswers: nil
//                )
//                documents.append(document)
//            }
//
//            for test in file.tests {
//                let document = Document(
//                    id: test.id,
//                    name: file.fileName,
//                    category: "Test",
//                    bookmark: false,
//                    date: Date(), // Adjust date parsing as needed
//                    documentType: .test,
//                    keywords: nil,
//                    questions: [], // Add actual questions if available
//                    answers: [],
//                    content: test.content,
//                    wrongAnswers: nil
//                )
//                documents.append(document)
//            }
//
//            for correctionNote in file.correctionNotes {
//                let document = Document(
//                    id: correctionNote.id,
//                    name: file.fileName,
//                    category: "CorrectionNote",
//                    bookmark: false,
//                    date: Date(), // Adjust date parsing as needed
//                    documentType: .correctionNote,
//                    keywords: nil,
//                    questions: [], // Add actual questions if available
//                    answers: [],
//                    content: correctionNote.content,
//                    wrongAnswers: []
//                )
//                documents.append(document)
//            }
//        }
//    }
//    
//    // 디코딩된 Document 목록을 확인합니다.
//    for document in documents {
//        print(document)
//    }
//} catch {
//    print("Failed to decode JSON: \(error)")
//}


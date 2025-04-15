//
//  FileScannerService.swift
//  XcodeHelper
//
//  Created by 米粒 on 2025/4/3.
//

import Foundation

class FileScannerService: ObservableObject {
    
    static let shared = FileScannerService()
    
    private let defaults = UserDefaults.standard
    
    private init() {
        
    }
    
    @Published var todoItems: [TodoItem] = []
    
    ///扫描文件功能
    func scanAllPathsForTODOs(from path: [SecurePath]) -> [TodoItem] {
        var result: [TodoItem] = []
        guard !path.isEmpty else {
            print("尚未添加任何掃描路徑")
            return []
        }
        for secure in path {
            do {
                var isStale = false
                let url = try URL(
                    resolvingBookmarkData: secure.bookmarkData,
                    options: [.withSecurityScope],
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                
                guard url.startAccessingSecurityScopedResource() else {
                    print("無法訪問目錄：\(secure.path)")
                    continue
                }
                
                let fileManager = FileManager.default
                let enumerator = fileManager.enumerator(atPath: url.path)
                
                while let element = enumerator?.nextObject() as? String {
                    guard element.hasSuffix(".swift") else { continue }
                    let fullPath = (url.path as NSString).appendingPathComponent(element)
                    let fileName = (fullPath as NSString).lastPathComponent
                    
                    if let content = try? String(contentsOfFile: fullPath) {
                        let lines = content.components(separatedBy: .newlines)
                        
                        for (i, line) in lines.enumerated() {
                            let trimmed = line.trimmingCharacters(in: .whitespaces)
                            if trimmed.hasPrefix("//TODO") || trimmed.hasPrefix("// TODO") {
                                let cleaned = trimmed
                                    .replacingOccurrences(of: "//TODO: ", with: "", options: .caseInsensitive)
                                    .replacingOccurrences(of: "// TODO:", with: "", options: .caseInsensitive)
                                    .trimmingCharacters(in: .whitespaces)
                                result.append(TodoItem(filePath: fullPath, fileName: fileName, lineNumber: i + 1, content: cleaned))
                            }
                        }
                    }
                }
                
                url.stopAccessingSecurityScopedResource()
                
            } catch {
                print("無法解析 bookmark：\(secure.path)，錯誤：\(error)")
            }
        }
        
        return result
    }
}

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
        self.storedPaths = defaults.storedBookmarks
        if !self.storedPaths.isEmpty {
            self.todoItems = scanAllPathsForTODOs()
        }
    }
    
    
    
    /// 当前已保存的路径列表
    @Published var storedPaths: [SecurePath] {
        didSet {
            defaults.storedBookmarks = storedPaths
        }
    }
    
    @Published var todoItems: [TodoItem] = []
    
    ///扫描文件功能
    func scanAllPathsForTODOs() -> [TodoItem] {
        var result: [TodoItem] = []
        
        for secure in storedPaths {
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
                                result.append(
                                    TodoItem(filePath: fullPath, fileName: fileName, lineNumber: i + 1, content: trimmed)
                                )
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

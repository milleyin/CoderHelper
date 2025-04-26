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
                        let projectInfo = detectProjectInfo(in: URL(fileURLWithPath: fullPath)) ?? (name: "Unknown", path: "")
                        for (i, line) in lines.enumerated() {
                            let trimmed = line.trimmingCharacters(in: .whitespaces)
                            if trimmed.hasPrefix("//TODO") || trimmed.hasPrefix("// TODO") {
                                let cleaned = trimmed
                                    .replacingOccurrences(of: "//TODO: ", with: "", options: .caseInsensitive)
                                    .replacingOccurrences(of: "// TODO:", with: "", options: .caseInsensitive)
                                    .trimmingCharacters(in: .whitespaces)
                                result.append(TodoItem(filePath: fullPath, fileName: fileName, projectName: projectInfo.name, projectPath: projectInfo.path, lineNumber: i + 1, content: cleaned))
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
    /// 探測專案名稱 (.xcodeproj > Package.swift)：從當前目錄一路向上找專案名稱與路徑 (.xcodeproj > Package.swift)
    private func detectProjectInfo(in url: URL) -> (name: String, path: String)? {
        var currentURL = url
        let fileManager = FileManager.default

        while true {
            if let files = try? fileManager.contentsOfDirectory(atPath: currentURL.path) {
                if let xcodeproj = files.first(where: { $0.hasSuffix(".xcodeproj") }) {
                    let name = (xcodeproj as NSString).deletingPathExtension
                    let projectPath = currentURL.appendingPathComponent(xcodeproj).path
                    return (name: name, path: projectPath)
                }
            }

            let packageSwiftPath = currentURL.appendingPathComponent("Package.swift")
            if fileManager.fileExists(atPath: packageSwiftPath.path) {
                let name: String
                if let content = try? String(contentsOfFile: packageSwiftPath.path),
                   let match = content.range(of: #"name:\s*\"([^\"]+)\""#, options: .regularExpression) {
                    let matchedString = String(content[match])
                    name = matchedString
                        .replacingOccurrences(of: "name:", with: "")
                        .replacingOccurrences(of: "\"", with: "")
                        .trimmingCharacters(in: .whitespaces)
                } else {
                    name = "Unknown"
                }
                return (name: name, path: packageSwiftPath.path)
            }

            if currentURL.path == "/" {
                break
            }
            currentURL.deleteLastPathComponent()
        }

        return nil
    }

}

//
//  SettingsViewModel.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/27.
//

import Foundation
import DevelopmentKit
import AppKit

class SettingsViewModel: ObservableObject {
    
    private let defaults = UserDefaults.standard
    
    /// 当前已保存的路径列表
    @Published var storedPaths: [SecurePath] {
        didSet {
            defaults.storedBookmarks = storedPaths
        }
    }
    /// 是否自动同步
    @Published var autoSyncToReminders: Bool {
        didSet {
            defaults.autoSyncToReminders = autoSyncToReminders
        }
    }
    
    /// 扫描频率
    @Published var scanFrequency: ScanFrequency {
        didSet {
            defaults.scanFrequency = scanFrequency
        }
    }
    
    /// 是否启用 Xcode 活动监听
    @Published var enableXcodeTracking: Bool {
        didSet {
            defaults.enableXcodeTracking = enableXcodeTracking
        }
    }
    
    
    init() {
        self.storedPaths = defaults.storedBookmarks
        self.autoSyncToReminders = defaults.autoSyncToReminders
        self.scanFrequency = defaults.scanFrequency
        self.enableXcodeTracking = defaults.enableXcodeTracking
    }
}
//TODO: 测试todo扫描功能
//MARK: - 扫描路径
extension SettingsViewModel {
    ///添加路径
    func addPath() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "選擇資料夾"
        
        if panel.runModal() == .OK, let selectedURL = panel.url {
            do {
                let standardizedURL = selectedURL.standardizedFileURL
                let bookmarkData = try standardizedURL.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                
                let newSecurePath = SecurePath(path: standardizedURL.path, bookmarkData: bookmarkData)
                
                if !storedPaths.contains(where: { $0.path == newSecurePath.path }) {
                    storedPaths.append(newSecurePath)
                } else {
                    print("⚠️ 該路徑已存在")
                }
                
            } catch {
                print("Bookmark 儲存失敗：\(error)")
            }
        }
    }
    ///删除路径
    func removePath(_ path: String) {
        storedPaths.removeAll { $0.path == path }
    }
}

//MARK: - 扫描

extension SettingsViewModel {
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

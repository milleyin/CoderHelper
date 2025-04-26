//
//  SettingsViewModel.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/27.
//

import Foundation
import DevelopmentKit
import AppKit
import Combine

class SettingsViewModel: ObservableObject {
    
    init() {
        scanStoredPaths()
    }
    
    var subscriptions: Set<AnyCancellable> = .init()
    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }
}
//TODO: 测试todo扫描功能1
//TODO: 测试todo扫描功能2
//TODO: 测试todo扫描功能3
//TODO: 测试todo扫描功能4
//TODO: 测试todo扫描功能4
//TODO: 测试todo扫描功能4

//MARK: - 路径
extension SettingsViewModel {
    ///添加路径
    func addPath() {
        let panel = NSOpenPanel()
        panel.title = "選擇你的項目文件夾，可選包含多個項目的父級文件夾"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let selectedURL = panel.url {
            do {
                let standardizedURL = selectedURL.standardizedFileURL
                
                // 這裡生成 SecurityScopedBookmark
                let bookmarkData = try standardizedURL.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                
                // 假訪問一次，系統記錄授權
                var isStale = false
                let accessURL = try URL(resolvingBookmarkData: bookmarkData, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale)
                
                if accessURL.startAccessingSecurityScopedResource() {
                    defer { accessURL.stopAccessingSecurityScopedResource() }
                    
                    print("✅ 成功訪問並授權：\(standardizedURL.path)")
                    
                    // 保存 SecurePath
                    let newSecurePath = SecurePath(path: standardizedURL.path, bookmarkData: bookmarkData)
                    UserSettings.shared.storedPaths.append(newSecurePath)
                } else {
                    print("❌ 無法訪問選定路徑")
                }
            } catch {
                print("❌ 授權過程出錯：\(error)")
            }
        }
    }
    ///删除路径
    func removePath(_ path: String) {
        UserSettings.shared.storedPaths.removeAll { $0.path == path }
    }
}

extension SettingsViewModel {
    ///扫描添加的路径
    func scanStoredPaths() {
        UserSettings.shared.$storedPaths
            .sink { newPaths in
                print("🟢 接收到新路徑：", newPaths.map { $0.path })
                guard !newPaths.isEmpty else {
                    print("尚未添加任何掃描路徑")
                    return
                }
                let items = FileScannerService.shared.scanAllPathsForTODOs(from: newPaths)
                DispatchQueue.main.async {
                    FileScannerService.shared.todoItems = items
                }
            }
            .store(in: &subscriptions)
    }
}


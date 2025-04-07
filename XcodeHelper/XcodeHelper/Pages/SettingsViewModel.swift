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

//MARK: - 路径
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
                
                if !UserSettings.shared.storedPaths.contains(where: { $0.path == newSecurePath.path }) {
                    UserSettings.shared.storedPaths.append(newSecurePath)
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


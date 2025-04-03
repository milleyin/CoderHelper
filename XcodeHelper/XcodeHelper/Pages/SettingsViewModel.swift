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
        
        self.autoSyncToReminders = defaults.autoSyncToReminders
        self.scanFrequency = defaults.scanFrequency
        self.enableXcodeTracking = defaults.enableXcodeTracking
    }
}
//TODO: 测试todo扫描功能1
//TODO: 测试todo扫描功能2
//TODO: 测试todo扫描功能3
//TODO: 测试todo扫描功能4
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
                
                if !FileScannerService.shared.storedPaths.contains(where: { $0.path == newSecurePath.path }) {
                    FileScannerService.shared.storedPaths.append(newSecurePath)
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
        FileScannerService.shared.storedPaths.removeAll { $0.path == path }
    }
}


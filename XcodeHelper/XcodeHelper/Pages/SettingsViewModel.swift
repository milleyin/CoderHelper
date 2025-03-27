//
//  SettingsViewModel.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/27.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    private let defaults = UserDefaults.standard
    
    /// 当前已保存的路径列表
    @Published var storedPaths: [String] {
        didSet {
            defaults.storedPaths = storedPaths
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
        self.storedPaths = defaults.storedPaths
        self.autoSyncToReminders = defaults.autoSyncToReminders
        self.scanFrequency = defaults.scanFrequency
        self.enableXcodeTracking = defaults.enableXcodeTracking
    }
}

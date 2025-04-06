//
//  UserSettings.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/4/5.
//

import Foundation
import EventKit

class UserSettings: ObservableObject {
    
    static let shared = UserSettings()
    
    private let defaults = UserDefaults.standard
    
    /// 当前已保存的路径列表
    @Published var storedPaths: [SecurePath] {
        didSet {
            defaults.storedBookmarks = storedPaths
        }
    }
    
    /// 是否自动同步到提醒事项
    @Published var autoSyncToReminders: Bool = false {
        didSet {
            defaults.autoSyncToReminders = autoSyncToReminders
            if autoSyncToReminders, EKEventStore.authorizationStatus(for: .reminder) == .denied {
                // 用户之前拒绝过，现在又尝试开启 —— 说明用户“变卦了”
                // 👉 主动提示：去系统设置打开权限
                isShowEnableRemindersAuthorizationAlert = true

            } else if autoSyncToReminders, !ReminderService.shared.isAuthorized {
                // 用户刚开启同步功能，但还没有系统授权 —— 初次尝试
                // 👉 请求系统弹授权弹窗
                ReminderService.shared.requestAccessIfNeeded()
            }
            
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
    
    ///提示用户手动开启提醒事项授权
    @Published var isShowEnableRemindersAuthorizationAlert: Bool = false
    
    init() {
        self.storedPaths = defaults.storedBookmarks
        self.autoSyncToReminders = defaults.autoSyncToReminders
        self.scanFrequency = defaults.scanFrequency
        self.enableXcodeTracking = defaults.enableXcodeTracking
    }
    
}

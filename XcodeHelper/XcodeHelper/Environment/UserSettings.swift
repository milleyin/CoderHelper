//
//  UserSettings.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/4/5.
//

import Foundation
import EventKit
import Combine

class UserSettings: ObservableObject {
    
    static let shared = UserSettings()
    
    private let defaults = UserDefaults.standard
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.storedPaths = defaults.storedBookmarks
        self.autoSyncToReminders = defaults.autoSyncToReminders
        self.scanFrequency = defaults.scanFrequency
        self.enableXcodeTracking = defaults.enableXcodeTracking
        
    }
    
    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }
    
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
            
            guard autoSyncToReminders else { return }
            
            let status = AuthorizationManager.shared.reminderAuthorizationStatus
            
            switch status {
            case .fullAccess:
                // 正常启用
                _ = ReminderService.shared
            case .denied:
                // 已明确拒绝，不再请求授权，转为提醒用户
                self.autoSyncToReminders = false
                self.isShowEnableRemindersAuthorizationAlert = true
            case .notDetermined:
                // 尚未请求，主动请求授权
                AuthorizationManager.shared.requestReminderAccess { granted in
                    if !granted {
                        DispatchQueue.main.async {
                            self.autoSyncToReminders = false
                            self.isShowEnableRemindersAuthorizationAlert = true
                        }
                    }
                }
            case .restricted:
                // 家长控制等情况，直接关掉
                self.autoSyncToReminders = false
                self.isShowEnableRemindersAuthorizationAlert = true
            default:
                break
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
    
    
}

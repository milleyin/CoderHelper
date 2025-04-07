//
//  AuthorizationManager.swift
//  XcodeHelper
//
//  Created by mille on 2025/4/7.
//

import Foundation
import EventKit
import Combine

final class AuthorizationManager: ObservableObject {
    static let shared = AuthorizationManager()

    private let eventStore = EKEventStore()

    /// 當前提醒事項授權狀態（統一來源）
    @Published private(set) var reminderAuthorizationStatus: EKAuthorizationStatus = .notDetermined

    /// 是否已完全授權提醒事項
    var isReminderAuthorized: Bool {
        reminderAuthorizationStatus == .fullAccess
    }

    private init() {
        self.reminderAuthorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
    }

    /// 主動發起系統授權請求
    func requestReminderAccess(completion: ((Bool) -> Void)? = nil) {
        eventStore.requestFullAccessToReminders { [weak self] granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ 授權提醒事項失敗：\(error.localizedDescription)")
                    completion?(false)
                    return
                }
                print(granted ? "✅ 已授權提醒事項" : "❌ 拒絕提醒事項權限")
                self?.refreshReminderAuthorizationStatus()
                if granted {
                    _ = ReminderService.shared
                }
                completion?(granted)
            }
        }
    }

    /// 同步刷新當前授權狀態（一般在授權彈窗後使用）
    func refreshReminderAuthorizationStatus() {
        reminderAuthorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
    }
}


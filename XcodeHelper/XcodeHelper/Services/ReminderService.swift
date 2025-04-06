//
//  ReminderService.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/4/5.
//

import Foundation
import EventKit
import Combine

final class ReminderService: ObservableObject {
    static let shared = ReminderService()
    
    private let eventStore = EKEventStore()
    private let calendarName = "Xcoder TODOs"
    private(set) var reminderCalendar: EKCalendar?

    @Published private(set) var isAuthorized: Bool = false {
        didSet {
            if isAuthorized {
                self.bindToTODOChanges(scanService: FileScannerService.shared, userSettings: UserSettings.shared)
            }
        }
    }
    private var subscriptions = Set<AnyCancellable>()

    private init() {
        // 初始化時同步授權狀態
        self.isAuthorized = EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
        self.reminderCalendar = getOrCreateReminderCalendar(named: calendarName)

        // 啟動時補檢查（用戶預設開啟 autoSync，但系統未授權）
        if UserSettings.shared.autoSyncToReminders, !isAuthorized {
            requestAccessIfNeeded()
        }
        
        reminderAuthorizationStatus()
    }

    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }

    /// 主動請求授權
    func requestAccessIfNeeded(completion: ((Bool) -> Void)? = nil) {
        eventStore.requestFullAccessToReminders { [weak self] granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Reminder 權限請求失敗: \(error.localizedDescription)")
                    completion?(false)
                    return
                }
                self?.isAuthorized = granted
                print(granted ? "✅ 已授權提醒事項" : "❌ 拒絕提醒事項權限")
                completion?(granted)
            }
        }
    }

    /// 確保存在可用提醒事項日曆（找不到就自建）
    private func getOrCreateReminderCalendar(named title: String) -> EKCalendar? {
        // 檢查是否已存在指定日曆
        if let existing = eventStore.calendars(for: .reminder).first(where: { $0.title == title }) {
            return existing
        }

        let newCalendar = EKCalendar(for: .reminder, eventStore: eventStore)
        newCalendar.title = title

        // 指定來源（優先 local）
        if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
            newCalendar.source = localSource
        } else if let anySource = eventStore.sources.first {
            newCalendar.source = anySource
        } else {
            print("❌ 沒有可用提醒事項來源，無法創建日曆")
            return nil
        }

        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            print("✅ 已成功創建提醒事項日曆：\(title)")
            return newCalendar
        } catch {
            print("❌ 創建提醒事項日曆失敗：\(error)")
            return nil
        }
    }

    /// 批量同步 TODO 項目到提醒事項（自帶去重）
    func sync(todos: [TodoItem]) {
        guard isAuthorized else {
            print("❌ 無提醒事項權限，無法同步 TODO")
            return
        }

        guard let calendar = reminderCalendar ?? getOrCreateReminderCalendar(named: calendarName) else {
            print("❌ 找不到提醒事項日曆，且創建失敗")
            return
        }

        let predicate = eventStore.predicateForReminders(in: [calendar])
        eventStore.fetchReminders(matching: predicate) { [weak self] reminders in
            guard let self = self else { return }
            let existingTitles = Set(reminders?.compactMap { $0.title } ?? [])

            let newItems = todos.filter { !existingTitles.contains($0.content) }
            print("🔍 TODO 去重後剩餘 \(newItems.count) 項待寫入")

            for todo in newItems {
                let reminder = EKReminder(eventStore: self.eventStore)
                reminder.title = todo.content
                reminder.calendar = calendar

                do {
                    try self.eventStore.save(reminder, commit: false)
                } catch {
                    print("❌ 寫入提醒失敗：\(todo.content)，錯誤：\(error)")
                }
            }

            do {
                try self.eventStore.commit()
                print("✅ 提醒事項寫入完成，共新增 \(newItems.count) 項")
            } catch {
                print("❌ 提醒事項提交失敗：\(error)")
            }
        }
    }

    /// 監聽掃描結果，自動同步提醒事項
    func bindToTODOChanges(scanService: FileScannerService, userSettings: UserSettings) {
        scanService.$todoItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard userSettings.autoSyncToReminders else { return }
                self?.sync(todos: items)
            }
            .store(in: &subscriptions)

        userSettings.$autoSyncToReminders
            .removeDuplicates()
            .filter { $0 == true }
            .sink { [weak self] _ in
                self?.sync(todos: scanService.todoItems)
            }
            .store(in: &subscriptions)

        if userSettings.autoSyncToReminders {
            sync(todos: scanService.todoItems)
        }
    }
    
    private func reminderAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .fullAccess, .writeOnly:
            break
        case .denied, .notDetermined, .restricted:
            if UserSettings.shared.autoSyncToReminders {
                    UserSettings.shared.autoSyncToReminders = false
                }
        @unknown default:
            break
        }
    }
}


//
//  ReminderService.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/4/5.
//

import Foundation
import EventKit
import Combine
import DevelopmentKit

class ReminderService: ObservableObject {
    
    static let shared = ReminderService()
    
    private let eventStore = EKEventStore()
    private let calendarName = "Xcoder TODOs"
    private(set) var reminderCalendar: EKCalendar?

    private var subscriptions = Set<AnyCancellable>()

    private init() {
        //初始化時非阻塞方式啟動提醒事項日曆建立 + 自動同步綁定
        self.createReminderAndBindTodo()
    }

    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }
    
}

//MARK: - 内部函数

extension ReminderService {
    ///创建和写入
    private func createReminderAndBindTodo() {
        getOrCreateReminderCalendarPublisher(named: calendarName)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    Log("创建提醒事项错误: \(error)")
                }
            } receiveValue: { reminder in
                self.bindToTODOChanges()
            }.store(in: &subscriptions)
    }

    /// 检查/创建提醒事項日曆
    private func getOrCreateReminderCalendarPublisher(named title: String) -> AnyPublisher<EKCalendar, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(ReminderError.calendarUnavailable))
                return
            }
            
            // 已存在則直接返回
            if let existing = self.eventStore.calendars(for: .reminder).first(where: { $0.title == title }) {
//                self.reminderCalendar = existing
                promise(.success(existing))
                return
            }
            
            let newCalendar = EKCalendar(for: .reminder, eventStore: self.eventStore)
            newCalendar.title = title
            
            // 選擇可用來源
            if let localSource = self.eventStore.sources.first(where: { $0.sourceType == .local }) {
                newCalendar.source = localSource
            } else if let anySource = self.eventStore.sources.first {
                newCalendar.source = anySource
            } else {
                print("❌ 沒有可用提醒事項來源，無法創建日曆")
                promise(.failure(ReminderError.calendarUnavailable))
                return
            }
            
            do {
                try self.eventStore.saveCalendar(newCalendar, commit: true)
                self.reminderCalendar = newCalendar
                print("✅ 已成功創建提醒事項日曆：\(title)")
                promise(.success(newCalendar))
            } catch {
                print("❌ 創建提醒事項日曆失敗：\(error)")
                promise(.failure(error))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }

    /// 批量同步 TODO 項目到提醒事項（自帶去重）
    private func sync(todos: [TodoItem]) {
        guard AuthorizationManager.shared.isReminderAuthorized else {
            print("❌ 無提醒事項權限，無法同步 TODO")
            return
        }

        guard let calendar = reminderCalendar else {
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
    
    ///复检reminder是否存在
    private func ensureReminderCalendarPublisher() -> AnyPublisher<EKCalendar, Error> {
        // 若已有且仍存在，直接返回
        if let current = reminderCalendar {
            let calendars = eventStore.calendars(for: .reminder)
            if calendars.contains(where: { $0.calendarIdentifier == current.calendarIdentifier }) {
                self.reminderCalendar = current
                return Just(current)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }
        // 否则重建
        return getOrCreateReminderCalendarPublisher(named: calendarName)
    }
}

//MARK: - 外部函数
extension ReminderService {
    /// 添加單條記錄到提醒事項
    func syncSingleItemPublisher(todo: TodoItem) -> AnyPublisher<Bool, Error> {
        return ensureReminderCalendarPublisher()
            .flatMap { calendar -> AnyPublisher<Bool, Error> in
                Future { promise in
                    let predicate = self.eventStore.predicateForReminders(in: [calendar])
                    self.eventStore.fetchReminders(matching: predicate) { reminders in
                        let existing = Set(reminders?.compactMap { $0.title } ?? [])
                        guard !existing.contains(todo.content) else {
                            print("⚠️ 已存在：\(todo.content)")
                            promise(.failure(ReminderError.duplicateItem))
                            return
                        }

                        let reminder = EKReminder(eventStore: self.eventStore)
                        reminder.title = todo.content
                        reminder.calendar = calendar

                        do {
                            try self.eventStore.save(reminder, commit: true)
                            print("✅ 單條寫入成功：\(todo.content)")
                            promise(.success(true))
                        } catch {
                            print("❌ 寫入失敗：\(error)")
                            promise(.failure(error))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    /// 監聽掃描結果，自動同步提醒事項
    func bindToTODOChanges() {
        let scanService = FileScannerService.shared
        let userSettings = UserSettings.shared

        // 🥊 1. 當 TODO 項發生變化，且 autoSync 為 true 時，自動寫入提醒事項
        scanService.$todoItems
            .receive(on: RunLoop.main)
            .filter { _ in userSettings.autoSyncToReminders } // 僅當開關為開啟時才繼續
            .flatMap { [weak self] items -> AnyPublisher<Void, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }

                // 檢查是否已有有效日曆（若無則創建）
                return self.ensureReminderCalendarPublisher()
                    .map { _ in items } // 將 items 傳入下一步
                    .handleEvents(receiveOutput: { self.sync(todos: $0) }) // 進行同步寫入
                    .map { _ in () } // 返回空值作為結尾
                    .catch { error -> AnyPublisher<Void, Never> in
                        Log("❌ 同步提醒事項失敗：\(error)")
                        return Empty().eraseToAnyPublisher() // 忽略錯誤，不中斷流程
                    }
                    .eraseToAnyPublisher()
            }
            .sink { _ in }
            .store(in: &subscriptions)

        // 🥊 2. 開關從關 -> 開 時，立即執行一次同步
        userSettings.$autoSyncToReminders
            .removeDuplicates()
            .filter { $0 == true } // 僅響應 true 的情況
            .flatMap { [weak self] _ -> AnyPublisher<Void, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }

                return self.ensureReminderCalendarPublisher()
//                    .handleEvents(receiveOutput: { calendar in
//                        self.reminderCalendar = calendar
//                    })
                    .map { _ in scanService.todoItems } // 拿到當前 TODO 項
                    .handleEvents(receiveOutput: { self.sync(todos: $0) }) // 寫入提醒事項
                    .map { _ in () }
                    .catch { error -> AnyPublisher<Void, Never> in
                        Log("❌ 初始同步失敗：\(error)")
                        return Empty().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { _ in }
            .store(in: &subscriptions)
    }
}

enum ReminderError: LocalizedError {
    case notAuthorized
    case calendarUnavailable
    case duplicateItem

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "未獲得提醒事項權限"
        case .calendarUnavailable:
            return "找不到有效的提醒事項日曆"
        case .duplicateItem:
            return "這條 TODO 已存在提醒事項中"
        }
    }
}

//
//  MenuViewModel.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import Foundation
import EventKit

class MenuViewModel: ObservableObject {
    
    @Published var isAuthorized = false
    
    let eventStore = EKEventStore()
    
    init () {
//        requestReminderAccess()
    }
    
    private func requestReminderAccess() {
        eventStore.requestFullAccessToReminders { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Reminder 权限请求失败: \(error.localizedDescription)")
                    return
                }
                
                self.isAuthorized = granted
                print(granted ? "✅ 已授权访问提醒事项" : "❌ 用户拒绝提醒事项权限")
            }
        }
    }
}

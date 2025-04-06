//
//  UserDefaults.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/27.
//

import Foundation
import CoreLocation
import Combine

extension UserDefaults {
    
    static var userDefaultsInstance: UserDefaults? {
        UserDefaults(suiteName: "xCodeHelper")
    }
}

extension UserDefaults {
    
    private enum Keys {
        static let storedBookmarks = "storedBookmarks"
        static let autoSyncToReminders = "autoSyncToReminders"
        static let scanFrequency = "scanFrequency"
        static let enableXcodeTracking = "enableXcodeTracking"
        static let lastManualScanDate = "lastManualScanDate"
    }

    /// 存储的本地路径
    var storedBookmarks: [SecurePath] {
        get {
            guard let data = data(forKey: Keys.storedBookmarks) else { return [] }
            return (try? JSONDecoder().decode([SecurePath].self, from: data)) ?? []
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            set(data, forKey: Keys.storedBookmarks)
        }
    }

    /// 是否自动同步 TODO 到提醒事项
    var autoSyncToReminders: Bool {
        get { self.bool(forKey: Keys.autoSyncToReminders) }
        set { self.set(newValue, forKey: Keys.autoSyncToReminders) }
    }

    /// 扫描频率（0 = 每次启动, 1 = 每 30 分钟, 2 = 每 1 小时, 3 = 每 2 小时）
    var scanFrequency: ScanFrequency {
        get { ScanFrequency(rawValue: self.integer(forKey: Keys.scanFrequency)) ?? .every30Minutes }
        set { self.set(newValue.rawValue, forKey: Keys.scanFrequency) }
    }

    /// 是否启用 Xcode 活动监听
    var enableXcodeTracking: Bool {
        get { self.bool(forKey: Keys.enableXcodeTracking) }
        set { self.set(newValue, forKey: Keys.enableXcodeTracking) }
    }

    /// 上次手动扫描时间（可选）
    var lastManualScanDate: Date? {
        get { self.object(forKey: Keys.lastManualScanDate) as? Date }
        set { self.set(newValue, forKey: Keys.lastManualScanDate) }
    }
}

enum ScanFrequency: Int, CaseIterable, Identifiable {
    case everyLaunch = 0
    case every30Minutes
    case everyHour
    case everyTwoHours

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .everyLaunch: return "每次启动"
        case .every30Minutes: return "每 30 分钟"
        case .everyHour: return "每 1 小时"
        case .everyTwoHours: return "每 2 小时"
        }
    }
    var interval: TimeInterval {
            switch self {
            case .everyLaunch: return 0
            case .every30Minutes: return 1800
            case .everyHour: return 3600
            case .everyTwoHours: return 7200
            }
        }
}

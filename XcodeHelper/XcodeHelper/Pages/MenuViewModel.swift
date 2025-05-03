//
//  MenuViewModel.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import Foundation
import EventKit
import Combine
import AppKit
import DevelopmentKit
import CoreLocationKit

class MenuViewModel: ObservableObject {
    ///是否获得授权
    @Published var isAuthorized = false
    ///Wi-Fi信号强度等级
    @Published var wifiSignalLevel: WiFiSignalLevel = .fair
    ///Wi-Fi上行速度
    @Published var wifiUp: String = ""
    ///Wi-Fi下行速度
    @Published var wifiDown: String = ""
    ///系统CPU信息
    @Published var cpuInfo: MacCPUInfo?
    ///系统内存信息
    @Published var memInfo: MacMemoryInfo?
    ///系统存储空间信息
    @Published var availableDiskSpace: Int = 0
    
    private let eventStore = EKEventStore()
    
    private var subscriptions = Set<AnyCancellable>()
    
    init () {
        self.getSystemInfo()
        CoreLocationKit.shared.requestCurrentLocation()
    }
    
    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }
    
}

//MARK: - 外部方法
extension MenuViewModel {
    ///同步单条todo到提醒事项
    func syncSingleItem(item: TodoItem) {
        ReminderService.shared.syncSingleItemPublisher(todo: item)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    Log("错误: \(error)")
                }
            } receiveValue: { _ in
                
            }.store(in: &subscriptions)
    }
    
    ///打开项目
    func openProject(at projectPath: String) {
        guard let secure = UserSettings.shared.storedPaths.first(where: { projectPath.hasPrefix($0.path) }) else {
            print("❌ 找不到對應的 SecurePath")
            return
        }
        
        do {
            var isStale = false
            let securedURL = try URL(
                resolvingBookmarkData: secure.bookmarkData,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            guard securedURL.startAccessingSecurityScopedResource() else {
                print("❌ 無法訪問 SecurePath")
                return
            }
            
            defer { securedURL.stopAccessingSecurityScopedResource() }
            
            let fileURL = URL(fileURLWithPath: projectPath)
            NSWorkspace.shared.open(fileURL)
            
        } catch {
            print("❌ 無法解析 SecurePath：\(error)")
        }
    }
    
    ///打开设置界面
    func openSettings() {
        SettingsWindowManager.shared.showSettingsWindow {
            SettingsView()
                .environmentObject(FileScannerService.shared)
                .environmentObject(UserSettings.shared)
        }
    }
}
//MARK: - 内部方法
extension MenuViewModel {
    ///获取系统信息
    private func getSystemInfo() {
        DevelopmentKit.Network.getWiFiSignalLevelPublisher()
            .sink { WiFiSignalLevel in
                self.wifiSignalLevel = WiFiSignalLevel
            }.store(in: &subscriptions)
        DevelopmentKit.Network.getSystemNetworkThroughputPublisher(interval: 1)
            .sink { value in
                self.wifiDown = self.formatNetworkSpeed(value.receivedBytesPerSec)
                self.wifiUp = self.formatNetworkSpeed(value.sentBytesPerSec)
            }.store(in: &subscriptions)

        DevelopmentKit.SysInfo.getCPUInfoPublisher(interval: 1)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    Log("错误: \(error)")
                }
            } receiveValue: { MacCPUInfo in
                self.cpuInfo = MacCPUInfo
            }.store(in: &subscriptions)
        DevelopmentKit.SysInfo.getMemoryInfoPublisher()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    Log(error)
                }
            } receiveValue: { MacMemoryInfo in
                self.memInfo = MacMemoryInfo
            }.store(in: &subscriptions)
        DevelopmentKit.SysInfo.getAvailableDiskSpacePublisher()
            .sink { availableDisk in
                self.availableDiskSpace = availableDisk
            }.store(in: &subscriptions)

    }
    ///网速格式化函数
    private func formatNetworkSpeed(_ bytePerSecond: UInt64) -> String {
        let doubleValue = Double(bytePerSecond)

        if doubleValue >= 1_048_576 {
            let mbps = doubleValue / 1_048_576
            return String(format: "%.2f MB/s", mbps)
        } else if doubleValue >= 1024 {
            let kbps = doubleValue / 1024
            return String(format: "%.0f KB/s", kbps)
        } else {
            return "\(bytePerSecond) B/s"
        }
    }
}

//
//  MenuViewModel.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import Foundation
import EventKit
import Combine
import DevelopmentKit

class MenuViewModel: ObservableObject {
    
    @Published var isAuthorized = false
    
    @Published var wifiSignalLevel: WiFiSignalLevel = .fair
    
    @Published var cpuInfo: MacCPUInfo?
    @Published var memInfo: MacMemoryInfo?
    
    private let eventStore = EKEventStore()
    
    private var subscriptions = Set<AnyCancellable>()
    
    init () {
        self.getSystemInfo()
    }
    
    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }
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
    
    private func getSystemInfo() {
        DevelopmentKit.Network.getWiFiSignalLevelPublisher()
//            .receive(on: RunLoop.main)
            .sink { WiFiSignalLevel in
                self.wifiSignalLevel = WiFiSignalLevel
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


    }
    
}

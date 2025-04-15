//
//  ScanSchedulerService.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/4/5.
//

import Foundation
import Combine

final class ScanSchedulerService {
    
    static let shared = ScanSchedulerService()
    
    private var timer: Timer?
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        observeFrequencyChange()
    }
    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }
    /// 开始定时任务
    func start() {
        restartTimer(with: UserSettings.shared.scanFrequency)
    }
    
    /// 停止定时任务
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 监听用户设置频率的变化，自动重启 timer
    private func observeFrequencyChange() {
        UserSettings.shared.$scanFrequency
            .sink { [weak self] newFrequency in
                self?.restartTimer(with: newFrequency)
            }
            .store(in: &subscriptions)
    }
    
    /// 启动或重启计时器
    private func restartTimer(with frequency: ScanFrequency) {
        stop()
        
        // 每次启动时立即执行一次
        triggerScan()
        
        guard frequency != .everyLaunch else {
            print("⏱ Scan frequency is 'everyLaunch'，不啟用定時掃描")
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: frequency.interval, repeats: true) { _ in
            self.triggerScan()
        }
        
        print("定時掃描啟用，\(frequency.displayName) 一次")
    }
    
    /// 实际扫描逻辑
    private func triggerScan() {
        let paths = UserSettings.shared.storedPaths
        let items = FileScannerService.shared.scanAllPathsForTODOs(from: paths)
        DispatchQueue.main.async {
            FileScannerService.shared.todoItems = items
            print("完成一次扫描")
        }
    }
}

//
//  AppDelegate.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import Foundation
import SwiftUI
import AppKit
import CoreLocation

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        
        // 设置菜单栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "hammer", accessibilityDescription: "Xcoder Helper")
            button.action = #selector(togglePopover(_:))
        }

        // 设置 popover 内容、
        let scanService = FileScannerService.shared
        let userSettings = UserSettings.shared
        let authorizationManager = AuthorizationManager.shared
//        let locationManager = LocationManager.shared
        let menuView = MenuView()
            .preferredColorScheme(.dark)
            .environmentObject(scanService)
            .environmentObject(userSettings)
            .environmentObject(authorizationManager)
//            .environmentObject(locationManager)
        let hostingController = NSHostingController(rootView: menuView)
        
        // 设置透明背景
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        hostingController.view.layer?.cornerRadius = 12
        hostingController.view.layer?.masksToBounds = true

        popover.contentViewController = hostingController
        popover.contentSize = NSSize(width: 350, height: 600)
        popover.behavior = .transient
        
        //定时扫描任务
        ScanSchedulerService.shared.start()
        //自动添加到提醒事项任务
//        reminderService.bindToTODOChanges(scanService: scanService, userSettings: userSettings)
//        let locationPermissionManager = LocationPermissionManager()
//        locationPermissionManager.requestAccessIfNeeded()
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                //点击任何地方关闭popover
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}

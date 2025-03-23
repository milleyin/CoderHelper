//
//  AppDelegate.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import Foundation
import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置菜单栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "hammer.fill", accessibilityDescription: "Xcoder Helper")
            button.action = #selector(togglePopover(_:))
        }

        // 设置 popover 内容（SwiftUI）
        let menuView = MenuView()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.contentViewController = NSHostingController(rootView: menuView)
        popover.behavior = .transient
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}

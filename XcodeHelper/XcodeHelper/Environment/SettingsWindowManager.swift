//
//  SettingsWindowManager.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/27.
//

import AppKit
import SwiftUI

class SettingsWindowManager {
    static let shared = SettingsWindowManager()

    var window: NSWindow?

    func showSettingsWindow<Content: View>(@ViewBuilder content: () -> Content) {
        if window == nil {
            let hostingController = NSHostingController(rootView: content())
            window = NSWindow(
                contentViewController: hostingController
            )
            window?.setContentSize(NSSize(width: 400, height: 300))
            window?.styleMask = [.titled, .closable]
            window?.title = "设置"
            window?.isReleasedWhenClosed = false
            window?.level = .floating
        }

        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

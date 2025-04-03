//
//  XcodeHelperApp.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import SwiftUI
import AppKit

@main
struct XcodeHelperApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        
    }
    @StateObject var scanService: FileScannerService = .shared
    var body: some Scene {
        MenuBarExtra("Xcoder Helper", systemImage: "hammer") {
            Color.clear.opacity(0)
            MenuView()
                .environmentObject(scanService)
        }
//        .defaultSize(CGSize(width: 300, height: 400))
        .menuBarExtraStyle(.window)
//        Settings {
//                    EmptyView()
//                }
        
    }
}




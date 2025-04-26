//
//  MenuView.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import SwiftUI
import EventKit
import DevelopmentKit

struct MenuView: View {
    
    @EnvironmentObject var scanService: FileScannerService
    @EnvironmentObject var userSettings: UserSettings
    
    @StateObject var viewModel: MenuViewModel = .init()
    
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: 6) {
                    HStack {
                        if let cpuInfo = viewModel.cpuInfo {
                            SysInfoData(icon: "cpu", value: "\(cpuInfo.totalUsage.formatted(.number.precision(.fractionLength(1)))) %")
                        }else {
                            SysInfoData(icon: "cpu", value: "-- %")
                        }
                        if let memInfo = viewModel.memInfo {
                            SysInfoData(icon: "memorychip", value: "\(memInfo.used.formatted(.number.precision(.fractionLength(1)))) %")
                        }else {
                            SysInfoData(icon: "cpu", value: "-- %")
                        }
                        SysInfoData(icon: "internaldrive", value: "\(viewModel.availableDiskSpace) GB")
                        
                    }
                    HStack {
                        SysInfoData(icon: "", value: viewModel.wifiSignalLevel.rawValue)
                        SysInfoData(icon: "arrow.up.right", value: viewModel.wifiUp)
                        SysInfoData(icon: "arrow.down.left", value: viewModel.wifiDown)
                    }
                }.padding(2)
                VStack {
                    Text("任务清单").font(.largeTitle.bold())
                }//.foregroundStyle(.white)
                if userSettings.storedPaths.isEmpty {
                    Button {
                        openSettings()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.clear.opacity(0.1))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                }
                            VStack {
                                Text("+")
                                Text("點擊打開設置界面")
                            }
                        }
                    }
                    .padding()
                    .buttonStyle(.borderless)

                }else {
                    TodoContentView(viewModel: viewModel)
                }
                Spacer()
                Divider().padding(.vertical, 5)
                HStack {
                    Button {
                        openSettings()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2)
                    }.buttonStyle(.borderless)
                    Spacer()
                    Button {
                        NSApp.terminate(nil)
                    } label: {
                        Image(systemName: "arrow.forward.square")
                            .font(.title2)
                    }.buttonStyle(.borderless)

                }
            }
            .padding()
        }
    }
    
    private func openSettings() {
        SettingsWindowManager.shared.showSettingsWindow {
            SettingsView()
                .environmentObject(scanService)
                .environmentObject(userSettings)
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(FileScannerService.shared)
        .environmentObject(UserSettings.shared)
        .frame(width: 350, height: 600)
}


fileprivate struct TodoContentView: View {
    
    @ObservedObject var viewModel: MenuViewModel
    
    @EnvironmentObject var scanService: FileScannerService
    @EnvironmentObject var authorizationManager: AuthorizationManager
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(self.scanService.todoItems, id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .bottom, spacing: 1) {
                                Image(systemName: "list.bullet.clipboard")
                                Text(item.projectName).bold()
                            }
//                            .padding(.vertical, 4)
//                            .padding(.horizontal, 10)
//                            .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 4))
                            HStack(spacing: 0) {
                                Text(item.fileName)
                                Text(" :\(item.lineNumber)")
                            }
                            Text(item.content)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        VStack {
                            Button {
                                viewModel.openProject(at: item.projectPath)
                                
                            }label: {
                                HStack {
                                    Image(systemName: "command")
                                        .font(.system(size: 16))
                                        .padding(4)
                                        .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 4))
                                }
                            }
                            .buttonStyle(.borderless)
                            .help("點擊使用 Xcode 開啟專案")
                            Button {
                                if !authorizationManager.isReminderAuthorized {
                                    authorizationManager.requestReminderAccess()
                                }else {
                                    viewModel.syncSingleItem(item: item)
                                }
                            }label: {
                                Image(systemName: "checklist")
                                    .font(.system(size: 15))
                                    .padding(4)
                                    .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 4))
                            }
                            .buttonStyle(.borderless)
                            .help("添加到提醒事项")
                        }
                        
                        

                    }
                    .padding()
                    .background(Color.gray.opacity(0.07), in: .rect(cornerRadius: 10))
                }
            }
        }
    }
    
}




struct SysInfoData: View {
    
    var icon: String
    var value: String
    
    var body: some View {
        HStack(spacing: 1) {
            Image(systemName: icon)
                .font(.system(size: 12))
//                .foregroundStyle(.white)
            Text(value)
                .font(.system(size: 12))
//                .foregroundStyle(.white)
        }
    }
}

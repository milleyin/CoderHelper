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
//            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, state: .active, cornerRadius: 12)
//            .edgesIgnoringSafeArea(.all)
//            .opacity(0.5)
//            RoundedRectangle(cornerRadius: 12)
//                .foregroundStyle(.gray.opacity(0.2))
                
            VStack {
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
                    SysInfoData(icon: "network", value: viewModel.wifiSignalLevel.rawValue)
                }.padding()
                VStack {
                    Text("任务清单").font(.largeTitle.bold())
                        
                    Text(userSettings.storedPaths.isEmpty ? "你先去設置裡加個項目路徑唄，\n不然我咋幫你弄 TODO 啊？" : "🐂牛馬，下面是你還沒做完的事")
                        .multilineTextAlignment(.center)
                        .font(.body)
                }.foregroundStyle(.white)
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
                                        .foregroundStyle(.gray.opacity(0.5))
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
                            .foregroundStyle(.white)
                    }.buttonStyle(.borderless)
                    Spacer()
                    Button {
                        NSApp.terminate(nil)
                    } label: {
                        Image(systemName: "arrow.forward.square")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }.buttonStyle(.borderless)

                }
            }
            .padding()
        }
        .padding()
//        .background(
//            LinearGradient(
//                gradient: Gradient(stops: [
//                    .init(color: .init(hex: "1E003D"), location: 0.0),    // 深紫（上左）
//                    .init(color: .init(hex: "3C1874"), location: 0.4),    // 蓝紫（中部偏上）
//                    .init(color: .init(hex: "2B1D52"), location: 0.7),    // 暗蓝（底部过渡）
//                    .init(color: .init(hex: "14002D"), location: 1.0)     // 接近黑的深紫
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//        )
    }
    
    private func openSettings() {
        SettingsWindowManager.shared.showSettingsWindow {
            SettingsView()
                .environmentObject(scanService)
                .environmentObject(userSettings)
//                .environmentObject(reminderService)
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
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 0) {
                                Text(item.fileName)
                                    
                                Text(":\(item.lineNumber)")
                            }.foregroundStyle(Color.white)
                            Text(item.content).foregroundStyle(Color.white)
                        }
                        
                        Spacer()
                        Button {
                            if !authorizationManager.isReminderAuthorized {
                                authorizationManager.requestReminderAccess()
                            }else {
                                viewModel.syncSingleItem(item: item)
                            }
                        }label: {
                            Image(systemName: "checklist").foregroundStyle(Color.white)
                        }
                        .buttonStyle(.borderless)
                        .help("添加到提醒事项")
                        

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

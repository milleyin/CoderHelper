//
//  MenuView.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import SwiftUI
import EventKit
import DevelopmentKit
import CoreLocationKit

struct MenuView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    @StateObject var viewModel: MenuViewModel = .init()
    
    var body: some View {
        ZStack {
            VStack {
                Header(viewModel: viewModel)
                Divider()
                
                if userSettings.storedPaths.isEmpty {
                    Button {
                        viewModel.openSettings()
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
                    HStack {
                        Text("📝任务清单").font(.title)
                        Spacer()
                    }
                    TodoContentView(viewModel: viewModel)
                }
                Spacer()
                Divider().padding(.vertical, 5)
                Footer(viewModel: viewModel)
            }
            .padding()
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
                            HStack(alignment: .bottom, spacing: 4) {
                                Image("xcodeprojIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                Text(item.projectName).bold()
                            }
                            HStack(alignment: .bottom, spacing: 4) {
                                Image(systemName: "swift").foregroundStyle(Color.orange)
                                Text(item.fileName)
                                Text(" :\(item.lineNumber)")
                            }
                            HStack(alignment: .top, spacing: 4) {
                                Image(systemName: "list.bullet.clipboard")
                                Text(item.content)
                                    .multilineTextAlignment(.leading)
                            }
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

fileprivate struct SysInfoData: View {
    
    var icon: String
    var value: String
    
    var body: some View {
        HStack(spacing: 1) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(value)
                .font(.system(size: 12))
        }
    }
}

fileprivate struct Header: View {
    
    @ObservedObject var viewModel: MenuViewModel
    @StateObject private var weatherManager = WeatherManager()
    
    var body: some View {
        HStack(spacing: 0){
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black.opacity(0.05))
                    .frame(width: 74, height: 74)
                if let weather = weatherManager.currentWeather {
                    VStack {
                        Image(systemName: weather.symbolName.description)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36)
                            .foregroundStyle(Color.white, Color.orange)
                        Text(weather.condition.localizedDescription)
                    }
                    .padding()
                }else {
                    Image(systemName: "mappin.slash.circle")
                        .font(.system(size: 28))
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
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
                    SysInfoData(icon: "network", value: viewModel.wifiSignalLevel.rawValue)
                    SysInfoData(icon: "arrow.up.right", value: viewModel.wifiUp)
                    SysInfoData(icon: "arrow.down.left", value: viewModel.wifiDown)
                }
                if let _ = weatherManager.currentWeather {
                    Text("☁️今日气象，适合编码")
                }else {
                    HStack(spacing: 4) {
                        Image(systemName: "icloud.slash")
                        Text("獲取定位失敗，暫無天氣數據")
                    }
                }
            }
            .padding()
            Spacer()
        }
    }
}

fileprivate struct Footer: View {
    
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        HStack {
            Button {
                viewModel.openSettings()
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
    
}

//
//  SettingsView.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/27.
//

import SwiftUI
import DevelopmentKit


struct SettingsView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    @StateObject var viewModel: SettingsViewModel = .init()
    
    var body: some View {
        HStack {
            Settings(viewModel: viewModel)
            Divider().padding(.horizontal)
            Text("Hello, World!")
        }
        .padding()
        .fixedSize(horizontal: true, vertical: true)
        .alert("需要授權", isPresented: $userSettings.isShowEnableRemindersAuthorizationAlert) {
            Button {
                userSettings.isShowEnableRemindersAuthorizationAlert = false
            } label: {
                Text("好的")
            }

        } message: {
            Text("請前往系統設置開啟提醒事項權限")
        }
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
}

#Preview {
    SettingsView()
        .environmentObject(FileScannerService.shared)
        .environmentObject(UserSettings.shared)
}

fileprivate struct Settings: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            
            ScanPathView(viewModel: viewModel)
            Divider()
            AutoSyncView(viewModel: viewModel)
            Divider()
            ScanSettingView(viewModel: viewModel)
            Divider()
            OtherSettingView()
        }
    }
}
///扫描路径设置
fileprivate struct ScanPathView: View {
    
    @EnvironmentObject var scanService: FileScannerService
    @EnvironmentObject var userSettings: UserSettings
    
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "folder.fill")
                    .font(.system(.largeTitle))
                    .foregroundStyle(.orange)
                Text("掃描路徑")
                    .font(.system(.largeTitle))
                Spacer()
            }.foregroundStyle(Color.white)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.init(hex: "#091D31"))
                    .opacity(0.2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    }
                    .frame(width: 500)
                    .frame(minHeight: 100)
                if userSettings.storedPaths.isEmpty {
                    
                    VStack {
                        Text("尚未添加任何路徑").opacity(0.5)
                        Button {
                            viewModel.addPath()
                        } label: {
                            Text("点击添加")
                                .padding(.vertical, 3)
                                .padding(.horizontal, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [4]))
                                }
                        }.buttonStyle(.borderless)

                    }
                    
                }else {
                    ScrollView(showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(userSettings.storedPaths, id: \.id) { path in
                                HStack {
                                    
                                    Text(path.path)
                                        .foregroundStyle(Color.white)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Spacer()
                                    Button {
                                        viewModel.removePath(path.path)
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundStyle(Color.white)
                                    }
                                    .buttonStyle(.plain)
                                    Button {
                                        viewModel.addPath()
                                    } label: {
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundStyle(Color.white)
                                    }.buttonStyle(.plain)

                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxHeight: 160)
//                    .frame(height: 160)
                    
                }
            }
//            HStack {
//                Spacer()
//                Button {
//                    viewModel.addPath()
//                } label: {
//                    Image(systemName: "folder.badge.plus")
//                    Text("添加路徑")
//                }.buttonStyle(.borderedProminent)
//                
//            }
        }
    }
}
///自動同步设置
fileprivate struct AutoSyncView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "arrow.down.left.arrow.up.right.circle")
                    .font(.system(.largeTitle))
                    .foregroundStyle(.yellow)
                Text("自動同步").font(.largeTitle).foregroundStyle(.white)
                Spacer()
            }
            //同步到提醒事项
            Toggle(isOn: $userSettings.autoSyncToReminders) {
                HStack {
                    Text("自動同步TODO到Apple提醒事項").foregroundStyle(.white)
                    Spacer()
                }
            }.toggleStyle(.switch)
        }
    }
}

///扫描频率设置
fileprivate struct ScanSettingView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "calendar.day.timeline.left")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                Text("掃描頻率")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                Spacer()
            }
            Picker("", selection: $userSettings.scanFrequency) {
                ForEach(ScanFrequency.allCases) { frequency in
                    Text(frequency.displayName)
                        .tag(frequency)
                        .tint(.white)
                }
            }
            
            .pickerStyle(.segmented)
            
            
        }
    }
}

///其他功能设置
fileprivate struct OtherSettingView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "ellipsis.curlybraces")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                Text("其他设置")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                Spacer()
            }
            HStack {
                LaunchAtLogin.Toggle(){
                    HStack {
                        Text("开机自动启动")
                            .foregroundStyle(.white)
                        Spacer()
                    }.padding(.leading, 10)
                }.toggleStyle(.switch)
            }
            HStack {
                Toggle(isOn: $userSettings.enableXcodeTracking) {
                    HStack {
                        Text("Xcode 项目退出后自动扫描（开发中...）")
                            .foregroundStyle(.white)
                        Spacer()
                    }.padding(.leading, 10)
                }.toggleStyle(.switch)
                
            }
        }
    }
}

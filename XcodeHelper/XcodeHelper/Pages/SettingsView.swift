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
                    .font(.system(.headline))
                Text("掃描路徑")
                    .font(.system(.headline))
                Spacer()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .opacity(0.05)
                    .overlay {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.gray)
                    }
                    .frame(width: 300, height: 100)
                if userSettings.storedPaths.isEmpty {
                    Text("尚未添加任何路徑").opacity(0.5)
                }else {
                    ScrollView(showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(userSettings.storedPaths, id: \.id) { path in
                                HStack {
                                    Button {
                                        viewModel.removePath(path.path)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.plain)
                                    Text(path.path)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(height: 100)
                    
                }
            }
            HStack {
                Spacer()
                Button {
                    viewModel.addPath()
                } label: {
                    Image(systemName: "folder.badge.plus")
                    Text("添加路徑")
                }.buttonStyle(.borderedProminent)
                
            }
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
                    .font(.system(.headline))
                Text("自動同步").font(.headline)
                Spacer()
            }
            //同步到提醒事项
            Toggle(isOn: $userSettings.autoSyncToReminders) {
                HStack {
                    Text("自動同步TODO到Apple提醒事項")
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
                Text("掃描頻率").font(.headline)
                Spacer()
            }
            Picker("", selection: $userSettings.scanFrequency) {
                ForEach(ScanFrequency.allCases) { frequency in
                    Text(frequency.displayName).tag(frequency)
                }
            }.pickerStyle(.segmented)
            
            HStack {
                Toggle(isOn: $userSettings.enableXcodeTracking) {
                    HStack {
                        Text("Xcode 项目退出后自动扫描")
                        Spacer()
                    }.padding(.leading, 10)
                }.toggleStyle(.switch)
                
            }
        }
    }
}

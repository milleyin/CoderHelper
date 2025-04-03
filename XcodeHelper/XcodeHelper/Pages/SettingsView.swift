//
//  SettingsView.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/27.
//

import SwiftUI
import DevelopmentKit

struct SettingsView: View {
    
    @StateObject var viewModel: SettingsViewModel = .init()
    
    var body: some View {
        HStack {
            Settings(viewModel: viewModel)
            Divider().padding(.horizontal)
            Text("Hello, World!")
        }
        .padding()
        .fixedSize(horizontal: true, vertical: true)
    }
}

#Preview {
    SettingsView()
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
                if scanService.storedPaths.isEmpty {
                    Text("尚未添加任何路徑").opacity(0.5)
                }else {
                    ScrollView(showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(scanService.storedPaths, id: \.id) { path in
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
        .onAppear {
//            if DevelopmentKit.isPreview {
//                viewModel.storedPaths = ["123", "234", "234", "234", "234", "234", "234"]
//            }
        }
    }
}
///自動同步设置
fileprivate struct AutoSyncView: View {
    
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
            Toggle(isOn: $viewModel.autoSyncToReminders) {
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
    
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("掃描頻率").font(.headline)
                Spacer()
            }
            Picker("", selection: $viewModel.scanFrequency) {
                ForEach(ScanFrequency.allCases) { frequency in
                    Text(frequency.displayName).tag(frequency)
                }
            }.pickerStyle(.segmented)
            
            HStack {
                Toggle(isOn: $viewModel.enableXcodeTracking) {
                    HStack {
                        Text("Xcode 项目退出后自动扫描")
                        Spacer()
                    }.padding(.leading, 10)
                }.toggleStyle(.switch)
                
            }
        }
    }
}

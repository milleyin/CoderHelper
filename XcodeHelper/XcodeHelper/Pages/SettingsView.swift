//
//  SettingsView.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/27.
//

import SwiftUI

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
            //扫描路径
            VStack {
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.system(.headline))
                    Text("掃描路徑")
                        .font(.system(.headline))
                    Spacer()
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .opacity(0.05)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray)
                        }
                        .frame(width: 300, height: 50)
                    Text("尚未添加任何路徑").opacity(0.5)
                }
                HStack {
                    Spacer()
                    Button {
                        print("!23")
                    } label: {
                        Image(systemName: "folder.badge.plus")
                        Text("添加路徑")
                    }.buttonStyle(.borderedProminent)
                    
                }
            }
            //同步到提醒事项
            VStack {
                Toggle(isOn: $viewModel.autoSyncToReminders) {
                    HStack {
                        Text("自動同步TODO到Apple提醒事項")
                            .font(.headline)
                        Spacer()
                    }
                }.toggleStyle(.switch)
            }
        }
    }
}

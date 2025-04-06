//
//  MenuView.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import SwiftUI

struct MenuView: View {
    
    @EnvironmentObject var scanService: FileScannerService
    @EnvironmentObject var userSettings: UserSettings
//    @EnvironmentObject var reminderService: ReminderService
    
    @StateObject var viewModel: MenuViewModel = .init()
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, state: .active, cornerRadius: 12)
            .edgesIgnoringSafeArea(.all)
            .opacity(0.5)
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .bottom, spacing: 0) {
                            Text("🐂")
                                .font(.largeTitle)
                                .bold()
                            Text("牛馬，你好")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.primary)
                        }
                        Text(userSettings.storedPaths.isEmpty ? "你先去設置裡加個項目路徑唄，\n不然我咋幫你弄 TODO 啊？" : "下面是你還沒做完的事：")
                            .font(.headline)
                            .bold()
                    }
                    Spacer()
                    
                }
                if userSettings.storedPaths.isEmpty {
                    Button {
                        openSettings()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 50)
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
                    TodoContentView()
                }
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        openSettings()
                    } label: {
                        Image(systemName: "gearshape")
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
//                .environmentObject(reminderService)
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(FileScannerService.shared)
        .environmentObject(UserSettings.shared)
        .frame(width: 350, height: 400)
}


fileprivate struct TodoContentView: View {
    
    @EnvironmentObject var scanService: FileScannerService
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(self.scanService.todoItems, id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 0) {
                                Text(item.fileName)
                                Text(":\(item.lineNumber)")
                            }
                            Text(item.content)
                        }
                        
                        Spacer()
                        Text("1")
                    }.padding()
                        .background(Color.gray.opacity(0.07), in: .rect(cornerRadius: 10))
                }
            }
        }
    }
}




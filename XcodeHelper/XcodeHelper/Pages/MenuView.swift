//
//  MenuView.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import SwiftUI

struct MenuView: View {
    
    @EnvironmentObject var scanService: FileScannerService
    
    @StateObject var viewModel: MenuViewModel = .init()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("🐂牛馬，你好")
                            .font(.title)
                            .bold()
                        Text("下面是你還沒做完的事：")
                            .font(.title)
                            .bold()
                    }
                    Spacer()
                }
                ForEach(self.scanService.todoItems, id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.fileName)
                            Text("Line:\(item.lineNumber)")
                            Text(item.content)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1), in: .rect(cornerRadius: 10))
                        Spacer()
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        SettingsWindowManager.shared.showSettingsWindow {
                            SettingsView()
                        }
                    } label: {
                        Image(systemName: "gearshape")
                    }.buttonStyle(.borderless)
                    
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        
    }
}

#Preview {
    MenuView()
        .environmentObject(FileScannerService.shared)
}

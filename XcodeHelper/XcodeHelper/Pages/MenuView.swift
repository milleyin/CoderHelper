//
//  MenuView.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/23.
//

import SwiftUI

struct MenuView: View {
    
    @StateObject var viewModel: MenuViewModel = .init()
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🛠 Xcoder Helper")
                .font(.title)
                .bold()
            Text("未来这里会显示 TODO 列表")
                .foregroundColor(.secondary)
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

#Preview {
    MenuView()
}

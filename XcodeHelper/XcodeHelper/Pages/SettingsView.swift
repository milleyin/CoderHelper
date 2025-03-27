//
//  SettingsView.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/3/27.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        HStack {
            Settings()
            Divider().padding(.horizontal)
            Text("Hello, World!")
        }.padding()
    }
}

#Preview {
    SettingsView()
}

fileprivate struct Settings: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "folder.fill")
                    .font(.system(.title2))
                Text("掃描路徑")
                    .font(.system(.title2))
                Spacer()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .opacity(0.05)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray)
                    }
                    .frame(maxHeight: 50)
                Text("尚未添加任何路徑").opacity(0.5)
            }
            HStack {
                Spacer()
                Button {
                    print("!23")
                } label: {
                    Image(systemName: "folder.badge.plus")
                    Text("添加路徑")
                }.buttonStyle(.borderless)
                
            }
        }
    }
}

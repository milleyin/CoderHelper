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
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("🐂")
                        .font(.largeTitle)
                        .bold()
                    Text("牛馬，你好")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.primary)
                    Text("下面是你還沒做完的事：")
                        .font(.headline)
                        .bold()
                }
                Spacer()
                Button {
                    SettingsWindowManager.shared.showSettingsWindow {
                        SettingsView()
                    }
                } label: {
                    Image(systemName: "gearshape")
                }.buttonStyle(.borderless)
            }
            ScrollView {
                VStack {
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
                }
//                .padding()
    //            .background(Color.white)
    //            .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Spacer()
        }
        .padding()
        .background(Color.clear)
    }
}

#Preview {
    MenuView()
        .environmentObject(FileScannerService.shared)
}

fileprivate struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let state: NSVisualEffectView.State

    init(material: NSVisualEffectView.Material = .underWindowBackground,
         blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
         state: NSVisualEffectView.State = .active) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

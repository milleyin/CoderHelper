//
//  TodoItem.swift
//  XcodeHelper
//
//  Created by 米粒 on 2025/4/3.
//

import Foundation

struct TodoItem: Identifiable {
    let id = UUID()
    let filePath: String
    let fileName: String
    let projectName: String
    let projectPath: String
    let lineNumber: Int
    let content: String
}

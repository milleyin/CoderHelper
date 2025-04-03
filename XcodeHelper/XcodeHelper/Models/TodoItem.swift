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
    let lineNumber: Int
    let content: String
}

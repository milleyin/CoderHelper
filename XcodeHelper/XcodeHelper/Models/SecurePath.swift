//
//  SecurePath.swift
//  XcodeHelper
//
//  Created by 米粒 on 2025/4/3.
//

import Foundation

struct SecurePath: Codable, Identifiable, Equatable {
    var id: UUID = .init()
    let path: String
    let bookmarkData: Data
}

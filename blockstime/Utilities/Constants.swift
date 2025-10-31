//
//  Constants.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import Foundation

enum Constants {
    static let totalHours: Double = 168.0 // 一週總時數
    static let blockHours: Double = 1.0 // 每個積木代表 1 小時
    static let storageKey = "legoTimePlannerCategories"
    static let appGroupId = "group.alex.blockstime"

    // UI Constants
    static let blockSize: CGFloat = 60
    static let blockGap: CGFloat = 6
    static let blockCornerRadius: CGFloat = 6
    static let categoryItemPadding: CGFloat = 12
    static let sidebarWidth: CGFloat = 300
}

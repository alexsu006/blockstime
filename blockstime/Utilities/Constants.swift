//
//  Constants.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import Foundation

enum Constants {
    // Time Constants
    static let totalHours: Double = 168.0 // 一週總時數
    static let blockHours: Double = 1.0 // 每個積木代表 1 小時

    // Storage Constants
    static let storageKey = "legoTimePlannerCategories"
    static let appGroupId = "group.alex.blockstime"

    // UI Constants
    static let blockSize: CGFloat = 60
    static let blockGap: CGFloat = 6
    static let blockCornerRadius: CGFloat = 6
    static let categoryItemPadding: CGFloat = 12
    static let sidebarWidth: CGFloat = 300

    // Layout Constants
    static let minBlockSize: CGFloat = 20
    static let maxBlockSize: CGFloat = 80
    static let minLayoutColumns: Int = 3
    static let maxLayoutColumns: Int = 10
    static let defaultLayoutColumns: Int = 4

    // Precision Constants
    static let hoursPrecision: Double = 10.0 // 用於四捨五入到小數點後一位
    static let sliderSyncThreshold: Double = 0.01 // Slider 同步閾值

    // Animation Constants
    static let defaultAnimationDuration: Double = 0.3
}

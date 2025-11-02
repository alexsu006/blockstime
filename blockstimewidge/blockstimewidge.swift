//
//  blockstimewidge.swift
//  blockstimewidge
//
//  Created by Alex Su on 2025/10/31.
//

import WidgetKit
import SwiftUI

// MARK: - Shared Models
// Note: These models mirror the main app's Category and LegoColor for data compatibility
struct Category: Codable {
    let id: String
    let name: String
    let hours: Double
    let colorId: String

    var blocksCount: Int {
        Int(ceil(hours / 1.0)) // 1 block = 1 hour
    }

    var color: LegoColor {
        LegoColor.allColors.first { $0.id == colorId } ?? LegoColor.allColors[0]
    }
}

struct LegoColor: Codable {
    let id: String
    let main: String
    let light: String
    let dark: String
    let glow: String

    var mainColor: Color {
        Color(hex: main)
    }

    var lightColor: Color {
        Color(hex: light)
    }

    var darkColor: Color {
        Color(hex: dark)
    }

    var glowColor: Color {
        Color(hex: glow)
    }

    static let allColors: [LegoColor] = [
        LegoColor(id: "red", main: "#E63946", light: "#FF6B6B", dark: "#A1161E", glow: "#E63946"),
        LegoColor(id: "orange", main: "#F77F00", light: "#FFA500", dark: "#D66E00", glow: "#F77F00"),
        LegoColor(id: "green", main: "#06A77D", light: "#00D9A3", dark: "#045A52", glow: "#06A77D"),
        LegoColor(id: "blue", main: "#3A86FF", light: "#72B4FF", dark: "#1E3A8A", glow: "#3A86FF"),
        LegoColor(id: "purple", main: "#8338EC", light: "#A867F3", dark: "#4C1D95", glow: "#8338EC"),
        LegoColor(id: "deepOrange", main: "#FB5607", light: "#FF8C42", dark: "#C41E3A", glow: "#FB5607"),
        LegoColor(id: "pink", main: "#FF006E", light: "#FF5C9A", dark: "#AD004C", glow: "#FF006E"),
        LegoColor(id: "white", main: "#F1FAEE", light: "#FFFFFF", dark: "#BDC4CB", glow: "#F1FAEE")
    ]
}

// Color extension to support hex strings
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Data Provider
class WidgetDataProvider {
    static let shared = WidgetDataProvider()
    private let storageKey = "legoTimePlannerCategories"
    private let appGroupId = "group.alex.blockstime"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    func loadCategories() -> [Category] {
        // Enhanced diagnostic logging
        print("🔍 Widget: Attempting to load categories...")
        print("   App Group ID: \(appGroupId)")
        print("   Storage Key: \(storageKey)")

        // Check if sharedDefaults is accessible
        guard let defaults = sharedDefaults else {
            print("❌ Widget: Failed to access shared UserDefaults for app group '\(appGroupId)'")
            print("⚠️ Widget: This usually means:")
            print("   1. App Group is not enabled in Xcode project settings")
            print("   2. App Group ID doesn't match between main app and widget")
            print("   3. App Group is not configured in Apple Developer account")
            return defaultCategories()
        }

        print("✅ Widget: Successfully accessed shared UserDefaults")

        // Try to get all keys to see what's available
        if let allKeys = defaults.dictionaryRepresentation().keys as? [String] {
            print("📋 Widget: Available keys in shared storage: \(allKeys.joined(separator: ", "))")
        }

        guard let data = defaults.data(forKey: storageKey) else {
            print("⚠️ Widget: No data found for key '\(storageKey)'")
            print("   Main app may not have saved data yet, or using different key")
            return defaultCategories()
        }

        print("✅ Widget: Found data for key '\(storageKey)' (\(data.count) bytes)")

        do {
            let decoder = JSONDecoder()
            let categories = try decoder.decode([Category].self, from: data)
            print("✅ Widget: Successfully decoded \(categories.count) categories")

            // Log ALL categories for debugging (including those with 0 hours)
            print("📊 Widget: All decoded categories:")
            for category in categories {
                let status = category.hours > 0 ? "✅ Will display" : "⚠️ Filtered (0 hours)"
                print("   - \(category.name): \(category.hours)h (color: \(category.colorId)) [\(status)]")
            }

            let visibleCount = categories.filter({ $0.hours > 0 }).count
            print("👁️ Widget: Will display \(visibleCount) out of \(categories.count) categories")

            return categories
        } catch {
            print("❌ Widget: Failed to decode categories: \(error.localizedDescription)")
            print("   Data may be corrupted or in wrong format")
            return defaultCategories()
        }
    }

    private func defaultCategories() -> [Category] {
        return [
            Category(id: UUID().uuidString, name: "睡眠", hours: 56, colorId: "red"),
            Category(id: UUID().uuidString, name: "工作", hours: 40, colorId: "orange"),
            Category(id: UUID().uuidString, name: "自由", hours: 72, colorId: "green")
        ]
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> BlocksEntry {
        BlocksEntry(date: Date(), categories: WidgetDataProvider.shared.loadCategories())
    }

    func getSnapshot(in context: Context, completion: @escaping (BlocksEntry) -> ()) {
        let entry = BlocksEntry(date: Date(), categories: WidgetDataProvider.shared.loadCategories())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let categories = WidgetDataProvider.shared.loadCategories()

        // Create entry with current data
        let entry = BlocksEntry(date: currentDate, categories: categories)

        // Use .atEnd policy for immediate updates when reloadAllTimelines() is called
        // This ensures the widget updates as soon as the app saves new data
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)

        print("📱 Widget timeline updated at \(currentDate) with \(categories.count) categories")
    }
}

struct BlocksEntry: TimelineEntry {
    let date: Date
    let categories: [Category]
}

// MARK: - Widget Block View
struct WidgetLegoBlock: View {
    let number: Int?
    let color: LegoColor
    let size: CGFloat
    let showNumber: Bool

    init(number: Int? = nil, color: LegoColor, size: CGFloat, showNumber: Bool = true) {
        self.number = number
        self.color = color
        self.size = size
        self.showNumber = showNumber
    }

    var body: some View {
        ZStack {
            // Main block with gradient
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.lightColor,
                            color.mainColor,
                            color.darkColor
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            // Border
            RoundedRectangle(cornerRadius: size * 0.1)
                .stroke(color.darkColor, lineWidth: 1.5)
                .frame(width: size, height: size)

            // Number text
            if showNumber, let number = number {
                Text("\(number)")
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 1, x: 0.5, y: 0.5)
            }
        }
        .shadow(color: color.glowColor.opacity(0.2), radius: 2, x: 1, y: 1)
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let categories: [Category]

    private var allBlocks: [(category: Category, blockIndex: Int)] {
        var blocks: [(Category, Int)] = []
        for category in categories.filter({ $0.hours > 0 }) {
            for index in 0..<category.blocksCount {
                blocks.append((category, index))
            }
        }
        return blocks
    }

    // Get the top category by hours
    private var topCategory: Category? {
        categories.filter({ $0.hours > 0 }).max(by: { $0.hours < $1.hours })
    }

    // Get top 2 categories
    private var topCategories: [Category] {
        categories.filter({ $0.hours > 0 })
            .sorted(by: { $0.hours > $1.hours })
            .prefix(2)
            .map { $0 }
    }

    // Calculate optimal layout for small widget - fits all blocks without scrolling
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, rows: Int, blockSize: CGFloat, spacing: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (7, 7, 10, 2)
        }

        let headerHeight: CGFloat = 32  // Slightly increased for better spacing
        let legendHeight: CGFloat = 56  // Space for improved legend
        let horizontalPadding: CGFloat = 20
        let verticalPadding: CGFloat = 16
        let availableWidth = max(0, width - horizontalPadding)
        let availableHeight = max(0, height - headerHeight - legendHeight - verticalPadding)

        var bestColumns = 7
        var bestRows = 24
        var bestBlockSize: CGFloat = 5
        var bestSpacing: CGFloat = 1.0

        // Try different column counts to find optimal layout
        for cols in stride(from: 14, through: 7, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))
            let spacing: CGFloat = 1.0

            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            // Verify the layout fits
            let totalWidthNeeded = CGFloat(cols) * blockSize + CGFloat(cols - 1) * spacing
            let totalHeightNeeded = CGFloat(rows) * blockSize + CGFloat(rows - 1) * spacing

            if blockSize >= 4.5 && totalWidthNeeded <= availableWidth && totalHeightNeeded <= availableHeight {
                bestColumns = cols
                bestRows = rows
                bestBlockSize = blockSize
                bestSpacing = spacing
                break
            }
        }

        return (bestColumns, bestRows, bestBlockSize, bestSpacing)
    }

    var body: some View {
        GeometryReader { geometry in
            let layout = calculateLayout(width: geometry.size.width, height: geometry.size.height)
            let columns = layout.columns
            let blockSize = layout.blockSize
            let spacing = layout.spacing

            VStack(spacing: 5) {
                // Compact header with 168h badge
                HStack(alignment: .center, spacing: 6) {
                    Text("週時間")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 3) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 7))
                            .foregroundColor(.white.opacity(0.8))
                        Text("168h")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.15))
                    )

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)

                // Blocks Grid - centered and properly constrained
                HStack {
                    Spacer(minLength: 0)
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(blockSize), spacing: spacing), count: columns),
                        spacing: spacing
                    ) {
                        ForEach(Array(allBlocks.enumerated()), id: \.offset) { _, block in
                            WidgetLegoBlock(
                                number: nil,
                                color: block.category.color,
                                size: blockSize,
                                showNumber: false
                            )
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 4)

                // Enhanced legend - show top 2 categories with stats
                VStack(spacing: 3) {
                    ForEach(topCategories, id: \.id) { category in
                        HStack(spacing: 4) {
                            // Color indicator
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            category.color.lightColor,
                                            category.color.mainColor
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 9, height: 9)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2.5)
                                        .stroke(category.color.darkColor.opacity(0.3), lineWidth: 0.7)
                                )

                            Text(category.name)
                                .font(.system(size: 8.5, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(1)

                            Spacer(minLength: 0)

                            HStack(spacing: 2) {
                                Text("\(Int(category.hours))h")
                                    .font(.system(size: 8.5, weight: .bold))
                                    .foregroundColor(.white)

                                Text("\(Int(category.hours / 168.0 * 100))%")
                                    .font(.system(size: 7.5, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.vertical, 1)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let categories: [Category]

    private var allBlocks: [(category: Category, blockIndex: Int)] {
        var blocks: [(Category, Int)] = []
        for category in categories.filter({ $0.hours > 0 }) {
            for index in 0..<category.blocksCount {
                blocks.append((category, index))
            }
        }
        return blocks
    }

    // Calculate optimal layout for medium widget - fits all blocks without scrolling
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, rows: Int, blockSize: CGFloat, spacing: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (14, 12, 12, 2)
        }

        let legendWidth: CGFloat = 75  // Optimized legend width with more padding
        let titleHeight: CGFloat = 32  // Slightly increased for better header spacing
        let horizontalPadding: CGFloat = 24
        let verticalPadding: CGFloat = 20
        let availableWidth = max(0, width - legendWidth - horizontalPadding)
        let availableHeight = max(0, height - titleHeight - verticalPadding)

        var bestColumns = 14
        var bestRows = 12
        var bestBlockSize: CGFloat = 7
        var bestSpacing: CGFloat = 1.8

        // Try different column counts to find optimal layout
        for cols in stride(from: 21, through: 12, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))
            let spacing: CGFloat = 1.8

            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            // Verify the layout fits
            let totalWidthNeeded = CGFloat(cols) * blockSize + CGFloat(cols - 1) * spacing
            let totalHeightNeeded = CGFloat(rows) * blockSize + CGFloat(rows - 1) * spacing

            if blockSize >= 6.5 && totalWidthNeeded <= availableWidth && totalHeightNeeded <= availableHeight {
                bestColumns = cols
                bestRows = rows
                bestBlockSize = blockSize
                bestSpacing = spacing
                break
            }
        }

        return (bestColumns, bestRows, bestBlockSize, bestSpacing)
    }

    var body: some View {
        GeometryReader { geometry in
            let layout = calculateLayout(width: geometry.size.width, height: geometry.size.height)
            let columns = layout.columns
            let blockSize = layout.blockSize
            let spacing = layout.spacing

            HStack(spacing: 8) {
                // Blocks Grid Section
                VStack(alignment: .leading, spacing: 5) {
                    // Unified header
                    HStack(alignment: .center, spacing: 5) {
                        Text("週時間")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)

                        Text("168h")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.12))
                            )

                        Spacer(minLength: 0)
                    }

                    // Blocks Grid - centered horizontally
                    HStack {
                        Spacer(minLength: 0)
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.fixed(blockSize), spacing: spacing), count: columns),
                            spacing: spacing
                        ) {
                            ForEach(Array(allBlocks.enumerated()), id: \.offset) { _, block in
                                WidgetLegoBlock(
                                    number: nil,
                                    color: block.category.color,
                                    size: blockSize,
                                    showNumber: false
                                )
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
                .padding(.leading, 12)
                .padding(.vertical, 10)

                // Compact Legend with better visual hierarchy
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(categories.filter({ $0.hours > 0 }), id: \.id) { category in
                            VStack(alignment: .leading, spacing: 2) {
                                // Category name with color indicator
                                HStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    category.color.lightColor,
                                                    category.color.mainColor,
                                                    category.color.darkColor
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 12, height: 12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 3)
                                                .stroke(category.color.darkColor.opacity(0.3), lineWidth: 0.8)
                                        )

                                    Text(category.name)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }

                                // Time and percentage on same line
                                HStack(spacing: 3) {
                                    Text("\(Int(category.hours))h")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.9))

                                    Text("(\(Int(category.hours / 168.0 * 100))%)")
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding(.vertical, 1)
                        }
                    }
                }
                .frame(width: 68)
                .padding(.trailing, 8)
                .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let categories: [Category]

    private var allBlocks: [(category: Category, blockIndex: Int)] {
        var blocks: [(Category, Int)] = []
        for category in categories.filter({ $0.hours > 0 }) {
            for index in 0..<category.blocksCount {
                blocks.append((category, index))
            }
        }
        return blocks
    }

    // Calculate optimal layout for large widget - fits all blocks without scrolling
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, rows: Int, blockSize: CGFloat, spacing: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (14, 12, 20, 3.5)
        }

        // Optimized spacing to maximize block display area
        // 實際佈局：Header (標題 + badge) -> Legend (圖例) -> Blocks Grid
        let headerHeight: CGFloat = 32  // 標題區域（含 padding）
        let legendHeight: CGFloat = 42  // 圖例區域（含 padding）
        let topPadding: CGFloat = 8     // 頂部 padding
        let bottomPadding: CGFloat = 8  // 底部 padding
        let sectionSpacing: CGFloat = 4 // 區域間距
        let horizontalPadding: CGFloat = 24

        let totalVerticalSpace = headerHeight + legendHeight + topPadding + bottomPadding + (sectionSpacing * 2)
        let availableWidth = max(0, width - horizontalPadding)
        let availableHeight = max(0, height - totalVerticalSpace)

        var bestColumns = 14
        var bestRows = 12
        var bestBlockSize: CGFloat = 13
        var bestSpacing: CGFloat = 1.8

        // Try different column counts to find optimal layout
        // 擴大搜尋範圍從 28 到 14 列，使用更小的間距
        for cols in stride(from: 28, through: 14, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))
            let spacing: CGFloat = 1.8  // 減少間距以容納更多區塊

            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            // Verify the layout fits
            let totalWidthNeeded = CGFloat(cols) * blockSize + CGFloat(cols - 1) * spacing
            let totalHeightNeeded = CGFloat(rows) * blockSize + CGFloat(rows - 1) * spacing

            // 降低最小區塊大小限制至 10pt，讓更多區塊能顯示
            if blockSize >= 10 && totalWidthNeeded <= availableWidth && totalHeightNeeded <= availableHeight {
                bestColumns = cols
                bestRows = rows
                bestBlockSize = blockSize
                bestSpacing = spacing
                break
            }
        }

        return (bestColumns, bestRows, bestBlockSize, bestSpacing)
    }

    var body: some View {
        GeometryReader { geometry in
            let layout = calculateLayout(width: geometry.size.width, height: geometry.size.height)
            let columns = layout.columns
            let blockSize = layout.blockSize
            let spacing = layout.spacing

            VStack(alignment: .leading, spacing: 4) {
                // Compact Header with 168h badge
                HStack(alignment: .center, spacing: 6) {
                    Text("週時間規劃")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)

                    // Prominent 168h badge
                    HStack(spacing: 2) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.9))
                        Text("168h")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.white.opacity(0.15))
                    )

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                // Categories Legend - Scrollable if too many categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories.filter({ $0.hours > 0 }), id: \.id) { category in
                            HStack(spacing: 4) {
                                // Compact color indicator
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                category.color.lightColor,
                                                category.color.mainColor,
                                                category.color.darkColor
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 14, height: 14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(category.color.darkColor.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: category.color.glowColor.opacity(0.15), radius: 1, x: 0, y: 0.5)

                                VStack(alignment: .leading, spacing: 0) {
                                    Text(category.name)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    HStack(spacing: 2) {
                                        Text("\(Int(category.hours))h")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.85))

                                        Text("(\(Int(category.hours / 168.0 * 100))%)")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                }
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal, 12)

                // Blocks Grid - centered and properly constrained
                HStack {
                    Spacer(minLength: 0)
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(blockSize), spacing: spacing), count: columns),
                        spacing: spacing
                    ) {
                        ForEach(Array(allBlocks.enumerated()), id: \.offset) { _, block in
                            WidgetLegoBlock(
                                number: nil,
                                color: block.category.color,
                                size: blockSize,
                                showNumber: false
                            )
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

// MARK: - Main Widget Entry View
struct blockstimewidgeEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(categories: entry.categories)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        case .systemMedium:
            MediumWidgetView(categories: entry.categories)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        case .systemLarge, .systemExtraLarge:
            LargeWidgetView(categories: entry.categories)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        default:
            SmallWidgetView(categories: entry.categories)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
    }
}

// MARK: - Widget Configuration
struct blockstimewidge: Widget {
    let kind: String = "blockstimewidge"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            blockstimewidgeEntryView(entry: entry)
        }
        .configurationDisplayName("Blocks Time")
        .description("以積木方塊視覺化您的週時間規劃")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews
#Preview(as: .systemSmall) {
    blockstimewidge()
} timeline: {
    BlocksEntry(date: .now, categories: WidgetDataProvider.shared.loadCategories())
}

#Preview(as: .systemMedium) {
    blockstimewidge()
} timeline: {
    BlocksEntry(date: .now, categories: WidgetDataProvider.shared.loadCategories())
}

#Preview(as: .systemLarge) {
    blockstimewidge()
} timeline: {
    BlocksEntry(date: .now, categories: WidgetDataProvider.shared.loadCategories())
}

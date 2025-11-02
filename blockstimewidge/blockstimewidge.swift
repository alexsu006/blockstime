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

    // Calculate optimal layout for small widget - maximize block size, reduce empty space
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, rows: Int, blockSize: CGFloat, spacing: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (14, 12, 8, 1)
        }

        // Reduce padding to fill more space
        let padding: CGFloat = 2
        let availableWidth = max(0, width - padding * 2)
        let availableHeight = max(0, height - padding * 2)

        var bestColumns = 14
        var bestRows = 12
        var bestBlockSize: CGFloat = 4
        var bestSpacing: CGFloat = 0.3

        // Reduce column count to make blocks bigger - start from 20 instead of 28
        for cols in stride(from: 20, through: 10, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))
            let spacing: CGFloat = 0.3  // Tighter spacing for more compact layout

            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            // Verify the layout fits
            let totalWidthNeeded = CGFloat(cols) * blockSize + CGFloat(cols - 1) * spacing
            let totalHeightNeeded = CGFloat(rows) * blockSize + CGFloat(rows - 1) * spacing

            // Increase minimum block size to make blocks more visible
            if blockSize >= 12 && totalWidthNeeded <= availableWidth && totalHeightNeeded <= availableHeight {
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

            // Only display blocks - no title, no legend, maximize space
            // Remove all spacers to fill the entire widget
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(blockSize), spacing: spacing), count: columns),
                alignment: .center,
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(2)
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

    // Get top 5 categories for medium widget
    private var topCategories: [Category] {
        categories.filter({ $0.hours > 0 })
            .sorted(by: { $0.hours > $1.hours })
            .prefix(5)
            .map { $0 }
    }

    // Calculate total hours to avoid division by zero
    private var totalHours: Double {
        let total = categories.reduce(0.0) { $0 + $1.hours }
        return max(total, 1.0) // Prevent division by zero
    }

    // Calculate optimal layout for medium widget - vertical layout with legend at bottom
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, rows: Int, blockSize: CGFloat, spacing: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (21, 8, 6, 1)
        }

        // Reserve space for bottom legend (compact horizontal layout)
        let legendHeight: CGFloat = 26  // Compact legend at bottom
        let padding: CGFloat = 4
        let sectionSpacing: CGFloat = 3

        let availableWidth = max(0, width - padding * 2)
        let availableHeight = max(0, height - legendHeight - padding * 2 - sectionSpacing)

        var bestColumns = 21
        var bestRows = 8
        var bestBlockSize: CGFloat = 6
        var bestSpacing: CGFloat = 0.8

        // Try different column counts to find optimal layout - maximize block space
        for cols in stride(from: 32, through: 14, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))
            let spacing: CGFloat = 0.8  // Compact spacing

            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            // Verify the layout fits
            let totalWidthNeeded = CGFloat(cols) * blockSize + CGFloat(cols - 1) * spacing
            let totalHeightNeeded = CGFloat(rows) * blockSize + CGFloat(rows - 1) * spacing

            // Lower minimum to ensure all blocks fit
            if blockSize >= 6 && totalWidthNeeded <= availableWidth && totalHeightNeeded <= availableHeight {
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

            VStack(spacing: 3) {
                // Blocks Grid - fills most of the space, no spacers
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(blockSize), spacing: spacing), count: columns),
                    alignment: .center,
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
                .frame(maxWidth: .infinity, alignment: .center)

                // Bottom Legend - Top 3 categories horizontal layout
                HStack(spacing: 6) {
                    ForEach(topCategories, id: \.id) { category in
                        HStack(spacing: 3) {
                            // Color indicator
                            RoundedRectangle(cornerRadius: 2.5)
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
                                .frame(width: 11, height: 11)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2.5)
                                        .stroke(category.color.darkColor.opacity(0.3), lineWidth: 0.8)
                                )

                            VStack(alignment: .leading, spacing: 0) {
                                Text(category.name)
                                    .font(.system(size: 8.5, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .truncationMode(.tail)

                                HStack(spacing: 2) {
                                    Text("\(Int(category.hours))h")
                                        .font(.system(size: 8, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.85))

                                    Text("(\(Int((category.hours / totalHours) * 100))%)")
                                        .font(.system(size: 7, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .lineLimit(1)
                            }
                            .frame(maxWidth: 65)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal, 4)
            }
            .padding(4)
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

    // Calculate total hours to avoid division by zero
    private var totalHours: Double {
        let total = categories.reduce(0.0) { $0 + $1.hours }
        return max(total, 1.0) // Prevent division by zero
    }

    // Calculate optimal layout for large widget - maximize block size, fill available space
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, rows: Int, blockSize: CGFloat, spacing: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (21, 8, 15, 2)
        }

        // Reserve space for bottom legend - horizontal scrollable layout
        let legendHeight: CGFloat = 32  // Bottom legend area
        let padding: CGFloat = 4  // Reduced padding for more space
        let sectionSpacing: CGFloat = 3  // Reduced spacing

        let availableWidth = max(0, width - padding * 2)
        let availableHeight = max(0, height - legendHeight - padding * 2 - sectionSpacing)

        var bestColumns = 21
        var bestRows = 8
        var bestBlockSize: CGFloat = 18  // Increased default block size
        var bestSpacing: CGFloat = 1.0  // Tighter spacing

        // Try different column counts to find optimal layout - maximize blocks
        // Start from 24 instead of 28 to make blocks bigger
        for cols in stride(from: 24, through: 14, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))
            let spacing: CGFloat = 1.0  // Tighter spacing for more block space

            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            // Verify the layout fits
            let totalWidthNeeded = CGFloat(cols) * blockSize + CGFloat(cols - 1) * spacing
            let totalHeightNeeded = CGFloat(rows) * blockSize + CGFloat(rows - 1) * spacing

            // Increase minimum block size to make blocks more prominent
            if blockSize >= 18.5 && totalWidthNeeded <= availableWidth && totalHeightNeeded <= availableHeight {
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

            VStack(spacing: 4) {
                // Blocks Grid - fills most of the space, no spacers
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(blockSize), spacing: spacing), count: columns),
                    alignment: .center,
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
                .frame(maxWidth: .infinity, alignment: .center)

                // Bottom Legend - All categories horizontal scrollable layout
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories.filter({ $0.hours > 0 }), id: \.id) { category in
                            HStack(spacing: 3) {
                                // Color indicator
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
                                    .shadow(color: category.color.glowColor.opacity(0.15), radius: 1, x: 0, y: 0.5)

                                VStack(alignment: .leading, spacing: 0) {
                                    Text(category.name)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .truncationMode(.tail)

                                    HStack(spacing: 2) {
                                        Text("\(Int(category.hours))h")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.85))

                                        Text("(\(Int((category.hours / totalHours) * 100))%)")
                                            .font(.system(size: 8, weight: .medium))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    .lineLimit(1)
                                }
                                .frame(maxWidth: 80)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                }
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal, 4)
            }
            .padding(4)
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

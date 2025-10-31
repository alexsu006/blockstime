//
//  blockstimewidge.swift
//  blockstimewidge
//
//  Created by Alex Su on 2025/10/31.
//

import WidgetKit
import SwiftUI

// MARK: - Shared Models
struct WidgetCategory: Codable {
    let id: String
    let name: String
    let hours: Double
    let colorId: String

    var blocksCount: Int {
        Int(ceil(hours / 1.0)) // 1 block = 1 hour
    }

    var color: WidgetLegoColor {
        WidgetLegoColor.allColors.first { $0.id == colorId } ?? WidgetLegoColor.allColors[0]
    }
}

struct WidgetLegoColor: Codable {
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

    static let allColors: [WidgetLegoColor] = [
        WidgetLegoColor(id: "red", main: "#E63946", light: "#FF6B6B", dark: "#A1161E", glow: "#E63946"),
        WidgetLegoColor(id: "orange", main: "#F77F00", light: "#FFA500", dark: "#D66E00", glow: "#F77F00"),
        WidgetLegoColor(id: "green", main: "#06A77D", light: "#00D9A3", dark: "#045A52", glow: "#06A77D"),
        WidgetLegoColor(id: "blue", main: "#3A86FF", light: "#72B4FF", dark: "#1E3A8A", glow: "#3A86FF"),
        WidgetLegoColor(id: "purple", main: "#8338EC", light: "#A867F3", dark: "#4C1D95", glow: "#8338EC"),
        WidgetLegoColor(id: "deepOrange", main: "#FB5607", light: "#FF8C42", dark: "#C41E3A", glow: "#FB5607"),
        WidgetLegoColor(id: "pink", main: "#FF006E", light: "#FF5C9A", dark: "#AD004C", glow: "#FF006E"),
        WidgetLegoColor(id: "white", main: "#F1FAEE", light: "#FFFFFF", dark: "#BDC4CB", glow: "#F1FAEE")
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

    func loadCategories() -> [WidgetCategory] {
        guard let data = sharedDefaults?.data(forKey: storageKey) else {
            return defaultCategories()
        }

        do {
            let decoder = JSONDecoder()
            // Try to decode as WidgetCategory first
            if let categories = try? decoder.decode([WidgetCategory].self, from: data) {
                return categories
            }

            // Fallback to a generic dictionary approach for compatibility
            return defaultCategories()
        }
    }

    private func defaultCategories() -> [WidgetCategory] {
        return [
            WidgetCategory(id: UUID().uuidString, name: "睡眠", hours: 56, colorId: "red"),
            WidgetCategory(id: UUID().uuidString, name: "工作", hours: 40, colorId: "orange"),
            WidgetCategory(id: UUID().uuidString, name: "自由", hours: 72, colorId: "green")
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

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let entry = BlocksEntry(date: currentDate, categories: categories)

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct BlocksEntry: TimelineEntry {
    let date: Date
    let categories: [WidgetCategory]
}

// MARK: - Widget Block View
struct WidgetLegoBlock: View {
    let number: Int?
    let color: WidgetLegoColor
    let size: CGFloat
    let showNumber: Bool

    init(number: Int? = nil, color: WidgetLegoColor, size: CGFloat, showNumber: Bool = true) {
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
    let categories: [WidgetCategory]

    private var allBlocks: [(category: WidgetCategory, blockIndex: Int)] {
        var blocks: [(WidgetCategory, Int)] = []
        for category in categories.filter({ $0.hours > 0 }) {
            for index in 0..<category.blocksCount {
                blocks.append((category, index))
            }
        }
        return blocks
    }

    // Calculate optimal layout for small widget - fits all blocks without scrolling
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, rows: Int, blockSize: CGFloat, spacing: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (7, 7, 10, 2)
        }

        let titleHeight: CGFloat = 20
        let padding: CGFloat = 12
        let availableWidth = width - padding
        let availableHeight = height - titleHeight - padding

        // For 168 blocks, try to find the best grid that fits
        var bestColumns = 7
        var bestRows = 24
        var bestBlockSize: CGFloat = 6
        var bestSpacing: CGFloat = 1.0

        // Try different column counts to find optimal layout
        // Small widget needs more columns to fit all 168 blocks
        for cols in stride(from: 14, through: 7, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))
            let spacing: CGFloat = 1.0

            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            // Make sure all blocks fit - reduced minimum size to 4
            if blockSize >= 4 && blockSize * CGFloat(rows) + spacing * CGFloat(rows - 1) <= availableHeight {
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
                // Title
                HStack {
                    Text("Blocks Time")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)

                // Blocks Grid (NO ScrollView - widgets can't scroll)
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
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let categories: [WidgetCategory]

    private var allBlocks: [(category: WidgetCategory, blockIndex: Int)] {
        var blocks: [(WidgetCategory, Int)] = []
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

        let legendWidth: CGFloat = 60
        let titleHeight: CGFloat = 24
        let padding: CGFloat = 20
        let availableWidth = width - legendWidth - padding
        let availableHeight = height - titleHeight - padding

        var bestColumns = 14
        var bestRows = 12
        var bestBlockSize: CGFloat = 8
        var bestSpacing: CGFloat = 1.5

        // Try different column counts to find optimal layout
        // Medium widget needs more columns to fit all 168 blocks
        for cols in stride(from: 21, through: 12, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))
            let spacing: CGFloat = 1.5

            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            // Make sure all blocks fit - reduced minimum size to 6
            if blockSize >= 6 && blockSize * CGFloat(rows) + spacing * CGFloat(rows - 1) <= availableHeight {
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
                // Blocks Grid
                VStack(spacing: 4) {
                    HStack {
                        Text("週時間規劃")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }

                    // Blocks Grid (NO ScrollView - widgets can't scroll)
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
                }
                .padding(10)

                // Legend
                VStack(alignment: .leading, spacing: 5) {
                    Text("分類")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))

                    ForEach(categories.filter({ $0.hours > 0 }), id: \.id) { category in
                        HStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(category.color.mainColor)
                                .frame(width: 10, height: 10)

                            VStack(alignment: .leading, spacing: 0) {
                                Text(category.name)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text("\(Int(category.hours))h")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }

                    Spacer()
                }
                .frame(width: 60)
                .padding(.trailing, 8)
                .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let categories: [WidgetCategory]

    private var allBlocks: [(category: WidgetCategory, blockIndex: Int)] {
        var blocks: [(WidgetCategory, Int)] = []
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
        let headerHeight: CGFloat = 45  // Slightly increased for larger fonts
        let legendHeight: CGFloat = 35  // Reduced to save space
        let horizontalPadding: CGFloat = 16  // Reduced from 20
        let verticalPadding: CGFloat = 12  // Reduced from 16
        let availableWidth = width - horizontalPadding
        let availableHeight = height - headerHeight - legendHeight - verticalPadding

        var bestColumns = 14
        var bestRows = 12
        var bestBlockSize: CGFloat = 20  // Default target block size
        var bestSpacing: CGFloat = 3.5  // Increased from 2.5

        // Try different column counts to find optimal layout
        // Large widget can use more columns for better space utilization
        for cols in stride(from: 24, through: 14, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))
            let spacing: CGFloat = 3.5  // Larger spacing for better visual separation

            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            // Increased minimum size to 12 for larger, more visible blocks
            if blockSize >= 12 && blockSize * CGFloat(rows) + spacing * CGFloat(rows - 1) <= availableHeight {
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

            VStack(spacing: 6) {
                // Header - Larger fonts for better visibility
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Blocks Time Planner")
                            .font(.system(size: 18, weight: .bold))  // Increased from 15
                            .foregroundColor(.white)
                        Text("週時間視覺化")
                            .font(.system(size: 12))  // Increased from 10
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Text("168小時")
                        .font(.system(size: 16, weight: .semibold))  // Increased from 13
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 10)  // Reduced from 12 for more space
                .padding(.top, 10)  // Reduced from 12

                // Blocks Grid (NO ScrollView - widgets can't scroll)
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
                .padding(.horizontal, 10)  // Reduced from 12 for more space

                // Categories Legend - Larger fonts and icons
                HStack(spacing: 12) {  // Increased spacing from 10
                    ForEach(categories.filter({ $0.hours > 0 }), id: \.id) { category in
                        HStack(spacing: 5) {  // Increased from 4
                            RoundedRectangle(cornerRadius: 3)  // Increased radius from 2
                                .fill(category.color.mainColor)
                                .frame(width: 16, height: 16)  // Increased from 14x14

                            VStack(alignment: .leading, spacing: 0) {
                                Text(category.name)
                                    .font(.system(size: 12, weight: .medium))  // Increased from 10
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text("\(Int(category.hours))h (\(Int(category.hours / 168.0 * 100))%)")
                                    .font(.system(size: 10))  // Increased from 8
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)  // Reduced from 12 for more space
                .padding(.bottom, 10)  // Reduced from 12
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

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

    // Calculate optimal layout for small widget
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, blockSize: CGFloat, spacing: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (7, 10, 2)
        }

        let titleHeight: CGFloat = 28
        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 16
        let availableWidth = width - horizontalPadding
        let availableHeight = height - titleHeight - verticalPadding

        var bestColumns = 7
        var bestBlockSize: CGFloat = 10
        var bestSpacing: CGFloat = 2

        // Try different column counts
        for cols in stride(from: 10, through: 5, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))

            let spacing: CGFloat = 2
            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            if blockSize >= 8 && blockSize <= 20 {
                bestColumns = cols
                bestBlockSize = blockSize
                bestSpacing = spacing
                break
            }
        }

        return (bestColumns, bestBlockSize, bestSpacing)
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
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)

                // Scrollable Blocks Grid
                ScrollView(.vertical, showsIndicators: true) {
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    // Calculate optimal layout for medium widget
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, blockSize: CGFloat, spacing: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (14, 16, 3)
        }

        let legendWidth: CGFloat = 80
        let titleHeight: CGFloat = 30
        let padding: CGFloat = 30
        let availableWidth = width - legendWidth - padding
        let availableHeight = height - titleHeight - padding

        var bestColumns = 14
        var bestBlockSize: CGFloat = 16
        var bestSpacing: CGFloat = 3

        // Try different column counts
        for cols in stride(from: 20, through: 8, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))

            let spacing: CGFloat = 3
            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            if blockSize >= 12 && blockSize <= 24 {
                bestColumns = cols
                bestBlockSize = blockSize
                bestSpacing = spacing
                break
            }
        }

        return (bestColumns, bestBlockSize, bestSpacing)
    }

    var body: some View {
        GeometryReader { geometry in
            let layout = calculateLayout(width: geometry.size.width, height: geometry.size.height)
            let columns = layout.columns
            let blockSize = layout.blockSize
            let spacing = layout.spacing

            HStack(spacing: 12) {
                // Blocks Grid
                VStack(spacing: 4) {
                    HStack {
                        Text("週時間規劃")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }

                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.fixed(blockSize), spacing: spacing), count: columns),
                            spacing: spacing
                        ) {
                            ForEach(Array(allBlocks.enumerated()), id: \.offset) { _, block in
                                WidgetLegoBlock(
                                    number: block.blockIndex + 1,
                                    color: block.category.color,
                                    size: blockSize,
                                    showNumber: blockSize >= 14
                                )
                            }
                        }
                    }
                }
                .padding(10)

                // Legend
                VStack(alignment: .leading, spacing: 6) {
                    Text("分類")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))

                    ForEach(categories.filter({ $0.hours > 0 }), id: \.id) { category in
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(category.color.mainColor)
                                .frame(width: 12, height: 12)

                            VStack(alignment: .leading, spacing: 0) {
                                Text(category.name)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.white)
                                Text("\(Int(category.hours))h")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.trailing, 10)
                .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    // Calculate optimal layout for large widget
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, blockSize: CGFloat, spacing: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (12, 20, 4)
        }

        let headerHeight: CGFloat = 50
        let legendHeight: CGFloat = 50
        let horizontalPadding: CGFloat = 24
        let verticalPadding: CGFloat = 24
        let availableWidth = width - horizontalPadding
        let availableHeight = height - headerHeight - legendHeight - verticalPadding

        var bestColumns = 12
        var bestBlockSize: CGFloat = 20
        var bestSpacing: CGFloat = 4

        // Try different column counts
        for cols in stride(from: 20, through: 8, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))

            let spacing: CGFloat = 4
            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * spacing) / CGFloat(cols)
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

            let blockSize = min(widthBasedSize, heightBasedSize)

            if blockSize >= 16 && blockSize <= 30 {
                bestColumns = cols
                bestBlockSize = blockSize
                bestSpacing = spacing
                break
            }
        }

        return (bestColumns, bestBlockSize, bestSpacing)
    }

    var body: some View {
        GeometryReader { geometry in
            let layout = calculateLayout(width: geometry.size.width, height: geometry.size.height)
            let columns = layout.columns
            let blockSize = layout.blockSize
            let spacing = layout.spacing

            VStack(spacing: 8) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Blocks Time Planner")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("週時間視覺化")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Text("168小時")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

                // Scrollable Blocks Grid
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(blockSize), spacing: spacing), count: columns),
                        spacing: spacing
                    ) {
                        ForEach(Array(allBlocks.enumerated()), id: \.offset) { _, block in
                            WidgetLegoBlock(
                                number: block.blockIndex + 1,
                                color: block.category.color,
                                size: blockSize,
                                showNumber: blockSize >= 18
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                }

                // Categories Legend
                HStack(spacing: 12) {
                    ForEach(categories.filter({ $0.hours > 0 }), id: \.id) { category in
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(category.color.mainColor)
                                .frame(width: 16, height: 16)

                            VStack(alignment: .leading, spacing: 0) {
                                Text(category.name)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white)
                                Text("\(Int(category.hours))h (\(Int(category.hours / 168.0 * 100))%)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

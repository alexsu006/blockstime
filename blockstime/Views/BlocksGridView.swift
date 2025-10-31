//
//  BlocksGridView.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import SwiftUI
import UniformTypeIdentifiers

struct BlocksGridView: View {
    @ObservedObject var viewModel: CategoryViewModel

    // Cache for memoization
    @State private var cachedBlocks: [(category: Category, blockIndex: Int)] = []
    @State private var lastCategoryHash: Int = 0

    // 生成所有積木的陣列（不分類別，統一顯示）- 使用記憶化優化性能
    private var allBlocks: [(category: Category, blockIndex: Int)] {
        // Create a hash of current categories state to detect changes
        let currentHash = viewModel.categories.map { "\($0.id):\($0.hours)" }.joined().hashValue

        // Only recompute if categories changed
        if currentHash != lastCategoryHash {
            DispatchQueue.main.async {
                self.lastCategoryHash = currentHash
                self.cachedBlocks = computeBlocks()
            }
        }

        return cachedBlocks.isEmpty ? computeBlocks() : cachedBlocks
    }

    private func computeBlocks() -> [(category: Category, blockIndex: Int)] {
        var blocks: [(Category, Int)] = []
        for category in viewModel.categories.filter({ $0.hours > 0 }) {
            for index in 0..<category.blocksCount {
                blocks.append((category, index))
            }
        }
        return blocks
    }

    // 計算最佳的列數和積木大小
    private func calculateLayout(width: CGFloat, height: CGFloat) -> (columns: Int, blockSize: CGFloat) {
        let totalBlocks = allBlocks.count
        guard totalBlocks > 0 else {
            return (Constants.defaultLayoutColumns, Constants.blockSize)
        }

        let padding: CGFloat = 30
        let availableWidth = width - padding
        let availableHeight = height - padding

        // 嘗試不同的列數，找到最適合的佈局
        var bestColumns = Constants.defaultLayoutColumns
        var bestBlockSize: CGFloat = Constants.blockSize

        for cols in stride(from: Constants.maxLayoutColumns, through: Constants.minLayoutColumns, by: -1) {
            let rows = Int(ceil(Double(totalBlocks) / Double(cols)))

            // 計算基於寬度的積木大小
            let widthBasedSize = (availableWidth - CGFloat(cols - 1) * Constants.blockGap) / CGFloat(cols)

            // 計算基於高度的積木大小
            let heightBasedSize = (availableHeight - CGFloat(rows - 1) * Constants.blockGap) / CGFloat(rows)

            // 使用較小的尺寸以確保兩個方向都能放得下
            let blockSize = min(widthBasedSize, heightBasedSize)

            // 如果積木大小合理，就使用這個佈局
            if blockSize >= Constants.minBlockSize && blockSize <= Constants.maxBlockSize {
                bestColumns = cols
                bestBlockSize = blockSize
                break
            }
        }

        return (bestColumns, bestBlockSize)
    }

    var body: some View {
        GeometryReader { geometry in
            let layout = calculateLayout(width: geometry.size.width, height: geometry.size.height)
            let columns = layout.columns
            let blockSize = layout.blockSize

            VStack {
                Spacer()
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(blockSize), spacing: Constants.blockGap), count: columns),
                    spacing: Constants.blockGap
                ) {
                    ForEach(Array(allBlocks.enumerated()), id: \.offset) { _, block in
                        LegoBlock(number: block.blockIndex + 1, color: block.category.color, size: blockSize)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(15)
        }
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
    }
}

struct CategoryBlockGroup: View {
    let category: Category
    @Binding var draggedBlock: DraggedBlock?
    let onBlockMoved: (Category, Category) -> Void

    @State private var isDropTarget = false

    private let columns = 4
    private var blockSize: CGFloat {
        // Calculate based on available width
        #if os(macOS)
        let screenWidth = NSScreen.main?.frame.width ?? 1024
        #else
        let screenWidth = UIScreen.main.bounds.width
        #endif
        let availableWidth = screenWidth - 340 // sidebar + padding
        let totalGap = CGFloat(columns - 1) * Constants.blockGap
        let containerPadding: CGFloat = 60
        return min(60, (availableWidth - totalGap - containerPadding) / CGFloat(columns))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Category label
            Text(category.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .padding(.leading, 10)

            // Blocks container
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(blockSize), spacing: Constants.blockGap), count: columns),
                spacing: Constants.blockGap
            ) {
                ForEach(0..<category.blocksCount, id: \.self) { index in
                    LegoBlock(number: index + 1, color: category.color, size: blockSize)
                        .onDrag {
                            draggedBlock = DraggedBlock(category: category, blockIndex: index)
                            return NSItemProvider(object: String(index) as NSString)
                        }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(isDropTarget ? 0.3 : 0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isDropTarget ? Color.white.opacity(0.3) : Color.clear,
                                lineWidth: 2
                            )
                            .allowsHitTesting(false)
                    )
            )
            .onDrop(of: [UTType.text], isTargeted: $isDropTarget) { providers in
                guard let draggedBlock = draggedBlock,
                      draggedBlock.category.id != category.id else {
                    return false
                }
                onBlockMoved(draggedBlock.category, category)
                self.draggedBlock = nil
                return true
            }
        }
    }
}

struct DraggedBlock: Equatable {
    let category: Category
    let blockIndex: Int

    static func == (lhs: DraggedBlock, rhs: DraggedBlock) -> Bool {
        lhs.category.id == rhs.category.id && lhs.blockIndex == rhs.blockIndex
    }
}

struct BlocksGridView_Previews: PreviewProvider {
    static var previews: some View {
        BlocksGridView(viewModel: CategoryViewModel())
            .background(Color.black)
    }
}

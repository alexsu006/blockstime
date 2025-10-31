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
    @State private var draggedBlock: DraggedBlock?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
                ForEach(viewModel.visibleCategories()) { category in
                    CategoryBlockGroup(
                        category: category,
                        draggedBlock: $draggedBlock,
                        onBlockMoved: { fromCat, toCat in
                            viewModel.moveBlock(from: fromCat, to: toCat)
                        }
                    )
                }
            }
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
        let screenWidth = UIScreen.main.bounds.width
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

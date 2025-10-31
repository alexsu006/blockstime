//
//  StatsView.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: CategoryViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                // Stats for each category
                ForEach(viewModel.categories) { category in
                    StatItem(
                        label: category.name,
                        value: category.hours,
                        color: category.color.mainColor
                    )
                }

                // Remaining hours
                if viewModel.remainingHours() > 0 || viewModel.categories.isEmpty {
                    StatItem(
                        label: "未分配",
                        value: viewModel.remainingHours(),
                        color: Color(hex: "#666666")
                    )
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 20)
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.1f", value))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Text("h")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(6)
        .overlay(
            Rectangle()
                .fill(color)
                .frame(width: 4)
                .cornerRadius(2),
            alignment: .leading
        )
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(viewModel: CategoryViewModel())
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}

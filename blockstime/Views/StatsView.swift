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
                    // Use stable ID for better animation performance
                    .id(category.id)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                }

                // Remaining hours
                if viewModel.remainingHours() > 0 || viewModel.categories.isEmpty {
                    StatItem(
                        label: "未分配",
                        value: viewModel.remainingHours(),
                        color: Color(hex: "#666666")
                    )
                    .id("remaining")
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 20)
            .animation(.spring(response: Constants.springResponse,
                             dampingFraction: Constants.springDampingFraction,
                             blendDuration: Constants.springBlendDuration),
                      value: viewModel.categories.map { $0.hours })
        }
        .background(.ultraThinMaterial)
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
                AnimatedNumberText(
                    value: value,
                    format: "%.1f",
                    font: .system(size: 20, weight: .bold),
                    foregroundColor: .white
                )

                Text("h")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.thinMaterial)
        .cornerRadius(6)
        .overlay(
            Rectangle()
                .fill(color)
                .frame(width: 4)
                .cornerRadius(2)
                .allowsHitTesting(false),
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

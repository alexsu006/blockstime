//
//  ContentView.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CategoryViewModel()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#0a0a0a"),
                    Color(hex: "#1a1a1a")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                // Main content
                GeometryReader { geometry in
                    if geometry.size.width > 768 {
                        // iPad landscape layout
                        HStack(spacing: 20) {
                            // Left sidebar
                            CategoryListView(viewModel: viewModel)
                                .frame(width: Constants.sidebarWidth)

                            // Right panel
                            rightPanel
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    } else {
                        // iPhone portrait layout
                        VStack(spacing: 20) {
                            // Categories
                            CategoryListView(viewModel: viewModel)
                                .frame(maxHeight: 300)

                            // Blocks and stats
                            rightPanel
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("🧱")
                .font(.system(size: 32))
            Text("Lego 時間規劃器")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#FF0000"),
                            Color(hex: "#FFFF00"),
                            Color(hex: "#0000FF")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }

    private var rightPanel: some View {
        VStack(spacing: 0) {
            // Blocks grid
            BlocksGridView(viewModel: viewModel)

            // Stats panel
            StatsView(viewModel: viewModel)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1a1a1a"),
                    Color(hex: "#0f0f0f")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#333333"), lineWidth: 2)
                .allowsHitTesting(false)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

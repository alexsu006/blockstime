//
//  ContentView.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var selectedTab = 0

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

                // Tab indicator
                tabIndicator
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                // Main content with swipe
                GeometryReader { geometry in
                    if geometry.size.width > 768 {
                        // iPad landscape layout - show both panels
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
                        // iPhone portrait layout - swipeable tabs
                        TabView(selection: $selectedTab) {
                            // Settings page
                            CategoryListView(viewModel: viewModel)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                                .tag(0)

                            // Visualization page
                            rightPanel
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                                .tag(1)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var tabIndicator: some View {
        GeometryReader { geometry in
            if geometry.size.width <= 768 {
                HStack(spacing: 12) {
                    tabButton(title: "⚙️ 設定", index: 0)
                    tabButton(title: "📊 視覺化", index: 1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 44)
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = index
            }
        }) {
            Text(title)
                .font(.system(size: 15, weight: selectedTab == index ? .bold : .regular))
                .foregroundColor(selectedTab == index ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    selectedTab == index ?
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#333333"),
                                Color(hex: "#222222")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#1a1a1a"),
                                Color(hex: "#1a1a1a")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
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
        VStack(spacing: 15) {
            // Blocks grid
            BlocksGridView(viewModel: viewModel)
                .frame(maxHeight: .infinity)

            // Stats panel - fixed height at bottom
            StatsView(viewModel: viewModel)
                .frame(height: 100)
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

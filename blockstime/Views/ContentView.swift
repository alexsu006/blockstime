//
//  ContentView.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

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
                    .padding(.bottom, 20)

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
                    } else {
                        // iPhone portrait layout - swipeable tabs
                        TabView(selection: $selectedTab) {
                            // Categories page
                            CategoryListView(viewModel: viewModel)
                                .padding(.horizontal, 20)
                                .tag(0)

                            // Visualization page
                            rightPanel
                                .padding(.horizontal, 20)
                                .tag(1)
                        }
                        #if os(iOS)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        #endif
                    }
                }

                // Tab indicator at bottom
                tabIndicator
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var tabIndicator: some View {
        GeometryReader { geometry in
            if geometry.size.width <= 768 {
                HStack(spacing: 12) {
                    liquidGlassTabButton(title: "📦 項目", index: 0)
                    liquidGlassTabButton(title: "📊 視覺化", index: 1)
                }
                .padding(6)
                .background(
                    // Liquid glass container background
                    ZStack {
                        // Dark background with blur
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                            .background(.ultraThinMaterial)

                        // Subtle border glow
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
        .frame(height: 60)
    }

    private func liquidGlassTabButton(title: String, index: Int) -> some View {
        Button(action: {
            HapticManager.shared.tabSwitch()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            Text(title)
                .font(.system(size: 16, weight: selectedTab == index ? .semibold : .medium))
                .foregroundColor(selectedTab == index ? .white : Color.white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        if selectedTab == index {
                            // Active state - glowing glass effect
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.25),
                                            Color.white.opacity(0.15)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .background(.ultraThinMaterial)

                            // Glass shine effect
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.5),
                                            Color.white.opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )

                            // Soft glow
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .blur(radius: 8)
                        } else {
                            // Inactive state - transparent
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.clear)
                        }
                    }
                )
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("🧱")
                .font(.system(size: 32))
            Text("Blocks Time")
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

            Spacer()
        }
        .padding(.horizontal, 20)
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
        .background(.thickMaterial)
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

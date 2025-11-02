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
    @State private var showingRefreshAnimation = false
    @State private var showingDiagnostics = false

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
                        #if os(iOS)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        #endif
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
            HapticManager.shared.tabSwitch()
            withAnimation(.spring(response: Constants.springResponse,
                                dampingFraction: Constants.springDampingFraction,
                                blendDuration: Constants.springBlendDuration)) {
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

            Spacer()

            // Diagnostics button
            Button(action: {
                HapticManager.shared.buttonTap()
                showingDiagnostics.toggle()
            }) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color(hex: "#333333"))
                    )
            }
            .springyButton(scale: 0.9)
            .help("Widget 診斷")
            .popover(isPresented: $showingDiagnostics) {
                DiagnosticsView()
                    .frame(width: 600, height: 500)
            }

            // Manual widget refresh button
            Button(action: {
                HapticManager.shared.buttonTap()
                refreshWidget()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color(hex: "#333333"))
                    )
                    .rotationEffect(.degrees(showingRefreshAnimation ? 360 : 0))
            }
            .springyButton(scale: 0.9)
            .help("手動刷新 Widget")
        }
        .padding(.horizontal, 20)
    }

    private func refreshWidget() {
        print("🔄 手動刷新 Widget...")

        // Trigger rotation animation with smooth spring
        withAnimation(.spring(response: Constants.smoothSpringResponse,
                            dampingFraction: 0.8)) {
            showingRefreshAnimation = true
        }

        // Force save current categories
        viewModel.saveCategories()

        #if canImport(WidgetKit)
        if #available(iOS 14.0, macOS 11.0, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                WidgetCenter.shared.reloadAllTimelines()
                print("✅ Widget 刷新請求已發送")

                // Reset animation after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingRefreshAnimation = false
                    HapticManager.shared.refreshCompleted()
                }
            }
        }
        #endif
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

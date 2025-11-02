//
//  CategoryListView.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import SwiftUI

struct CategoryListView: View {
    @ObservedObject var viewModel: CategoryViewModel
    @State private var selectedCategoryForColor: Category?
    @State private var showColorPicker = false
    @FocusState private var focusedField: Bool
    @Namespace private var colorAnimation
    @State private var addButtonPressed = false

    var body: some View {
        VStack(spacing: 15) {
            // Title
            HStack(spacing: 8) {
                Text("📋")
                    .font(.system(size: 18))
                Text("時間項目")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .padding(.bottom, 5)

            // Categories list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        CategoryRow(
                            category: category,
                            maxAvailableHours: viewModel.maxAvailableHours(for: category),
                            onNameChange: { newName in
                                viewModel.updateCategoryName(category, newName: newName)
                            },
                            onHoursChange: { newHours in
                                viewModel.updateCategoryHours(category, newHours: newHours)
                            },
                            onColorTap: {
                                selectedCategoryForColor = category
                                showColorPicker = true
                            },
                            onRemove: {
                                withAnimation(.spring(response: Constants.springResponse,
                                                    dampingFraction: Constants.springDampingFraction)) {
                                    viewModel.removeCategory(category)
                                }
                            },
                            colorAnimation: colorAnimation
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                }
            }

            // Add button
            Button(action: {
                HapticManager.shared.itemAdded()
                addButtonPressed = true
                withAnimation(.spring(response: Constants.springResponse,
                                    dampingFraction: Constants.springDampingFraction)) {
                    viewModel.addCategory()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    addButtonPressed = false
                }
            }) {
                Text("+ 新增項目")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#00AA00"),
                                Color(hex: "#00FF00")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(8)
            }
            .bounceButton()
            .pulseEffect(isActive: addButtonPressed)
        }
        .padding(20)
        .background(.thickMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#333333"), lineWidth: 2)
                .allowsHitTesting(false)
        )
        .sheet(isPresented: $showColorPicker) {
            ColorPickerView(
                selectedColor: selectedCategoryForColor?.color ?? LegoColor.allColors[0],
                colorAnimation: colorAnimation,
                onColorSelected: { color in
                    if let category = selectedCategoryForColor {
                        viewModel.updateCategoryColor(category, colorId: color.id)
                    }
                    showColorPicker = false
                }
            )
            .presentationDetents([.height(200)])
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") {
                    focusedField = false
                }
                .font(.system(size: 16, weight: .semibold))
            }
        }
    }
}

struct ColorPickerView: View {
    let selectedColor: LegoColor
    let colorAnimation: Namespace.ID
    let onColorSelected: (LegoColor) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("選擇顏色")
                .font(.headline)
                .padding(.top)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                ForEach(LegoColor.allColors) { color in
                    Button(action: {
                        HapticManager.shared.colorPicked()
                        onColorSelected(color)
                    }) {
                        ZStack {
                            Color.clear
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            color.lightColor,
                                            color.mainColor
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .matchedGeometryEffect(id: "color-\(color.id)", in: colorAnimation)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            color.id == selectedColor.id ? Color.white : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                                .shadow(
                                    color: color.id == selectedColor.id ? .white.opacity(0.5) : .clear,
                                    radius: 5
                                )
                        }
                        .frame(width: 60, height: 60)
                    }
                    .glowButton(color: color.mainColor)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(.regularMaterial)
    }
}

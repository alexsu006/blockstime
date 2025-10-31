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

    var body: some View {
        VStack(spacing: 15) {
            // Title
            HStack(spacing: 8) {
                Text("📋")
                    .font(.system(size: 18))
                Text("時間類別")
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
                                viewModel.removeCategory(category)
                            }
                        )
                    }
                }
            }

            // Add button
            Button(action: {
                viewModel.addCategory()
            }) {
                Text("+ 新增類別")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
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
        }
        .padding(20)
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
        .sheet(isPresented: $showColorPicker) {
            ColorPickerView(
                selectedColor: selectedCategoryForColor?.color ?? LegoColor.allColors[0],
                onColorSelected: { color in
                    if let category = selectedCategoryForColor {
                        viewModel.updateCategoryColor(category, colorId: color.id)
                    }
                    showColorPicker = false
                }
            )
            .presentationDetents([.height(200)])
        }
    }
}

struct ColorPickerView: View {
    let selectedColor: LegoColor
    let onColorSelected: (LegoColor) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("選擇顏色")
                .font(.headline)
                .padding(.top)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 15) {
                ForEach(LegoColor.allColors) { color in
                    Button(action: {
                        onColorSelected(color)
                    }) {
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        color.id == selectedColor.id ? Color.white : Color.clear,
                                        lineWidth: 3
                                    )
                                    .allowsHitTesting(false)
                            )
                            .shadow(
                                color: color.id == selectedColor.id ? .white.opacity(0.5) : .clear,
                                radius: 5
                            )
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(Color(hex: "#1a1a1a"))
    }
}

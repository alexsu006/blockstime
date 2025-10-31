//
//  CategoryRow.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import SwiftUI

struct CategoryRow: View {
    let category: Category
    let maxAvailableHours: Double
    let onNameChange: (String) -> Void
    let onHoursChange: (Double) -> Void
    let onColorTap: () -> Void
    let onRemove: () -> Void

    @State private var sliderValue: Double

    init(category: Category,
         maxAvailableHours: Double,
         onNameChange: @escaping (String) -> Void,
         onHoursChange: @escaping (Double) -> Void,
         onColorTap: @escaping () -> Void,
         onRemove: @escaping () -> Void) {
        self.category = category
        self.maxAvailableHours = maxAvailableHours
        self.onNameChange = onNameChange
        self.onHoursChange = onHoursChange
        self.onColorTap = onColorTap
        self.onRemove = onRemove
        _sliderValue = State(initialValue: category.hours)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Header: Color + Name + Remove
            HStack(spacing: 8) {
                // Color button
                Button(action: onColorTap) {
                    ZStack {
                        Color.clear
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        category.color.lightColor,
                                        category.color.mainColor
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 24, height: 24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                    }
                    .frame(width: 44, height: 44)
                }
                .buttonStyle(PlainButtonStyle())

                // Name input
                TextField("類別名稱", text: .init(
                    get: { category.name },
                    set: { onNameChange($0) }
                ))
                .font(.system(size: 14, weight: .semibold))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 28)

                // Remove button
                Button(action: onRemove) {
                    ZStack {
                        Color.clear
                        Text("×")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Color(hex: "#AA0000"))
                            .cornerRadius(4)
                    }
                    .frame(width: 44, height: 44)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Hours slider with value display
            VStack(spacing: 8) {
                // Hours value display
                HStack {
                    Text("時數")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)

                    Spacer()

                    Text(String(format: "%.1f h", sliderValue))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#00D9A3"))
                }

                // Slider
                HStack(spacing: 8) {
                    Text("0")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .frame(width: 20)

                    Slider(value: $sliderValue, in: 0...maxAvailableHours, step: 0.5)
                        .accentColor(category.color.mainColor)
                        .onChange(of: sliderValue) { newValue in
                            onHoursChange(newValue)
                        }

                    Text(String(format: "%.0f", maxAvailableHours))
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .frame(width: 30)
                }
            }

            // Stats
            HStack {
                Text("\(category.blocksCount) 個積木")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Spacer()

                Text(String(format: "%.1f%%", category.percentage))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
        .padding(Constants.categoryItemPadding)
        .background(Color(hex: "#0f0f0f"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#333333"), lineWidth: 2)
                .allowsHitTesting(false)
        )
        .onChange(of: category.hours) { newValue in
            // Sync external changes to slider
            if abs(sliderValue - newValue) > 0.01 {
                sliderValue = newValue
            }
        }
    }
}

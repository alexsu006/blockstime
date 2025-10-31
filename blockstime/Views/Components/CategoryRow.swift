//
//  CategoryRow.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import SwiftUI

struct CategoryRow: View {
    let category: Category
    let onNameChange: (String) -> Void
    let onHoursChange: (Double) -> Void
    let onColorTap: () -> Void
    let onRemove: () -> Void

    @State private var hoursText: String = ""
    @FocusState private var isHoursFocused: Bool

    init(category: Category,
         onNameChange: @escaping (String) -> Void,
         onHoursChange: @escaping (Double) -> Void,
         onColorTap: @escaping () -> Void,
         onRemove: @escaping () -> Void) {
        self.category = category
        self.onNameChange = onNameChange
        self.onHoursChange = onHoursChange
        self.onColorTap = onColorTap
        self.onRemove = onRemove
        _hoursText = State(initialValue: String(format: "%.1f", category.hours))
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

            // Hours input with quick adjustment buttons
            HStack(spacing: 6) {
                // Decrease button
                Button(action: {
                    let newHours = max(0, category.hours - 1)
                    onHoursChange(newHours)
                    hoursText = String(format: "%.1f", newHours)
                }) {
                    ZStack {
                        Color.clear
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "#FF6B6B"))
                    }
                    .frame(width: 44, height: 44)
                }
                .buttonStyle(PlainButtonStyle())

                // Hours text field
                TextField("0.0", text: $hoursText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 32)
                    .multilineTextAlignment(.center)
                    .focused($isHoursFocused)
                    .onSubmit {
                        if let newHours = Double(hoursText) {
                            onHoursChange(newHours)
                        } else {
                            hoursText = String(format: "%.1f", category.hours)
                        }
                        isHoursFocused = false
                    }
                    .onChange(of: category.hours) { newValue in
                        if !isHoursFocused {
                            hoursText = String(format: "%.1f", newValue)
                        }
                    }

                Text("h")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
                    .frame(width: 20)

                // Increase button
                Button(action: {
                    let newHours = min(Constants.totalHours, category.hours + 1)
                    onHoursChange(newHours)
                    hoursText = String(format: "%.1f", newHours)
                }) {
                    ZStack {
                        Color.clear
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "#00D9A3"))
                    }
                    .frame(width: 44, height: 44)
                }
                .buttonStyle(PlainButtonStyle())
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
    }
}

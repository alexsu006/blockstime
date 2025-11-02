//
//  AnimatedNumberText.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-11-02.
//

import SwiftUI

/// 可動畫的數字文字組件
struct AnimatedNumberText: View {
    let value: Double
    let format: String
    var font: Font = .system(size: 20, weight: .bold)
    var foregroundColor: Color = .white

    var body: some View {
        Text(String(format: format, value))
            .font(font)
            .foregroundColor(foregroundColor)
            .modifier(AnimatableNumberModifier(number: value, format: format))
            .animation(.spring(response: Constants.springResponse,
                             dampingFraction: Constants.springDampingFraction),
                      value: value)
    }
}

/// 可動畫的數字 Modifier
struct AnimatableNumberModifier: AnimatableModifier {
    var number: Double
    let format: String

    var animatableData: Double {
        get { number }
        set { number = newValue }
    }

    func body(content: Content) -> some View {
        Text(String(format: format, number))
            .font(content.font ?? .body)
            .foregroundColor(content.foregroundColor ?? .primary)
    }
}

// MARK: - Preview

struct AnimatedNumberText_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var value: Double = 0

        var body: some View {
            VStack(spacing: 20) {
                AnimatedNumberText(
                    value: value,
                    format: "%.1f",
                    font: .system(size: 48, weight: .bold),
                    foregroundColor: .white
                )

                Button("增加") {
                    value += 10.5
                }
                .buttonStyle(.borderedProminent)

                Button("減少") {
                    value = max(0, value - 10.5)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color.black)
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .preferredColorScheme(.dark)
    }
}

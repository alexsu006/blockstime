//
//  CustomButtonStyles.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-11-02.
//

import SwiftUI

/// 彈性按壓按鈕樣式 - 提供 Apple 原生的按壓反饋
struct SpringyButtonStyle: ButtonStyle {
    var scaleEffect: CGFloat = 0.95

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleEffect : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// 發光按壓按鈕樣式 - 按下時會發光
struct GlowButtonStyle: ButtonStyle {
    var glowColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(
                color: configuration.isPressed ? glowColor.opacity(0.6) : .clear,
                radius: configuration.isPressed ? 10 : 0
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// 縮小按壓按鈕樣式 - 按下時縮小並降低不透明度
struct ShrinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// 彈跳按鈕樣式 - 按下後會有彈跳效果
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.3),
                value: configuration.isPressed
            )
    }
}

// MARK: - View Extension for Easy Access

extension View {
    /// 應用彈性按壓效果
    func springyButton(scale: CGFloat = 0.95) -> some View {
        self.buttonStyle(SpringyButtonStyle(scaleEffect: scale))
    }

    /// 應用發光按壓效果
    func glowButton(color: Color = .white) -> some View {
        self.buttonStyle(GlowButtonStyle(glowColor: color))
    }

    /// 應用縮小按壓效果
    func shrinkButton() -> some View {
        self.buttonStyle(ShrinkButtonStyle())
    }

    /// 應用彈跳效果
    func bounceButton() -> some View {
        self.buttonStyle(BounceButtonStyle())
    }
}

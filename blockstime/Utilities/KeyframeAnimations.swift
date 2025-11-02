//
//  KeyframeAnimations.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-11-02.
//

import SwiftUI

// MARK: - Pulse Animation

extension View {
    /// 添加脈衝動畫效果
    func pulseEffect(isActive: Bool) -> some View {
        self.modifier(PulseModifier(isActive: isActive))
    }
}

struct PulseModifier: ViewModifier {
    let isActive: Bool
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: isActive) { newValue in
                if newValue {
                    withAnimation(.easeOut(duration: 0.1)) {
                        scale = 0.9
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            scale = 1.1
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            scale = 1.0
                        }
                    }
                }
            }
    }
}

// MARK: - Shake Animation

extension View {
    /// 添加搖晃動畫效果
    func shakeEffect(trigger: Int) -> some View {
        self.modifier(ShakeModifier(shakes: trigger))
    }
}

struct ShakeModifier: ViewModifier {
    let shakes: Int
    @State private var offset: CGFloat = 0

    var animatableData: Int {
        get { shakes }
        set { }
    }

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: shakes) { _ in
                let animation = Animation.spring(response: 0.2, dampingFraction: 0.3)
                withAnimation(animation) {
                    offset = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(animation) {
                        offset = -10
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(animation) {
                        offset = 5
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(animation) {
                        offset = 0
                    }
                }
            }
    }
}

// MARK: - Pop Animation

extension View {
    /// 添加彈出動畫效果（用於新增元素）
    func popAnimation(isPresented: Bool) -> some View {
        self.modifier(PopModifier(isPresented: isPresented))
    }
}

struct PopModifier: ViewModifier {
    let isPresented: Bool
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                if isPresented {
                    // Stage 1: Quick scale to overshoot
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        scale = 1.2
                        opacity = 1.0
                    }
                    // Stage 2: Settle back to normal
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.7)) {
                            scale = 1.0
                        }
                    }
                }
            }
    }
}

// MARK: - Wiggle Animation

extension View {
    /// 添加擺動動畫效果
    func wiggleEffect(isActive: Bool) -> some View {
        self.modifier(WiggleModifier(isActive: isActive))
    }
}

struct WiggleModifier: ViewModifier {
    let isActive: Bool
    @State private var rotation: Double = 0

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onChange(of: isActive) { newValue in
                if newValue {
                    let wiggleAnimation = Animation.spring(response: 0.15, dampingFraction: 0.3)
                    withAnimation(wiggleAnimation) {
                        rotation = -5
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(wiggleAnimation) {
                            rotation = 5
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(wiggleAnimation) {
                            rotation = -3
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(wiggleAnimation) {
                            rotation = 0
                        }
                    }
                }
            }
    }
}

// MARK: - Success Feedback Animation

extension View {
    /// 成功反饋動畫（綠色閃爍 + 縮放）
    func successFeedback(trigger: Int) -> some View {
        self.modifier(SuccessFeedbackModifier(trigger: trigger))
    }
}

struct SuccessFeedbackModifier: ViewModifier {
    let trigger: Int
    @State private var scale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .shadow(color: .green.opacity(glowOpacity), radius: 20)
            .onChange(of: trigger) { _ in
                // Stage 1: Shrink
                withAnimation(.easeIn(duration: 0.08)) {
                    scale = 0.95
                }
                // Stage 2: Grow with glow
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        scale = 1.05
                        glowOpacity = 0.8
                    }
                }
                // Stage 3: Return to normal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        scale = 1.0
                        glowOpacity = 0
                    }
                }
            }
    }
}

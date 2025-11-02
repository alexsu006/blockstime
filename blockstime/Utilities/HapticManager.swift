//
//  HapticManager.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-11-02.
//

#if canImport(UIKit)
import UIKit
#endif

/// 觸覺反饋管理器 - 提供 Apple 原生的觸覺體驗
class HapticManager {
    static let shared = HapticManager()

    #if canImport(UIKit)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    #endif

    private init() {
        #if canImport(UIKit)
        // Prepare generators for better performance
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactSoft.prepare()
        impactRigid.prepare()
        selectionGenerator.prepare()
        notification.prepare()
        #endif
    }

    // MARK: - Impact Feedback

    /// 輕微衝擊 - 用於輕量級互動（如按鈕點擊）
    func light() {
        #if canImport(UIKit)
        impactLight.impactOccurred()
        impactLight.prepare()
        #endif
    }

    /// 中等衝擊 - 用於中等互動（如滑桿調整）
    func medium() {
        #if canImport(UIKit)
        impactMedium.impactOccurred()
        impactMedium.prepare()
        #endif
    }

    /// 重度衝擊 - 用於重要操作（如刪除、確認）
    func heavy() {
        #if canImport(UIKit)
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
        #endif
    }

    /// 柔軟衝擊 - 用於平滑的拖動操作
    func soft() {
        #if canImport(UIKit)
        impactSoft.impactOccurred()
        impactSoft.prepare()
        #endif
    }

    /// 剛性衝擊 - 用於精確的選擇操作
    func rigid() {
        #if canImport(UIKit)
        impactRigid.impactOccurred()
        impactRigid.prepare()
        #endif
    }

    // MARK: - Selection Feedback

    /// 選擇反饋 - 用於選項變更（如 Tab 切換、選擇器）
    func selection() {
        #if canImport(UIKit)
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
        #endif
    }

    // MARK: - Notification Feedback

    /// 成功通知 - 用於成功的操作（如保存成功）
    func success() {
        #if canImport(UIKit)
        notification.notificationOccurred(.success)
        notification.prepare()
        #endif
    }

    /// 警告通知 - 用於警告操作
    func warning() {
        #if canImport(UIKit)
        notification.notificationOccurred(.warning)
        notification.prepare()
        #endif
    }

    /// 錯誤通知 - 用於錯誤操作（如刪除失敗、驗證錯誤）
    func error() {
        #if canImport(UIKit)
        notification.notificationOccurred(.error)
        notification.prepare()
        #endif
    }

    // MARK: - Contextual Helpers

    /// Tab 切換反饋
    func tabSwitch() {
        selection()
    }

    /// 按鈕點擊反饋
    func buttonTap() {
        light()
    }

    /// 滑桿調整反饋
    func sliderChange() {
        soft()
    }

    /// 添加項目反饋
    func itemAdded() {
        medium()
    }

    /// 刪除項目反饋
    func itemDeleted() {
        heavy()
    }

    /// 顏色選擇反饋
    func colorPicked() {
        rigid()
    }

    /// 刷新完成反饋
    func refreshCompleted() {
        success()
    }
}

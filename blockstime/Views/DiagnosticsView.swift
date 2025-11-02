//
//  DiagnosticsView.swift
//  blockstime
//
//  Created for debugging App Group and Widget data sharing
//

import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

struct DiagnosticsView: View {
    @State private var diagnosticInfo: String = "正在檢查..."
    @State private var isHealthy: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: isHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(isHealthy ? .green : .orange)

                Text("Widget 診斷")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            Divider()
                .background(Color.gray.opacity(0.3))

            // Diagnostic information
            ScrollView {
                Text(diagnosticInfo)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
                .background(Color.gray.opacity(0.3))

            // Action buttons
            VStack(spacing: 12) {
                HStack {
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        runDiagnostics()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("重新檢查")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .springyButton()

                    Button(action: {
                        HapticManager.shared.buttonTap()
                        forceSyncCurrentData()
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("同步當前數據到 Widget")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .springyButton()

                    #if canImport(WidgetKit)
                    if #available(iOS 14.0, macOS 11.0, *) {
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            reloadWidgets()
                        }) {
                            HStack {
                                Image(systemName: "app.badge")
                                Text("刷新 Widget")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .springyButton()
                    }
                    #endif
                }
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#333333"), lineWidth: 2)
        )
        .onAppear {
            runDiagnostics()
        }
    }

    private func runDiagnostics() {
        var info = "=== Widget 數據共享診斷 ===\n\n"

        // Check App Group ID
        info += "📋 配置信息:\n"
        info += "  App Group ID: \(Constants.appGroupId)\n"
        info += "  Storage Key: \(Constants.storageKey)\n\n"

        // Check shared UserDefaults access
        info += "🔍 檢查 UserDefaults 訪問:\n"
        if let sharedDefaults = UserDefaults(suiteName: Constants.appGroupId) {
            info += "  ✅ 成功訪問 shared UserDefaults\n"

            // List all keys
            let allKeys = Array(sharedDefaults.dictionaryRepresentation().keys).sorted()
            info += "\n📋 共享存儲中的所有 keys (\(allKeys.count)):\n"
            if allKeys.isEmpty {
                info += "  ⚠️ 沒有找到任何 keys\n"
            } else {
                for key in allKeys.prefix(20) {
                    info += "  - \(key)\n"
                }
                if allKeys.count > 20 {
                    info += "  ... 還有 \(allKeys.count - 20) 個\n"
                }
            }

            // Check for our specific key
            info += "\n🔎 檢查目標數據 key '\(Constants.storageKey)':\n"
            if let data = sharedDefaults.data(forKey: Constants.storageKey) {
                info += "  ✅ 找到數據 (\(data.count) bytes)\n"

                // Try to decode
                do {
                    let categories = try JSONDecoder().decode([Category].self, from: data)
                    info += "  ✅ 數據解碼成功 (\(categories.count) 個分類)\n"
                    info += "\n📊 分類詳情:\n"
                    for category in categories {
                        let status = category.hours > 0 ? "✅ 會在 Widget 顯示" : "⚠️ 不會顯示 (0 小時)"
                        info += "  - \(category.name): \(category.hours)h (color: \(category.colorId)) [\(status)]\n"
                    }

                    let visibleCount = categories.filter({ $0.hours > 0 }).count
                    info += "\n👁️ Widget 顯示狀態: \(visibleCount)/\(categories.count) 個分類會被顯示\n"

                    if visibleCount < categories.count {
                        let hiddenCount = categories.count - visibleCount
                        info += "⚠️ 有 \(hiddenCount) 個分類因為小時數為 0 而不會在 Widget 顯示\n"
                    }

                    isHealthy = true
                } catch {
                    info += "  ❌ 數據解碼失敗: \(error.localizedDescription)\n"
                    isHealthy = false
                }
            } else {
                info += "  ❌ 沒有找到數據\n"
                info += "  💡 建議: 點擊「強制保存數據」按鈕\n"
                isHealthy = false
            }
        } else {
            info += "  ❌ 無法訪問 shared UserDefaults\n"
            info += "  💡 可能的原因:\n"
            info += "     1. App Group 未在 Xcode 項目中啟用\n"
            info += "     2. App Group ID 配置錯誤\n"
            info += "     3. App Group 未在 Apple Developer 賬號中配置\n"
            isHealthy = false
        }

        info += "\n" + String(repeating: "=", count: 40) + "\n"
        info += "診斷完成時間: \(Date().formatted())\n"

        diagnosticInfo = info
    }

    private func forceSyncCurrentData() {
        print("🔄 同步當前數據到 Widget...")

        // Load current categories from storage
        let currentCategories = LocalStorage.shared.loadCategories()
        print("📥 讀取到 \(currentCategories.count) 個分類")

        // Force save to shared storage
        LocalStorage.shared.saveCategories(currentCategories)
        print("💾 數據已強制保存到共享存儲")

        // Reload widgets
        #if canImport(WidgetKit)
        if #available(iOS 14.0, macOS 11.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
            print("🔄 Widget 已觸發刷新")
        }
        #endif

        // Refresh diagnostics after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            runDiagnostics()
        }
    }

    #if canImport(WidgetKit)
    @available(iOS 14.0, macOS 11.0, *)
    private func reloadWidgets() {
        print("🔄 觸發 Widget 刷新...")
        WidgetCenter.shared.reloadAllTimelines()
        print("✅ Widget 刷新請求已發送")
    }
    #endif
}

struct DiagnosticsView_Previews: PreviewProvider {
    static var previews: some View {
        DiagnosticsView()
            .frame(width: 600, height: 500)
            .preferredColorScheme(.dark)
    }
}

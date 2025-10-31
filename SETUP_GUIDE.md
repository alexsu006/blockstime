# BlocksTime - Xcode 專案設置指南

## 方法一：直接使用包含的 Xcode 專案 (最簡單，推薦)

本專案已包含完整的 Xcode 專案文件 (`BlocksTime.xcodeproj`)，可以直接開啟使用:

1. 克隆或下載專案
2. 雙擊 `BlocksTime.xcodeproj` 開啟專案
3. 選擇目標裝置並點擊 ▶️ Run

這個方法可以避免常見的建置錯誤，如 "Multiple commands produce" 錯誤。

---

## 方法二：使用 Xcode 手動創建專案 (進階)

### 步驟 1: 創建新專案

1. 打開 Xcode
2. 選擇 "File" > "New" > "Project..."
3. 選擇 "iOS" > "App"
4. 點擊 "Next"

### 步驟 2: 配置專案

在專案設置頁面填寫:
- **Product Name**: `BlocksTime`
- **Team**: 選擇你的開發團隊 (如果沒有可先選 None)
- **Organization Identifier**: `com.yourname` (自定義)
- **Bundle Identifier**: 自動生成 `com.yourname.BlocksTime`
- **Interface**: **SwiftUI** ⚠️ 重要!
- **Language**: **Swift**
- **Storage**: 不勾選 "Use Core Data"
- **Include Tests**: 可選

### 步驟 3: 整理文件結構

1. 刪除 Xcode 自動生成的文件:
   - `ContentView.swift` (我們會用自己的版本)

2. 創建資料夾結構 (在 Xcode 左側欄):
   - 右鍵點擊專案名稱 > "New Group"
   - 創建以下群組:
     ```
     BlocksTime/
     ├── Models
     ├── ViewModels
     ├── Views
     │   └── Components
     └── Utilities
     ```

### 步驟 4: 添加源碼文件

#### 方法 A: 拖拽添加 (簡單)
1. 打開 Finder，找到本專案的 `BlocksTime` 資料夾
2. 將對應的 `.swift` 文件拖拽到 Xcode 對應的群組中
3. 確保勾選 "Copy items if needed"

#### 方法 B: 手動創建
1. 右鍵點擊群組 > "New File..."
2. 選擇 "Swift File"
3. 複製貼上對應文件的程式碼

### 步驟 5: 文件清單

確保添加以下文件到對應位置:

**Models/**
- `Category.swift`
- `LegoColor.swift`

**ViewModels/**
- `CategoryViewModel.swift`

**Views/**
- `ContentView.swift`
- `CategoryListView.swift`
- `BlocksGridView.swift`
- `StatsView.swift`

**Views/Components/**
- `CategoryRow.swift`
- `LegoBlock.swift`

**Utilities/**
- `Constants.swift`
- `LocalStorage.swift`

**根目錄:**
- `BlocksTimeApp.swift`
- `Info.plist` (如果沒有自動生成)

### 步驟 6: 配置 Info.plist

1. 在專案導航器中找到 `Info.plist`
2. 確保包含以下設定:
   - Display Name: `BlocksTime`
   - Supported Interface Orientations: 包含 Portrait 和 Landscape

或直接使用本專案提供的 `Info.plist` 文件。

### 步驟 7: 運行專案

1. 選擇目標裝置:
   - iPhone 14 Pro (模擬器) 或
   - 你的真實設備
2. 點擊 ▶️ Run (或按 Cmd+R)
3. 等待編譯完成

---

## 方法二：使用命令列工具 (進階)

如果你熟悉 Xcode 命令列工具，可以使用以下腳本快速創建專案:

```bash
#!/bin/bash

# 創建專案目錄
PROJECT_NAME="BlocksTime"
BUNDLE_ID="com.yourname.BlocksTime"

# 使用 xcodegen 或手動創建 .xcodeproj
# (需要額外安裝工具)

echo "請使用方法一手動創建，更簡單可靠"
```

---

## 常見問題

### Q1: 編譯錯誤 "Cannot find type 'Category' in scope"
**解決方案**: 確保所有 Model 文件都已正確添加到專案中。

### Q2: 顏色顯示異常
**解決方案**: 檢查 `LegoColor.swift` 中的 Color extension 是否正確。

### Q3: 拖放功能無法使用
**解決方案**:
- 確保運行在 iOS 15+ 的裝置/模擬器上
- 檢查 `BlocksGridView.swift` 中的 `onDrag` 和 `onDrop` 實作

### Q4: "Multiple commands produce '/Users/.../DerivedData/...'" 錯誤
**問題**: 這是 Xcode 最常見的建置錯誤之一，通常發生在 Info.plist 被錯誤地添加到 "Copy Bundle Resources" 階段。

**解決方案**:
- **最佳方案**: 使用本專案包含的 `BlocksTime.xcodeproj` 文件，已正確配置
- **手動修復**:
  1. 在 Xcode 中選擇專案 → Target → Build Phases
  2. 展開 "Copy Bundle Resources"
  3. 找到 Info.plist 並移除它
  4. 清理建置資料夾 (Product → Clean Build Folder)
  5. 重新建置

### Q5: 資料無法儲存
**解決方案**:
- 檢查 `LocalStorage.swift` 實作
- 查看 Console 中的錯誤訊息
- 確保 `Constants.storageKey` 正確設定

### Q6: iPad 上顯示異常
**解決方案**:
- 檢查 `ContentView.swift` 中的 GeometryReader 佈局邏輯
- 確認 `Constants.sidebarWidth` 設定合理

---

## 驗證清單

運行前請檢查:

- [ ] 所有 .swift 文件都已添加到專案
- [ ] 文件位於正確的群組中
- [ ] 沒有編譯錯誤 (紅色標記)
- [ ] Info.plist 配置正確
- [ ] 選擇了正確的目標裝置
- [ ] Xcode 版本 >= 13.0
- [ ] 模擬器 iOS 版本 >= 15.0

---

## 進階配置

### 自定義積木大小
在 `Constants.swift` 中修改:
```swift
static let blockSize: CGFloat = 60  // 改成你喜歡的大小
```

### 修改總時數
```swift
static let totalHours: Double = 168.0  // 一週 = 168 小時
```

### 添加更多顏色
在 `LegoColor.swift` 中添加到 `allColors` 陣列:
```swift
LegoColor(id: "custom", main: "#RRGGBB", light: "#RRGGBB", dark: "#RRGGBB", glow: "#RRGGBB")
```

---

## 需要幫助?

如果遇到問題:
1. 檢查 Xcode Console 的錯誤訊息
2. 確保所有文件都正確添加
3. 參考本專案的 README.md
4. 重新創建專案並仔細跟隨步驟

---

**祝你開發順利! 🧱**

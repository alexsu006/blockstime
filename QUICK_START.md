# 🚀 快速開始 - 2 分鐘上手指南

## 最快開始方式 (推薦)

### 步驟 1: 克隆專案 (30 秒)
```bash
git clone <repository-url>
cd blockstime
```

### 步驟 2: 開啟專案 (30 秒)
雙擊 `BlocksTime.xcodeproj` 或在終端執行:
```bash
open BlocksTime.xcodeproj
```

### 步驟 3: 運行! (1 分鐘)
1. 等待 Xcode 載入專案
2. 選擇模擬器: iPhone 14 Pro (iOS 15+)
3. 點擊 ▶️ Run (或按 Cmd+R)

---

## 手動設置方式 (進階用戶)

如果你想從頭創建專案，可以參考以下步驟:

### 步驟 1: 開啟 Xcode
```
打開 Xcode → File → New → Project → iOS → App
```

配置:
- Product Name: `BlocksTime`
- Interface: **SwiftUI** ⚠️
- Language: Swift

### 步驟 2: 複製文件

#### 方式 A: 直接拖拽 (推薦)
1. 在 Finder 中打開 `BlocksTime` 資料夾
2. 全選所有 `.swift` 文件 (Cmd+A)
3. 拖拽到 Xcode 專案中
4. 勾選 "Copy items if needed"

#### 方式 B: 手動複製
```bash
cd /path/to/your/xcode/project
cp -r /path/to/this/repo/BlocksTime/* ./BlocksTime/
```

### 步驟 3: 整理文件

在 Xcode 中創建資料夾結構 (右鍵 → New Group):
```
Models/
  ├─ Category.swift
  └─ LegoColor.swift
ViewModels/
  └─ CategoryViewModel.swift
Views/
  ├─ ContentView.swift
  ├─ CategoryListView.swift
  ├─ BlocksGridView.swift
  ├─ StatsView.swift
  └─ Components/
      ├─ CategoryRow.swift
      └─ LegoBlock.swift
Utilities/
  ├─ Constants.swift
  └─ LocalStorage.swift
```

### 步驟 4: 運行
```
選擇模擬器: iPhone 14 Pro
點擊 ▶️ Run (或 Cmd+R)
```

---

## 檢查清單

運行前確認:
- [ ] Interface 選擇了 **SwiftUI** (不是 Storyboard)
- [ ] 所有 12 個 .swift 文件都已添加
- [ ] 沒有紅色錯誤標記
- [ ] 模擬器 iOS 版本 >= 15.0

---

## 常見問題 1 分鐘解決

### ❌ 編譯錯誤
**檢查**: 所有文件都添加了嗎？
```bash
# 應該有這些文件
BlocksTimeApp.swift
Category.swift
LegoColor.swift
CategoryViewModel.swift
ContentView.swift
... (共 12 個)
```

### ❌ 顏色不顯示
**解決**: 確保 `LegoColor.swift` 包含 Color extension

### ❌ 拖放無效
**解決**: 使用 iOS 15+ 模擬器/真機

---

## 文件清單 (12 個必要文件)

### 核心文件 (3)
- ✅ `BlocksTimeApp.swift` - App 入口
- ✅ `Category.swift` - 資料模型
- ✅ `LegoColor.swift` - 顏色系統

### ViewModel (1)
- ✅ `CategoryViewModel.swift` - 業務邏輯

### 主視圖 (4)
- ✅ `ContentView.swift` - 主畫面
- ✅ `CategoryListView.swift` - 左側面板
- ✅ `BlocksGridView.swift` - 積木區
- ✅ `StatsView.swift` - 統計面板

### 組件 (2)
- ✅ `CategoryRow.swift` - 類別項目
- ✅ `LegoBlock.swift` - 積木元件

### 工具 (2)
- ✅ `Constants.swift` - 常數
- ✅ `LocalStorage.swift` - 儲存管理

---

## 測試功能

運行後立即測試:
1. ✅ 點擊 "+ 新增類別"
2. ✅ 修改類別名稱
3. ✅ 調整時數 (看到積木變化)
4. ✅ 拖動積木到其他類別
5. ✅ 查看底部統計

---

## 下一步

### 自定義設置
編輯 `Constants.swift`:
```swift
static let totalHours: Double = 168.0  // 總時數
static let blockHours: Double = 1.0    // 每積木時數
static let blockSize: CGFloat = 60     // 積木大小
```

### 添加新顏色
編輯 `LegoColor.swift`:
```swift
LegoColor(id: "mycolor",
          main: "#RRGGBB",
          light: "#RRGGBB",
          dark: "#RRGGBB",
          glow: "#RRGGBB")
```

---

## 需要詳細說明？

- 📖 完整文檔: 查看 `README.md`
- 🔧 設置指南: 查看 `SETUP_GUIDE.md`
- 💡 功能說明: 查看各 `.swift` 文件的註解

---

**開始使用吧! 🧱**

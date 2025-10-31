# 🧱 Lego 時間規劃器 - iOS App

一個視覺化的週時間規劃工具，使用 Lego 積木的概念讓時間分配更直觀有趣。

## 功能特色

### ✅ 已完成功能 (第一、二階段)

#### 第一階段：基礎 UI 框架
- ✅ SwiftUI 專案架構
- ✅ 左側邊欄 (類別列表)
- ✅ 右側主區域 (積木顯示區)
- ✅ 深色主題設計
- ✅ 響應式佈局 (支援 iPhone/iPad)

#### 第二階段：資料管理和持久化
- ✅ Category 資料模型
- ✅ CategoryViewModel (MVVM 架構)
- ✅ 新增/編輯/刪除類別
- ✅ UserDefaults 本地儲存
- ✅ 預設資料初始化
- ✅ 拖放功能 (積木轉移)

## 專案結構

```
LegoTimePlanner/
├── Models/
│   ├── Category.swift          # 類別資料模型
│   └── LegoColor.swift          # 顏色定義和 Hex 轉換
├── ViewModels/
│   └── CategoryViewModel.swift  # 主要業務邏輯
├── Views/
│   ├── ContentView.swift        # 主視圖
│   ├── CategoryListView.swift   # 左側類別列表
│   ├── BlocksGridView.swift     # 積木網格顯示
│   ├── StatsView.swift          # 統計面板
│   └── Components/
│       ├── CategoryRow.swift    # 類別項目
│       └── LegoBlock.swift      # Lego 積木元件
├── Utilities/
│   ├── Constants.swift          # 常數定義
│   └── LocalStorage.swift       # 本地儲存管理
├── Info.plist
└── LegoTimePlannerApp.swift    # App 入口
```

## 技術棧

- **框架**: SwiftUI (iOS 15+)
- **架構**: MVVM (Model-View-ViewModel)
- **資料持久化**: UserDefaults
- **拖放**: SwiftUI Drag & Drop API
- **支援裝置**: iPhone, iPad
- **語言**: 繁體中文

## 使用方式

### 在 Xcode 中開啟專案

**簡易版 (推薦):**

1. 下載或克隆此專案:
   ```bash
   git clone <repository-url>
   cd blockstime
   ```

2. 雙擊 `LegoTimePlanner.xcodeproj` 開啟專案

3. 選擇目標裝置並運行:
   - 選擇 iPhone 或 iPad 模擬器 (iOS 15+)
   - 點擊 ▶️ Run (或按 Cmd+R)

**完整版 (手動設置):**

如果需要從頭創建專案，請參考 [SETUP_GUIDE.md](SETUP_GUIDE.md) 獲取詳細步驟。

### 功能使用

#### 管理時間類別
1. **新增類別**: 點擊 "+ 新增類別" 按鈕
2. **編輯名稱**: 直接在文字欄位中輸入
3. **設定時數**: 調整小時數 (每個積木 = 1 小時)
4. **更換顏色**: 點擊顏色方塊，選擇喜歡的顏色
5. **刪除類別**: 點擊 "×" 按鈕

#### 調整時間分配
- **方法 1**: 直接在左側調整小時數
- **方法 2**: 長按積木，拖曳到其他類別 (轉移 1 小時)

#### 查看統計
- 底部統計面板顯示各類別時數
- 自動計算未分配時間
- 百分比顯示時間佔比

## 核心功能說明

### 資料模型

```swift
struct Category {
    let id: String          // 唯一識別碼
    var name: String        // 類別名稱
    var hours: Double       // 分配時數
    var colorId: String     // 顏色 ID
}
```

### 常數設定

```swift
Constants.totalHours = 168.0    // 一週總時數
Constants.blockHours = 1.0      // 每個積木代表 1 小時
```

### 顏色系統

8 種預設 Lego 顏色:
- 紅色 (#E63946)
- 橙色 (#F77F00)
- 綠色 (#06A77D)
- 藍色 (#3A86FF)
- 紫色 (#8338EC)
- 深橙 (#FB5607)
- 粉紅 (#FF006E)
- 白色 (#F1FAEE)

## 開發注意事項

### 最低系統需求
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

### 已知限制
- 資料僅儲存在本地 (UserDefaults)
- 不支援 iCloud 同步
- 不支援多週規劃

## 未來規劃 (後續階段)

### 第三階段：進階功能
- [ ] 編輯積木標籤 (顯示具體任務)
- [ ] 週/日視圖切換
- [ ] 時間軸顯示
- [ ] 統計圖表

### 第四階段：資料同步
- [ ] iCloud 同步
- [ ] 匯出/匯入功能
- [ ] 歷史記錄

### 第五階段：使用者體驗
- [ ] 動畫效果優化
- [ ] 觸覺反饋
- [ ] 小工具 (Widget)
- [ ] Apple Watch 支援

## 授權

本專案為個人學習專案，僅供參考。

## 作者

由 Claude AI 協助開發
建立日期: 2025-10-30

# Widget 數據持久化故障排除指南

## 問題描述
Widget 顯示 "No saved data found, using defaults" 錯誤,無法從主 app 讀取數據。

## 原因分析
這通常是由於 **App Group 未正確配置** 導致的。Widget 和主 app 需要通過 App Group 共享數據。

## 解決方案

### 步驟 1: 使用內建診斷工具

1. 啟動主 app
2. 點擊右上角的 **聽診器圖標** (🩺) 打開診斷視圖
3. 查看診斷結果:
   - ✅ **如果顯示 "成功訪問 shared UserDefaults"**: App Group 配置正確,問題可能在其他地方
   - ❌ **如果顯示 "無法訪問 shared UserDefaults"**: 需要配置 App Group (見步驟 2)

### 步驟 2: 在 Xcode 中配置 App Group

#### 2.1 為主 app 啟用 App Group

1. 在 Xcode 中打開項目
2. 選擇主 target "blockstime"
3. 點擊 "Signing & Capabilities" 標籤
4. 點擊 "+ Capability" 按鈕
5. 選擇 "App Groups"
6. 在 App Groups 列表中,確保 **`group.alex.blockstime`** 已勾選
   - 如果沒有此選項,點擊 "+" 創建新的 App Group
   - 輸入: `group.alex.blockstime`

#### 2.2 為 Widget Extension 啟用 App Group

1. 選擇 Widget target "blockstimewidgeExtension"
2. 點擊 "Signing & Capabilities" 標籤
3. 點擊 "+ Capability" 按鈕
4. 選擇 "App Groups"
5. 在 App Groups 列表中,確保 **`group.alex.blockstime`** 已勾選

### 步驟 3: 在 Apple Developer 網站配置 App Group

> ⚠️ **重要**: 如果使用個人 Apple ID (免費開發者賬號),可能無法使用 App Groups 功能。建議升級到 Apple Developer Program ($99/年)。

1. 訪問 [Apple Developer](https://developer.apple.com)
2. 登入您的賬號
3. 導航到 "Certificates, Identifiers & Profiles"
4. 選擇 "Identifiers" > "App Groups"
5. 如果 `group.alex.blockstime` 不存在:
   - 點擊 "+" 創建新的 App Group
   - 輸入 Description: "Blocks Time Shared Data"
   - 輸入 Identifier: `group.alex.blockstime`
   - 點擊 "Continue" 和 "Register"

6. 確保 App ID 關聯了 App Group:
   - 導航到 "Identifiers" > "App IDs"
   - 選擇主 app 的 Bundle ID (`alex.blockstime`)
   - 在 "Capabilities" 中勾選 "App Groups"
   - 選擇 `group.alex.blockstime`
   - 保存
   - 對 Widget Extension 的 Bundle ID (`alex.blockstime.blockstimewidge`) 重複以上步驟

### 步驟 4: 驗證配置

1. 清理並重新構建項目:
   - 在 Xcode 中: `Product` > `Clean Build Folder` (⇧⌘K)
   - 重新構建: `Product` > `Build` (⌘B)

2. 卸載並重新安裝 app:
   - 從設備上完全刪除 app
   - 重新從 Xcode 安裝

3. 測試數據共享:
   - 啟動 app 並修改一些分類
   - 點擊右上角的刷新按鈕 (🔄)
   - 打開診斷視圖 (🩺) 檢查狀態
   - 查看 Widget 是否更新

### 步驟 5: 查看詳細日誌

現在 app 會輸出詳細的診斷日誌。在 Xcode 的 Console 中查找:

**主 app 日誌:**
```
💾 Saving 3 categories to shared storage...
   App Group ID: group.alex.blockstime
   Storage Key: legoTimePlannerCategories
✅ Main App: Successfully accessed shared UserDefaults
📦 Main App: Encoded data size: XXX bytes
💾 Main App: Data saved to key 'legoTimePlannerCategories'
✅ Main App: Data synchronized to shared storage successfully
✅ Main App: Verified data exists (XXX bytes)
📋 Main App: All keys in shared storage: ...
```

**Widget 日誌:**
```
🔍 Widget: Attempting to load categories...
   App Group ID: group.alex.blockstime
   Storage Key: legoTimePlannerCategories
✅ Widget: Successfully accessed shared UserDefaults
📋 Widget: Available keys in shared storage: ...
✅ Widget: Found data for key 'legoTimePlannerCategories' (XXX bytes)
✅ Widget: Successfully decoded 3 categories
```

## 常見問題

### Q: 為什麼我看到 "無法訪問 shared UserDefaults" 錯誤?
**A**: 這表示 App Group 未正確配置。請仔細按照步驟 2 和 3 操作。

### Q: 我使用的是免費的 Apple ID,可以使用 App Groups 嗎?
**A**: App Groups 功能可能在免費賬號上有限制。建議註冊 Apple Developer Program。

### Q: Widget 仍然顯示舊數據怎麼辦?
**A**:
1. 點擊 app 右上角的刷新按鈕 (🔄)
2. 或者長按 Widget > 選擇 "Remove Widget" > 重新添加 Widget

### Q: 如何確認 App Group 配置正確?
**A**: 使用診斷工具 (🩺 圖標):
- 應該顯示 "✅ 成功訪問 shared UserDefaults"
- 應該列出存儲的 keys
- 應該顯示解碼成功的分類數據

## 新增功能

### 1. 診斷視圖 (Diagnostics View)
- 點擊右上角的聽診器圖標 (🩺) 打開
- 顯示 App Group 配置狀態
- 顯示共享存儲中的所有 keys
- 顯示當前保存的分類數據
- 提供一鍵測試按鈕

### 2. 手動刷新按鈕
- 點擊右上角的刷新圖標 (🔄)
- 強制保存當前數據並刷新 Widget
- 有旋轉動畫反饋

### 3. 增強的日誌輸出
- 主 app 和 Widget 都會輸出詳細的診斷信息
- 包括 App Group ID、Storage Key、數據大小等
- 便於調試和問題排查

## 技術細節

### App Group 配置
- **App Group ID**: `group.alex.blockstime`
- **Storage Key**: `legoTimePlannerCategories`
- **Bundle IDs**:
  - 主 app: `alex.blockstime`
  - Widget: `alex.blockstime.blockstimewidge`

### 數據流程
1. 主 app 修改分類數據
2. CategoryViewModel 調用 `saveCategories()`
3. LocalStorage 將數據編碼為 JSON 並保存到 shared UserDefaults
4. 觸發 `WidgetCenter.shared.reloadAllTimelines()`
5. Widget 的 `getTimeline()` 被調用
6. WidgetDataProvider 從 shared UserDefaults 讀取數據
7. Widget 顯示更新後的數據

## 還需要幫助?

如果按照以上步驟仍然無法解決問題,請:
1. 檢查 Xcode Console 中的完整日誌
2. 確保兩個 target 的 entitlements 文件都包含 App Group
3. 嘗試使用診斷視圖中的 "強制保存數據" 按鈕
4. 完全卸載並重新安裝 app

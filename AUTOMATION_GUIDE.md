# 🤖 BlocksTime 自動化指南

本指南說明如何使用自動化腳本在你的 Mac 上拉取 GitHub 代碼並自動 build 專案。

---

## 📋 目錄

1. [快速開始](#快速開始)
2. [腳本說明](#腳本說明)
3. [使用方式](#使用方式)
4. [進階設定](#進階設定)
5. [常見問題](#常見問題)

---

## 🚀 快速開始

### 首次設置（只需執行一次）

如果你的 Mac 上還沒有這個專案：

```bash
# 1. 下載設置腳本
curl -O https://raw.githubusercontent.com/alexsu006/blockstime/main/setup-project.sh

# 2. 賦予執行權限
chmod +x setup-project.sh

# 3. 執行設置
./setup-project.sh
```

腳本會自動：
- ✅ 檢查 Git 和 Xcode 是否安裝
- ✅ Clone 專案到當前目錄
- ✅ 設置所有腳本的執行權限
- ✅ 詢問是否立即 build

### 日常使用

如果專案已經在你的 Mac 上：

```bash
# 進入專案目錄
cd blockstime

# 一鍵拉取並 build
./auto-build.sh
```

就這麼簡單！🎉

---

## 📜 腳本說明

### 1. `setup-project.sh` - 首次設置腳本

**用途**：首次從 GitHub clone 專案

**功能**：
- 檢查開發環境（Git、Xcode）
- Clone GitHub repo 到本地
- 設置腳本執行權限
- 可選：立即執行首次 build

**使用場景**：
- 新電腦首次下載專案
- 重新 clone 整個專案

**執行方式**：
```bash
./setup-project.sh
```

---

### 2. `auto-build.sh` - 自動化 Build 腳本 ⭐️

**用途**：拉取最新代碼並自動 build

**功能**：
- ✅ 檢查開發環境
- ✅ 從 GitHub 拉取最新代碼
- ✅ 自動處理本地未提交的變更（stash）
- ✅ 使用 xcodebuild 編譯專案
- ✅ 產生詳細的 build log
- ✅ 詢問是否開啟 Xcode IDE

**使用方式**：

```bash
# 基本用法：拉取並 build
./auto-build.sh

# Clean build（清除舊檔案後 build）
./auto-build.sh -c
```

**執行流程**：
```
1. 檢查環境 (Git, Xcode)
   ↓
2. 拉取最新代碼 (git pull)
   ↓
3. Build 專案 (xcodebuild)
   ↓
4. 詢問是否開啟 Xcode
   ↓
5. 顯示後續步驟建議
```

**Build Log 位置**：
```
build-logs/build-YYYYMMDD-HHMMSS.log
```

---

### 3. `run-simulator.sh` - 模擬器運行腳本

**用途**：Build 並在 iOS 模擬器中運行 App

**功能**：
- Build 專案
- 啟動指定的 iOS 模擬器
- 自動安裝並運行 App

**使用方式**：
```bash
./run-simulator.sh
```

**預設模擬器**：iPhone 15 Pro

修改模擬器：編輯腳本中的 `SIMULATOR` 變數

---

### 4. `run-tests.sh` - 測試執行腳本

**用途**：運行單元測試和 UI 測試

**功能**：
- 執行所有測試
- 產生測試報告
- 顯示測試結果

**使用方式**：
```bash
./run-tests.sh
```

**測試報告位置**：
```
test-reports/test-YYYYMMDD-HHMMSS.log
```

---

## 💡 使用方式

### 場景 1：每天開始工作時

```bash
cd blockstime
./auto-build.sh
```

這會：
1. 拉取團隊成員的最新提交
2. 自動 build 專案
3. 確保你的代碼是最新的

### 場景 2：想在模擬器中測試

```bash
./run-simulator.sh
```

或者在 Xcode 中：
```bash
./auto-build.sh
# 選擇 'y' 開啟 Xcode
# 然後按 Cmd+R 運行
```

### 場景 3：運行測試確保沒有問題

```bash
./run-tests.sh
```

### 場景 4：Clean Build（解決奇怪的編譯問題）

```bash
./auto-build.sh -c
```

### 場景 5：新電腦設置

```bash
# 1. 首次設置
./setup-project.sh

# 2. 後續每天使用
./auto-build.sh
```

---

## ⚙️ 進階設定

### 自定義模擬器

編輯腳本中的 `SIMULATOR` 變數：

```bash
# 在 auto-build.sh 或 run-simulator.sh 中
SIMULATOR="iPhone 14"           # iPhone 14
SIMULATOR="iPad Pro (12.9-inch)" # iPad
SIMULATOR="iPhone SE (3rd generation)" # iPhone SE
```

查看可用模擬器：
```bash
xcrun simctl list devices
```

### 自定義 Build 配置

編輯 `auto-build.sh` 中的配置：

```bash
BUILD_CONFIG="Debug"   # 開發用（預設）
BUILD_CONFIG="Release" # 正式發布用
```

### 設定定時自動拉取（可選）

使用 macOS 的 `cron` 或 `launchd` 定時執行：

**方式 1：使用 cron**

```bash
# 編輯 crontab
crontab -e

# 添加：每天早上 9:00 自動拉取並 build
0 9 * * * cd /path/to/blockstime && ./auto-build.sh
```

**方式 2：使用 launchd（推薦）**

創建 `~/Library/LaunchAgents/com.blockstime.autobuild.plist`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.blockstime.autobuild</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/blockstime/auto-build.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
```

載入定時任務：
```bash
launchctl load ~/Library/LaunchAgents/com.blockstime.autobuild.plist
```

---

## 🔧 環境需求

### 必須安裝：

1. **Git**
   - 檢查：`git --version`
   - 安裝：`xcode-select --install`

2. **Xcode Command Line Tools**
   - 檢查：`xcodebuild -version`
   - 安裝：`xcode-select --install`

3. **Xcode（完整版）**
   - 推薦：最新版本
   - 下載：Mac App Store

### 系統需求：

- macOS 10.15 或更新版本
- 至少 10GB 可用空間（用於 Xcode 和模擬器）

---

## ❓ 常見問題

### Q1: 執行腳本時出現「Permission denied」

**解決方式**：
```bash
chmod +x *.sh
```

### Q2: Build 失敗，提示找不到開發者工具

**解決方式**：
```bash
# 安裝 Xcode Command Line Tools
xcode-select --install

# 或設置 Xcode 路徑
sudo xcode-select --switch /Applications/Xcode.app
```

### Q3: Git pull 時出現衝突

腳本會自動 stash 你的本地變更，但如果出現衝突：

```bash
# 查看 stash 列表
git stash list

# 手動解決衝突後
git stash pop

# 或放棄本地變更
git stash drop
```

### Q4: 想要拉取特定分支

修改 `auto-build.sh`：

```bash
# 或手動切換分支
git checkout feature/my-branch
./auto-build.sh
```

### Q5: Build 成功但 App 無法運行

```bash
# 嘗試 clean build
./auto-build.sh -c

# 或重置模擬器
xcrun simctl erase all
```

### Q6: 如何查看 build log？

```bash
# Build log 存放在
ls -la build-logs/

# 查看最新的 log
tail -f build-logs/build-*.log
```

### Q7: 想要 build 到真機而不是模擬器

編輯 `auto-build.sh`，修改 destination：

```bash
# 原本（模擬器）
-destination "platform=iOS Simulator,name=$SIMULATOR"

# 改為（真機）
-destination "platform=iOS,name=我的 iPhone"
```

查看連接的設備：
```bash
xcrun xctrace list devices
```

---

## 🎯 工作流程建議

### 每日工作流程

```bash
# 1. 早上開始工作
cd blockstime
./auto-build.sh          # 拉取最新代碼並 build

# 2. 開發過程中
# ... 在 Xcode 中編碼 ...

# 3. 測試功能
./run-simulator.sh       # 在模擬器中測試

# 4. 提交前檢查
./run-tests.sh          # 確保測試通過

# 5. 提交代碼
git add .
git commit -m "feat: 新功能"
git push
```

### 遇到問題時

```bash
# 1. Clean build
./auto-build.sh -c

# 2. 還是不行？重新 clone
cd ..
./setup-project.sh

# 3. 檢查 Xcode 版本
xcodebuild -version
```

---

## 📚 更多資源

- **專案文檔**：[README.md](README.md)
- **快速開始**：[QUICK_START.md](QUICK_START.md)
- **設置指南**：[SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Widget 疑難排解**：[WIDGET_TROUBLESHOOTING.md](WIDGET_TROUBLESHOOTING.md)

---

## 🆘 需要幫助？

如果遇到問題：

1. 查看 build log：`build-logs/` 目錄
2. 檢查環境：`xcodebuild -version` 和 `git --version`
3. 嘗試 clean build：`./auto-build.sh -c`
4. 重新 clone 專案：`./setup-project.sh`

---

## 📝 腳本維護

### 更新腳本

當腳本更新時：

```bash
# 拉取最新版本
git pull

# 確保權限正確
chmod +x *.sh
```

### 自定義腳本

歡迎根據自己的需求修改腳本！所有腳本都有詳細註解。

---

**享受自動化帶來的便利！🚀**

如有任何問題或建議，歡迎提 Issue 或 PR。

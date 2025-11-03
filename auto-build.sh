#!/bin/bash

# ========================================
# BlocksTime 自動化 Build 腳本
# ========================================
# 功能：
# 1. 從 GitHub 拉取最新代碼
# 2. 使用 xcodebuild 自動 build 專案
# 3. 選擇性開啟 Xcode IDE
# ========================================

set -e  # 遇到錯誤立即停止

# 顏色定義（讓輸出更美觀）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 專案配置
PROJECT_NAME="blockstime"
XCODEPROJ_FILE="blockstime.xcodeproj"
SCHEME="blockstime"
BUILD_CONFIG="Debug"  # 可選：Debug 或 Release
SIMULATOR="iPhone 15 Pro"  # 預設模擬器

# 函數：印出帶顏色的訊息
print_step() {
    echo -e "${BLUE}[步驟]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_error() {
    echo -e "${RED}[錯誤]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

# 函數：檢查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 未安裝或不在 PATH 中"
        return 1
    fi
    return 0
}

# 函數：檢查環境
check_environment() {
    print_step "檢查開發環境..."

    # 檢查 Git
    if ! check_command git; then
        print_error "請先安裝 Git"
        exit 1
    fi
    print_success "Git 已安裝 ✓"

    # 檢查 Xcode Command Line Tools
    if ! check_command xcodebuild; then
        print_error "請先安裝 Xcode Command Line Tools"
        echo "執行命令：xcode-select --install"
        exit 1
    fi
    print_success "Xcode Command Line Tools 已安裝 ✓"

    # 顯示 Xcode 版本
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    echo "   使用 Xcode 版本：$XCODE_VERSION"
}

# 函數：拉取最新代碼
pull_latest_code() {
    print_step "拉取最新代碼..."

    # 檢查是否在 git repo 中
    if [ ! -d .git ]; then
        print_error "當前目錄不是 Git 倉庫"
        echo "請先 cd 到專案目錄，或使用 setup-project.sh 首次下載"
        exit 1
    fi

    # 顯示當前分支
    CURRENT_BRANCH=$(git branch --show-current)
    print_warning "當前分支：$CURRENT_BRANCH"

    # 儲存本地變更（如果有）
    if ! git diff-index --quiet HEAD --; then
        print_warning "發現本地未提交的變更，正在暫存..."
        git stash push -m "Auto-stash before pull $(date '+%Y-%m-%d %H:%M:%S')"
        STASHED=true
    else
        STASHED=false
    fi

    # 拉取最新代碼
    echo "正在從遠端拉取..."
    if git pull origin "$CURRENT_BRANCH" --rebase; then
        print_success "代碼已更新到最新版本 ✓"
    else
        print_error "拉取代碼失敗"
        exit 1
    fi

    # 恢復暫存的變更
    if [ "$STASHED" = true ]; then
        print_warning "正在恢復本地變更..."
        git stash pop
    fi

    # 顯示最新的提交
    echo ""
    echo "最新提交："
    git log -1 --oneline --decorate
    echo ""
}

# 函數：清理舊的 build
clean_build() {
    print_step "清理舊的 build 檔案..."

    if xcodebuild clean \
        -project "$XCODEPROJ_FILE" \
        -scheme "$SCHEME" \
        -configuration "$BUILD_CONFIG" &> /dev/null; then
        print_success "清理完成 ✓"
    else
        print_warning "清理失敗，繼續執行..."
    fi
}

# 函數：Build 專案
build_project() {
    print_step "開始 Build 專案..."
    echo "配置：$BUILD_CONFIG"
    echo "目標：iOS Simulator"
    echo ""

    # 創建 build log 目錄
    mkdir -p build-logs
    BUILD_LOG="build-logs/build-$(date '+%Y%m%d-%H%M%S').log"

    # 執行 build
    if xcodebuild \
        -project "$XCODEPROJ_FILE" \
        -scheme "$SCHEME" \
        -configuration "$BUILD_CONFIG" \
        -destination "platform=iOS Simulator,name=$SIMULATOR" \
        -allowProvisioningUpdates \
        build 2>&1 | tee "$BUILD_LOG"; then

        echo ""
        print_success "=========================================="
        print_success "  Build 成功完成！🎉"
        print_success "=========================================="
        echo ""
        echo "Build log 已儲存至：$BUILD_LOG"
        return 0
    else
        echo ""
        print_error "=========================================="
        print_error "  Build 失敗 ❌"
        print_error "=========================================="
        echo ""
        echo "詳細錯誤請查看：$BUILD_LOG"
        return 1
    fi
}

# 函數：詢問是否開啟 Xcode
open_xcode() {
    echo ""
    read -p "是否要開啟 Xcode IDE？(y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "正在開啟 Xcode..."
        open "$XCODEPROJ_FILE"
        print_success "Xcode 已開啟 ✓"
    fi
}

# 函數：顯示建議的下一步
show_next_steps() {
    echo ""
    echo "=========================================="
    echo "  下一步建議："
    echo "=========================================="
    echo "1. 在 Xcode 中按 Cmd+R 運行專案"
    echo "2. 或使用命令運行："
    echo "   ./run-simulator.sh"
    echo ""
    echo "其他可用腳本："
    echo "   ./auto-build.sh         - 重新 build"
    echo "   ./run-tests.sh          - 運行測試"
    echo "   ./setup-project.sh      - 首次設置專案"
    echo ""
}

# ========================================
# 主程式流程
# ========================================

main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   BlocksTime 自動化 Build 工具        ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    # 步驟 1: 檢查環境
    check_environment
    echo ""

    # 步驟 2: 拉取最新代碼
    pull_latest_code

    # 步驟 3: 清理（可選）
    if [ "${CLEAN_BUILD:-false}" = true ]; then
        clean_build
        echo ""
    fi

    # 步驟 4: Build 專案
    if build_project; then
        BUILD_SUCCESS=true
    else
        BUILD_SUCCESS=false
    fi

    echo ""

    # 步驟 5: 詢問是否開啟 Xcode
    if [ "$BUILD_SUCCESS" = true ]; then
        open_xcode
        show_next_steps
    else
        print_error "由於 build 失敗，請檢查錯誤訊息後再試"
        exit 1
    fi
}

# 參數處理
while getopts "c" opt; do
    case $opt in
        c)
            CLEAN_BUILD=true
            ;;
        \?)
            echo "用法: $0 [-c]"
            echo "  -c: 執行 clean build"
            exit 1
            ;;
    esac
done

# 執行主程式
main

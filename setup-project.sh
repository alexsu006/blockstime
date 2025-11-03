#!/bin/bash

# ========================================
# BlocksTime 專案首次設置腳本
# ========================================
# 用途：首次從 GitHub clone 專案到 Mac
# 使用方式：
#   curl -O https://raw.githubusercontent.com/YOUR_USERNAME/blockstime/main/setup-project.sh
#   chmod +x setup-project.sh
#   ./setup-project.sh
# ========================================

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 專案配置
REPO_URL="https://github.com/alexsu006/blockstime.git"  # 修改為你的 repo URL
PROJECT_DIR="blockstime"
DEFAULT_BRANCH="main"  # 或 master，根據你的預設分支

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

# 檢查 Git 是否安裝
check_git() {
    print_step "檢查 Git 安裝狀態..."

    if ! command -v git &> /dev/null; then
        print_error "Git 未安裝"
        echo ""
        echo "請先安裝 Git："
        echo "  方法 1: 訪問 https://git-scm.com/download/mac"
        echo "  方法 2: 使用 Homebrew：brew install git"
        echo "  方法 3: 安裝 Xcode Command Line Tools：xcode-select --install"
        exit 1
    fi

    GIT_VERSION=$(git --version)
    print_success "Git 已安裝：$GIT_VERSION ✓"
}

# 檢查 Xcode
check_xcode() {
    print_step "檢查 Xcode 安裝狀態..."

    if ! command -v xcodebuild &> /dev/null; then
        print_warning "Xcode Command Line Tools 未安裝"
        echo ""
        read -p "是否現在安裝 Xcode Command Line Tools？(y/n) " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            xcode-select --install
            echo "請在彈出視窗中完成安裝，然後重新運行此腳本"
            exit 0
        else
            print_warning "跳過 Xcode 安裝，但後續 build 將會失敗"
        fi
    else
        XCODE_VERSION=$(xcodebuild -version | head -n 1)
        print_success "Xcode 已安裝：$XCODE_VERSION ✓"
    fi
}

# Clone 專案
clone_project() {
    print_step "從 GitHub clone 專案..."

    # 檢查目錄是否已存在
    if [ -d "$PROJECT_DIR" ]; then
        print_warning "專案目錄已存在：$PROJECT_DIR"
        echo ""
        read -p "是否要刪除現有目錄並重新 clone？(y/n) " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_step "刪除現有目錄..."
            rm -rf "$PROJECT_DIR"
        else
            print_error "取消操作"
            exit 1
        fi
    fi

    # Clone 專案
    echo "正在 clone：$REPO_URL"
    if git clone "$REPO_URL" "$PROJECT_DIR"; then
        print_success "專案 clone 完成 ✓"
    else
        print_error "Clone 失敗，請檢查網路連接和 repo URL"
        exit 1
    fi

    # 進入專案目錄
    cd "$PROJECT_DIR"

    # 顯示專案資訊
    echo ""
    echo "專案資訊："
    echo "  位置：$(pwd)"
    echo "  分支：$(git branch --show-current)"
    echo "  最新提交：$(git log -1 --oneline)"
    echo ""
}

# 設置腳本權限
setup_scripts() {
    print_step "設置腳本執行權限..."

    # 列出所有 .sh 腳本
    SCRIPTS=$(find . -maxdepth 1 -name "*.sh" -type f)

    if [ -z "$SCRIPTS" ]; then
        print_warning "未找到任何 .sh 腳本"
        return
    fi

    # 設置權限
    for script in $SCRIPTS; do
        chmod +x "$script"
        echo "  ✓ $(basename $script)"
    done

    print_success "腳本權限設置完成 ✓"
}

# 首次 build
initial_build() {
    echo ""
    read -p "是否要立即執行首次 build？(y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "執行首次 build..."
        echo ""

        if [ -f "auto-build.sh" ]; then
            ./auto-build.sh
        else
            print_warning "找不到 auto-build.sh 腳本"
            echo "請手動開啟 Xcode 並 build 專案"
        fi
    else
        print_warning "跳過首次 build"
    fi
}

# 顯示後續步驟
show_next_steps() {
    echo ""
    echo "=========================================="
    echo "  🎉 設置完成！"
    echo "=========================================="
    echo ""
    echo "專案已 clone 到："
    echo "  $(pwd)"
    echo ""
    echo "下一步："
    echo "  1. cd $PROJECT_DIR"
    echo "  2. ./auto-build.sh          # 拉取最新代碼並 build"
    echo ""
    echo "其他可用命令："
    echo "  ./run-simulator.sh          # 在模擬器中運行"
    echo "  ./run-tests.sh              # 運行測試"
    echo "  open blockstime.xcodeproj   # 開啟 Xcode"
    echo ""
}

# 主程式
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   BlocksTime 專案設置工具             ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    # 步驟 1: 檢查 Git
    check_git
    echo ""

    # 步驟 2: 檢查 Xcode
    check_xcode
    echo ""

    # 步驟 3: Clone 專案
    clone_project

    # 步驟 4: 設置腳本
    setup_scripts
    echo ""

    # 步驟 5: 首次 build（可選）
    initial_build

    # 顯示後續步驟
    show_next_steps
}

# 執行主程式
main

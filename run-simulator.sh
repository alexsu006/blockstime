#!/bin/bash

# ========================================
# 在模擬器中運行 BlocksTime App
# ========================================

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 專案配置
XCODEPROJ_FILE="blockstime.xcodeproj"
SCHEME="blockstime"
SIMULATOR="iPhone 15 Pro"

print_step() {
    echo -e "${BLUE}[步驟]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_error() {
    echo -e "${RED}[錯誤]${NC} $1"
}

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   運行 BlocksTime 在模擬器             ║"
echo "╚════════════════════════════════════════╝"
echo ""

print_step "啟動模擬器並運行 App..."
echo "目標模擬器：$SIMULATOR"
echo ""

# Build 並運行
if xcodebuild \
    -project "$XCODEPROJ_FILE" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -allowProvisioningUpdates \
    build; then

    print_success "Build 完成 ✓"
    echo ""
    print_step "正在啟動 App..."

    # 運行 App
    xcodebuild \
        -project "$XCODEPROJ_FILE" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,name=$SIMULATOR" \
        run

    print_success "App 已在模擬器中啟動 🚀"
else
    print_error "Build 失敗"
    exit 1
fi

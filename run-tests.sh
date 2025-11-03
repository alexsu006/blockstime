#!/bin/bash

# ========================================
# 運行 BlocksTime 測試
# ========================================

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   BlocksTime 測試執行工具              ║"
echo "╚════════════════════════════════════════╝"
echo ""

print_step "準備運行測試..."
echo "目標：$SIMULATOR"
echo ""

# 創建測試報告目錄
mkdir -p test-reports

# 運行測試
TEST_LOG="test-reports/test-$(date '+%Y%m%d-%H%M%S').log"

print_step "執行單元測試..."

if xcodebuild test \
    -project "$XCODEPROJ_FILE" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -allowProvisioningUpdates \
    2>&1 | tee "$TEST_LOG"; then

    echo ""
    print_success "=========================================="
    print_success "  所有測試通過！✅"
    print_success "=========================================="
    echo ""
else
    echo ""
    print_error "=========================================="
    print_error "  測試失敗 ❌"
    print_error "=========================================="
    echo ""
    echo "詳細測試結果請查看：$TEST_LOG"
    exit 1
fi

echo "測試報告已儲存至：$TEST_LOG"
echo ""

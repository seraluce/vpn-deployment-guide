#!/bin/bash

# VPN部署指南 - Wiki自动部署脚本

set -e

# 配置
WIKI_REPO="https://github.com/seraluce/vpn-deployment-guide.wiki.git"
WIKI_DIR="/tmp/vpn-wiki-$(date +%s)"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)/wiki"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    if ! command -v git &> /dev/null; then
        log_error "Git未安装"
        exit 1
    fi
    
    if [ ! -d "$SOURCE_DIR" ]; then
        log_error "源目录不存在: $SOURCE_DIR"
        exit 1
    fi
    
    log_info "依赖检查完成"
}

# 克隆Wiki仓库
clone_wiki() {
    log_info "克隆Wiki仓库..."
    
    if [ -d "$WIKI_DIR" ]; then
        rm -rf "$WIKI_DIR"
    fi
    
    git clone "$WIKI_REPO" "$WIKI_DIR"
    log_info "Wiki仓库克隆完成"
}

# 复制文档
copy_documents() {
    log_info "复制文档..."
    
    # 复制所有markdown文件
    find "$SOURCE_DIR" -name "*.md" -type f | while read file; do
        filename=$(basename "$file")
        cp "$file" "$WIKI_DIR/$filename"
        log_info "复制: $filename"
    done
    
    log_info "文档复制完成"
}

# 提交并推送
commit_and_push() {
    log_info "提交并推送更改..."
    
    cd "$WIKI_DIR"
    
    # 添加所有文件
    git add .
    
    # 检查是否有更改
    if git diff --cached --quiet; then
        log_warn "没有新的更改"
        return
    fi
    
    # 提交
    git commit -m "自动更新文档 $(date +%Y-%m-%d %H:%M:%S)"
    
    # 推送
    git push
    
    log_info "文档推送完成"
}

# 清理临时文件
cleanup() {
    log_info "清理临时文件..."
    if [ -d "$WIKI_DIR" ]; then
        rm -rf "$WIKI_DIR"
    fi
    log_info "清理完成"
}

# 显示帮助
show_help() {
    echo "VPN部署指南 - Wiki自动部署脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -s, --source   指定源目录 (默认: ./wiki)"
    echo "  -d, --dest     指定目标仓库地址"
    echo "  -n, --dry-run  模拟运行，不实际提交"
    echo "  -v, --verbose  显示详细输出"
    echo ""
    echo "示例:"
    echo "  $0                    # 使用默认配置"
    echo "  $0 -s /path/to/wiki   # 指定源目录"
    echo "  $0 -n                 # 模拟运行"
    echo ""
}

# 主函数
main() {
    # 解析参数
    DRY_RUN=false
    VERBOSE=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--source)
                SOURCE_DIR="$2"
                shift 2
                ;;
            -d|--dest)
                WIKI_REPO="$2"
                shift 2
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查源目录
    if [ ! -d "$SOURCE_DIR" ]; then
        log_error "源目录不存在: $SOURCE_DIR"
        exit 1
    fi
    
    # 执行部署
    log_info "开始部署Wiki文档..."
    log_info "源目录: $SOURCE_DIR"
    log_info "目标仓库: $WIKI_REPO"
    
    check_dependencies
    clone_wiki
    copy_documents
    
    if [ "$DRY_RUN" = false ]; then
        commit_and_push
    else
        log_info "模拟运行，跳过提交"
    fi
    
    cleanup
    
    log_info "部署完成！"
    log_info "访问Wiki: https://github.com/seraluce/vpn-deployment-guide/wiki"
}

# 执行主函数
main "$@"
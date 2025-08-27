#!/bin/bash
# ========================================
# VPS 管理菜单脚本
# ========================================

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用 root 权限运行脚本${RESET}"
    exit 1
fi

# 安装必备工具
install_tool() {
    if ! command -v "$1" &> /dev/null; then
        apt-get update
        apt-get install -y "$1"
    fi
}

# ========================================
# 功能函数
# ========================================

swap_manage() {
    echo -e "${YELLOW}开设虚拟内存(Swap)${RESET}"
    curl -L https://raw.githubusercontent.com/spiritLHLS/addswap/main/addswap.sh -o addswap.sh
    chmod +x addswap.sh
    bash addswap.sh
}

docker_install() {
    echo -e "${YELLOW}开始安装 Docker${RESET}"
    curl -L https://raw.githubusercontent.com/oneclickvirt/docker/main/scripts/dockerinstall.sh -o dockerinstall.sh
    chmod +x dockerinstall.sh
    bash dockerinstall.sh
}

docker_one() {
    echo -e "${YELLOW}检测磁盘限制${RESET}"
    curl -L https://raw.githubusercontent.com/oneclickvirt/docker/refs/heads/main/extra_scripts/disk_test.sh -o disk_test.sh
    chmod +x disk_test.sh 
    bash disk_test.sh
}

docker_batch() {
    bash <(curl -sL https://raw.githubusercontent.com/Polarisiu/toy/main/kdocker.sh)
}

docker_cleanup() {
    echo -e "${YELLOW}删除 ndpresponder Docker 容器和镜像${RESET}"
    docker ps -a --format '{{.Names}}' | grep -vE '^ndpresponder' | xargs -r docker rm -f
    docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | grep -v 'ndpresponder' | awk '{print $2}' | xargs -r docker rmi
    rm -rf dclog test
    ls
    echo -e "${GREEN}清理完成${RESET}"
}


# ========================================
# 主菜单
# ========================================

while true; do
    clear
    echo -e "${CYAN}================= VPS 管理菜单 =================${RESET}"
    echo -e "${GREEN}1. 开设/移除 Swap${RESET}"
    echo -e "${GREEN}2. 环境组件安装${RESET}"
    echo -e "${GREEN}3. 检测磁盘限制${RESET}"
    echo -e "${GREEN}4. 开设 Docker 小鸡${RESET}"
    echo -e "${GREEN}5. 删除所有容器镜像${RESET}"
    echo -e "${GREEN}0. 退出脚本${RESET}"
    echo -e "${CYAN}===============================================${RESET}"

    read -p "请输入你的选择 [0-5]: " choice

    case "$choice" in
        1) swap_manage ;;
        2) docker_install ;;
        3) docker_one ;;
        4) docker_batch ;;
        5) docker_cleanup ;;
        0) echo -e "${GREEN}退出脚本${RESET}"; exit 0 ;;
        *) echo -e "${RED}输入错误，请输入 0-6${RESET}"; sleep 2 ;;
    esac

    echo -e "${CYAN}按回车键返回主菜单...${RESET}"
    read
done

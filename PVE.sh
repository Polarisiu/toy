#!/bin/bash

# ================== 颜色定义 ==================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ================== 安全提示 ==================
echo -e "${YELLOW}⚠️ 警告！安装 Proxmox VE 会做以下操作：${RESET}"
echo -e "${GREEN}1. 修改系统APT源为PVE仓库${RESET}"
echo -e "${GREEN}2. 安装KVM/QEMU/LXC等虚拟化核心组件${RESET}"
echo -e "${GREEN}3. 修改网络配置（可能覆盖原有网络）${RESET}"
echo -e "${GREEN}4. 可能需要重启系统${RESET}"

echo -e "${RED}⚠️ 建议在干净的 Debian/Ubuntu 系统上执行，并备份重要数据${RESET}"

# ================== 用户确认 ==================
read -p "是否继续安装 PVE？输入 y 确认: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${CYAN}已取消安装${RESET}"
    exit 0
fi

# ================== 下载并执行安装脚本 ==================
GH_PROXY=${GH_PROXY:-""}  # 可通过环境变量设置 GitHub 代理
INSTALL_SCRIPT="install_pve.sh"

echo -e "${GREEN}开始下载 PVE 安装脚本...${RESET}"
curl -L ${GH_PROXY}https://raw.githubusercontent.com/oneclickvirt/pve/main/scripts/install_pve.sh -o $INSTALL_SCRIPT

if [[ ! -f "$INSTALL_SCRIPT" ]]; then
    echo -e "${RED}下载失败，请检查网络或代理${RESET}"
    exit 1
fi

chmod +x $INSTALL_SCRIPT
echo -e "${GREEN}执行安装脚本...${RESET}"
bash $INSTALL_SCRIPT

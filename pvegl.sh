#!/bin/bash

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

menu() {
    clear
    echo -e "${GREEN}=== PVE 管理菜单 ===${RESET}"
    echo -e "${GREEN}1) 添加 SWAP${RESET}"
    echo -e "${GREEN}2) 检测环境${RESET}"
    echo -e "${GREEN}3) PVE 主体安装${RESET}"
    echo -e "${GREEN}4) 预配置环境${RESET}"
    echo -e "${GREEN}5) 自动配置宿主机网关${RESET}"
    echo -e "${GREEN}6) 开设 KVM 小鸡${RESET}"
    echo -e "${GREEN}7) 开设 LXC 小鸡${RESET}"
    echo -e "${GREEN}0) 退出${RESET}"
    echo
    read -p $'\033[32m请选择操作: \033[0m' choice
    case $choice in
        1)
            echo -e "${GREEN}正在添加 SWAP...${RESET}"
            curl -L https://raw.githubusercontent.com/spiritLHLS/addswap/main/addswap.sh -o addswap.sh
            chmod +x addswap.sh
            bash addswap.sh
            pause
            ;;
        2)
            echo -e "${GREEN}正在检测环境...${RESET}"
            bash <(wget -qO- --no-check-certificate https://raw.githubusercontent.com/oneclickvirt/pve/main/scripts/check_kernal.sh)
            pause
            ;;
        3)
            echo -e "${GREEN}正在安装 PVE 主体...${RESET}"
            curl -L https://raw.githubusercontent.com/oneclickvirt/pve/main/scripts/install_pve.sh -o install_pve.sh
            chmod +x install_pve.sh
            bash install_pve.sh
            pause
            ;;
        4)
            echo -e "${GREEN}正在预配置环境...${RESET}"
            bash <(wget -qO- --no-check-certificate https://raw.githubusercontent.com/oneclickvirt/pve/main/scripts/build_backend.sh)
            pause
            ;;
        5)
            echo -e "${GREEN}正在自动配置宿主机网关...${RESET}"
            bash <(wget -qO- --no-check-certificate https://raw.githubusercontent.com/oneclickvirt/pve/main/scripts/build_nat_network.sh)
            pause
            ;;
        6)
            echo -e "${GREEN}正在开设 KVM 小鸡...${RESET}"
            bash <(curl -sL https://raw.githubusercontent.com/Polarisiu/toy/main/pvekvm.sh)
            pause
            ;;
        7)
            echo -e "${GREEN}正在开设 LXC 小鸡...${RESET}"
            bash <(curl -sL https://raw.githubusercontent.com/Polarisiu/toy/main/pvelxc.sh)
            pause
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "${RED}无效选择，请重新输入${RESET}"
            sleep 1
            menu
            ;;
    esac
}

pause() {
    read -p $'\033[32m按回车键返回菜单...\033[0m'
    menu
}

menu

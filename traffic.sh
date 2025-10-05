#!/bin/bash

# ================== 颜色定义 ==================
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
NC="\033[0m"

# ================== 菜单函数 ==================
show_menu() {
    clear
    echo -e "${GREEN}==== TrafficCop流量监控管理 =====${NC}"
    echo -e "${GREEN}1) 安装${NC}"
    echo -e "${GREEN}2) 卸载${NC}"
    echo -e "${GREEN}0) 退出${NC}"
    echo -n -e "${GREEN}请输入选项: ${NC}"
}

# ================== 功能函数 ==================
install_script() {
    echo -e "${GREEN}正在一键安装 TrafficCop 脚本...${NC}"
    bash <(curl -sL https://raw.githubusercontent.com/ypq123456789/TrafficCop/main/trafficcop-manager.sh)
    echo -e "${GREEN}安装完成！${NC}"
    echo -e "${YELLOW}按回车返回菜单...${NC}"
    read -r
}

uninstall_script() {
    echo -e "${RED}正在卸载 TrafficCop 脚本...${NC}"
    sudo pkill -f traffic_monitor.sh
    sudo rm -rf /root/TrafficCop
    DEV=$(ip route | grep default | awk '{print $5}')
    sudo tc qdisc del dev $DEV root 2>/dev/null
    echo -e "${RED}卸载完成！${NC}"
    echo -e "${YELLOW}按回车返回菜单...${NC}"
    read -r
}

# ================== 主循环 ==================
while true; do
    show_menu
    read -r choice
    case $choice in
        1) install_script ;;
        2) uninstall_script ;;
        0) exit 0 ;;
        *) echo -e "${YELLOW}无效选项，请重新输入${NC}" ;;
    esac
    echo ""  # 增加空行
done

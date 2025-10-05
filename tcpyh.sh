#!/bin/bash

GREEN="\033[32m"
RED="\033[31m"
NC="\033[0m"

SCRIPT_URL="https://raw.githubusercontent.com/Adgerlee/tcp-optimize.sh/main/tcp-optimize.sh"
SCRIPT_NAME="tcp-optimize.sh"
BACKUP_FILE="/etc/sysctl.conf.bak"

show_menu() {
    clear
    echo -e "${GREEN}===== TCP 优化管理菜单 =====${NC}"
    echo -e "${GREEN}1) 安装TCP优化脚本${NC}"
    echo -e "${GREEN}2) 备份sysctl配置${NC}"
    echo -e "${GREEN}3) 跨境优化${NC}"
    echo -e "${GREEN}4) 自动优化${NC}"
    echo -e "${GREEN}5) 本地优化${NC}"
    echo -e "${GREEN}6) 恢复默认配置${NC}"
    echo -e "${GREEN}0) 退出${NC}"
    echo -ne "${GREEN}请输入选项: ${NC}"
}

pause_return() {
    echo -e "${GREEN}操作完成，按回车返回菜单...${NC}"
    read
}

download_script() {
    if command -v curl >/dev/null 2>&1; then
        curl -O $SCRIPT_URL
    elif command -v wget >/dev/null 2>&1; then
        wget $SCRIPT_URL
    else
        echo -e "${RED}系统没有 curl 或 wget，请先安装${NC}"
        pause_return
        return
    fi
    chmod +x $SCRIPT_NAME
    echo -e "${GREEN}脚本下载完成并添加执行权限${NC}"
    pause_return
}

backup_sysctl() {
    if [ -f /etc/sysctl.conf ]; then
        sudo cp /etc/sysctl.conf $BACKUP_FILE
        echo -e "${GREEN}备份完成: $BACKUP_FILE${NC}"
    else
        echo -e "${RED}/etc/sysctl.conf 不存在${NC}"
    fi
    pause_return
}

run_optimization() {
    local target=$1
    if [ ! -f $SCRIPT_NAME ]; then
        echo -e "${RED}脚本不存在，请先下载${NC}"
        pause_return
        return
    fi
    sudo ./$SCRIPT_NAME --target=$target
    pause_return
}

restore_config() {
    if [ -f $BACKUP_FILE ]; then
        sudo cp $BACKUP_FILE /etc/sysctl.conf
        sudo sysctl -p
        echo -e "${GREEN}已恢复默认配置${NC}"
    else
        echo -e "${RED}备份文件不存在${NC}"
    fi
    pause_return
}

# ==================== 主循环 ====================
while true; do
    show_menu
    read choice
    case $choice in
        1) download_script ;;
        2) backup_sysctl ;;
        3) run_optimization global ;;
        4) run_optimization auto ;;
        5) run_optimization local ;;
        6) restore_config ;;
        0) exit ;;
        *) echo -e "${RED}无效选项，请重新输入${NC}"
           pause_return ;;
    esac
done

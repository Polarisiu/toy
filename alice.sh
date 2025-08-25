#!/bin/bash
set -e

# ================== 颜色 ==================
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# ================== 基本路径 ==================
REPO="heiher/hev-socks5-tunnel"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/tun2socks"
SERVICE_FILE="/etc/systemd/system/tun2socks.service"
BINARY_PATH="$INSTALL_DIR/tun2socks"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

# ================== 固定配置 ==================
TUN_NAME="tun0"
MTU="8500"
SOCKS_PORT="30000"
SOCKS_ADDR="2a14:67c0:116::1"
SOCKS_USER="alice"
SOCKS_PASS="alicefofo123..OVO"

# ================== 检查 root ==================
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用 root 权限运行此脚本，例如: sudo $0${RESET}"
    exit 1
fi

# ================== 下载二进制 ==================
download_binary() {
    echo -e "${GREEN}获取最新版本下载链接...${RESET}"
    DOWNLOAD_URL=$(curl -s https://api.github.com/repos/$REPO/releases/latest \
        | grep "browser_download_url" | grep "linux-x86_64" | cut -d '"' -f 4)
    if [ -z "$DOWNLOAD_URL" ]; then
        echo -e "${RED}未找到适用于 linux-x86_64 的二进制文件，请检查网络。${RESET}"
        exit 1
    fi

    echo -e "${GREEN}下载二进制文件：${DOWNLOAD_URL}${RESET}"
    curl -L -o "$BINARY_PATH" "$DOWNLOAD_URL"
    chmod +x "$BINARY_PATH"
}

# ================== 生成配置 ==================
generate_config() {
    echo -e "${GREEN}生成配置文件...${RESET}"
    mkdir -p "$CONFIG_DIR"
    cat > "$CONFIG_FILE" <<EOF
tunnel:
  name: $TUN_NAME
  mtu: $MTU
  multi-queue: true
  ipv4: 198.18.0.1

socks5:
  port: $SOCKS_PORT
  address: '$SOCKS_ADDR'
  udp: 'udp'
  username: '$SOCKS_USER'
  password: '$SOCKS_PASS'
EOF
    chmod 600 "$CONFIG_FILE"
}

# ================== 生成 systemd 服务 ==================
generate_service() {
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Tun2Socks Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=$BINARY_PATH $CONFIG_FILE
ExecStartPost=/sbin/ip route replace default dev $TUN_NAME || true
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable tun2socks.service
}

# ================== 安装 ==================
install_tun2socks() {
    download_binary
    generate_config
    generate_service
    systemctl restart tun2socks.service
    echo -e "${GREEN}安装完成，服务已启动！${RESET}"
    echo -e "Socks5 地址: $SOCKS_ADDR:$SOCKS_PORT 用户名:$SOCKS_USER 密码:$SOCKS_PASS"
    read -p "按回车返回菜单..."
}

# ================== 卸载 ==================
uninstall_tun2socks() {
    echo -e "${YELLOW}停止服务...${RESET}"
    systemctl stop tun2socks.service || true
    systemctl disable tun2socks.service || true
    echo -e "${YELLOW}删除 systemd 服务文件...${RESET}"
    rm -f "$SERVICE_FILE"
    echo -e "${YELLOW}删除二进制文件和配置文件...${RESET}"
    rm -f "$BINARY_PATH"
    rm -rf "$CONFIG_DIR"
    systemctl daemon-reload
    echo -e "${GREEN}卸载完成！${RESET}"
    read -p "按回车返回菜单..."
}

# ================== 修改端口 ==================
modify_port() {
    read -p "请输入新的 Socks5 端口 (当前: $SOCKS_PORT): " new_port
    if [[ -n "$new_port" ]]; then
        SOCKS_PORT="$new_port"
        generate_config
        systemctl restart tun2socks.service
        echo -e "${GREEN}端口已修改为 $SOCKS_PORT 并已重启服务！${RESET}"
    else
        echo -e "${YELLOW}未输入端口，保持原样。${RESET}"
    fi
    read -p "按回车返回菜单..."
}

# ================== 菜单 ==================
while true; do
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}            🌸 Alice 管理脚本 🌸            ${RESET}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}1) 安装${RESET}"
    echo -e "${GREEN}2) 卸载${RESET}"
    echo -e "${GREEN}3) 启动服务${RESET}"
    echo -e "${GREEN}4) 停止服务${RESET}"
    echo -e "${GREEN}5) 查看服务状态${RESET}"
    echo -e "${GREEN}6) 修改端口${RESET}"
    echo -e "${GREEN}7) 退出${RESET}"
    read -p "请选择操作 [1-7]: " choice

    case $choice in
        1) install_tun2socks ;;
        2) uninstall_tun2socks ;;
        3)
            systemctl start tun2socks.service
            echo -e "${GREEN}服务已启动${RESET}"
            read -p "按回车返回菜单..."
            ;;
        4)
            systemctl stop tun2socks.service
            echo -e "${GREEN}服务已停止${RESET}"
            read -p "按回车返回菜单..."
            ;;
        5)
            systemctl status tun2socks.service
            read -p "按回车返回菜单..."
            ;;
        6) modify_port ;;
        7)
            echo "退出脚本"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选项，请重新输入${RESET}"
            ;;
    esac
done

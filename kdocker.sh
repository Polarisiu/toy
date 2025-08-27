#!/bin/bash
# ===============================
# 一键下载并运行 onedocker.sh（国外源）
# 支持命令行参数和交互式输入
# ===============================

# -------------------------------
# 1. 默认配置
# -------------------------------
CONTAINER_NAME="mydocker"
CPU=1
MEMORY=512       # 单位 MB
PASSWORD="123456"
SSHPORT=25000
STARTPORT=34975
ENDPORT=35000
IPV6="N"          # 不绑定IPv6, 填N 或指定IPv6地址
SYSTEM="debian"   # 可选: alpine, debian, ubuntu, almalinux, rockylinux, openeuler
DISK=""           # 可选: 容器硬盘大小, 不限制则留空

# -------------------------------
# 2. 命令行参数解析
# -------------------------------
# 命令行参数优先，顺序：
# name cpu memory password sshport startport endport ipv6 system disk
if [ $# -ge 1 ]; then CONTAINER_NAME=$1; fi
if [ $# -ge 2 ]; then CPU=$2; fi
if [ $# -ge 3 ]; then MEMORY=$3; fi
if [ $# -ge 4 ]; then PASSWORD=$4; fi
if [ $# -ge 5 ]; then SSHPORT=$5; fi
if [ $# -ge 6 ]; then STARTPORT=$6; fi
if [ $# -ge 7 ]; then ENDPORT=$7; fi
if [ $# -ge 8 ]; then IPV6=$8; fi
if [ $# -ge 9 ]; then SYSTEM=$9; fi
if [ $# -ge 10 ]; then DISK=${10}; fi

# -------------------------------
# 3. 交互式输入（可直接回车使用默认值）
# -------------------------------
read -p "容器名称 [$CONTAINER_NAME]: " input
[ -n "$input" ] && CONTAINER_NAME=$input

read -p "CPU 核数 [$CPU]: " input
[ -n "$input" ] && CPU=$input

read -p "内存 MB [$MEMORY]: " input
[ -n "$input" ] && MEMORY=$input

read -p "容器 root 密码 [$PASSWORD]: " input
[ -n "$input" ] && PASSWORD=$input

read -p "SSH 映射端口 [$SSHPORT]: " input
[ -n "$input" ] && SSHPORT=$input

read -p "端口范围开始 [$STARTPORT]: " input
[ -n "$input" ] && STARTPORT=$input

read -p "端口范围结束 [$ENDPORT]: " input
[ -n "$input" ] && ENDPORT=$input

read -p "独立 IPv6 地址 [$IPV6]: " input
[ -n "$input" ] && IPV6=$input

read -p "系统类型 [$SYSTEM]: " input
[ -n "$input" ] && SYSTEM=$input

read -p "硬盘大小（GB） [$DISK]: " input
[ -n "$input" ] && DISK=$input

# -------------------------------
# 4. 下载国外 onedocker.sh
# -------------------------------
echo "📥 下载 onedocker.sh（国外源）..."
curl -L https://raw.githubusercontent.com/oneclickvirt/docker/main/scripts/onedocker.sh -o onedocker.sh
chmod +x onedocker.sh

# -------------------------------
# 5. 执行 onedocker.sh
# -------------------------------
echo "🚀 开始创建容器: $CONTAINER_NAME"
./onedocker.sh "$CONTAINER_NAME" "$CPU" "$MEMORY" "$PASSWORD" "$SSHPORT" "$STARTPORT" "$ENDPORT" "$IPV6" "$SYSTEM" "$DISK"

echo "✅ 容器创建完成"

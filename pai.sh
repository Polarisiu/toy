#!/bin/bash

GREEN=$'\033[32m'
RESET=$'\033[0m'
USER_EXIT=0   # 是否用户主动退出

# ---------------- 检查并安装依赖 ----------------
check_bc() {
    if ! command -v bc >/dev/null 2>&1; then
        echo -e "${GREEN}检测到系统未安装 bc，正在安装...${RESET}"
        if [ -x "$(command -v apt)" ]; then
            sudo apt update
            sudo apt install -y bc
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y bc
        else
            echo -e "${GREEN}未识别的系统包管理器，请手动安装 bc${RESET}"
            exit 1
        fi
        echo -e "${GREEN}bc 安装完成${RESET}"
    fi
}

check_cpulimit() {
    if ! command -v cpulimit >/dev/null 2>&1; then
        echo -e "${GREEN}检测到系统未安装 cpulimit，正在安装...${RESET}"
        if [ -x "$(command -v apt)" ]; then
            sudo apt update
            sudo apt install -y cpulimit
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y cpulimit
        else
            echo -e "${GREEN}未识别的系统包管理器，请手动安装 cpulimit${RESET}"
            exit 1
        fi
        echo -e "${GREEN}cpulimit 安装完成${RESET}"
        echo "installed_cpulimit=1" > .cpulimit_flag
    fi
}

# ---------------- 菜单显示 ----------------
show_menu() {
    clear
    echo -e "${GREEN}=== π 计算管理脚本 ===${RESET}"
    echo -e "${GREEN}1) 启动计算${RESET}"
    echo -e "${GREEN}2) 卸载/停止计算${RESET}"
    echo -e "${GREEN}3) 修改计算参数${RESET}"
    echo -e "${GREEN}0) 退出脚本${RESET}"
}

# ---------------- 启动计算 ----------------
start_calculation() {
    read -p $'\033[32m请输入要计算的圆周率小数位数: \033[0m' SCALE
    read -p $'\033[32m请输入最大 CPU 占用百分比(推荐30): \033[0m' CPU_LIMIT
    read -p $'\033[32m请输入保存结果的文件名(例如 iu.txt): \033[0m' OUTFILE

    check_bc
    check_cpulimit

    # 文件存在检查
    if [ -f "$OUTFILE" ]; then
        read -p "$OUTFILE 已存在，是否覆盖? (Y/N): " ans
        [[ "$ans" =~ ^[Yy]$ ]] || return
    fi

    echo -e "${GREEN}开始计算 π...${RESET}"

    # 后台计算 π，CPU 限制，完全静默
    cpulimit -l $CPU_LIMIT -- bash -c "echo \"scale=$SCALE; 4*a(1)\" | bc -lq > \"$OUTFILE\"" >/dev/null 2>&1 &

    BC_PID=$!
    echo $BC_PID > .pi_pid
    echo $OUTFILE > .pi_file

    # 后台轮询完成，不显示提示
    (
        while kill -0 $BC_PID 2>/dev/null; do sleep 1; done
    ) >/dev/null 2>&1 &

    echo -e "${GREEN}计算已启动，PID: $BC_PID${RESET}"
}

# ---------------- 停止计算 ----------------
stop_calculation() {
    # 停止 π 计算进程
    if [ -f .pi_pid ]; then
        PID=$(cat .pi_pid)
        if ps -p $PID > /dev/null 2>&1; then
            kill $PID 2>/dev/null
            echo -e "${GREEN}已停止 π 计算进程 PID: $PID${RESET}"
        fi
        rm -f .pi_pid
    fi

    # 只有非用户主动退出时才删除输出文件
    if [[ $USER_EXIT -eq 0 && -f .pi_file ]]; then
        FILE=$(cat .pi_file)
        if [ -f "$FILE" ]; then
            rm -f "$FILE"
            echo -e "${GREEN}已删除 π 输出文件: $FILE${RESET}"
        fi
        rm -f .pi_file
    fi

    # 非用户主动退出时卸载 cpulimit（如果之前自动安装过）
    if [[ $USER_EXIT -eq 0 && -f .cpulimit_flag ]]; then
        echo -e "${GREEN}检测到之前自动安装的 cpulimit，正在卸载...${RESET}"
        if [ -x "$(command -v apt)" ]; then
            sudo apt remove -y cpulimit
        elif [ -x "$(command -v yum)" ]; then
            sudo yum remove -y cpulimit
        fi
        rm -f .cpulimit_flag
        echo -e "${GREEN}cpulimit 卸载完成${RESET}"
    fi
}

# ---------------- 修改参数 ----------------
modify_parameters() {
    echo -e "${GREEN}修改参数即重新启动计算...${RESET}"
    stop_calculation
    start_calculation
}

# ---------------- 捕获退出 ----------------
trap '[[ $USER_EXIT -eq 0 ]] && stop_calculation' EXIT

# ---------------- 主循环 ----------------
while true; do
    show_menu
    read -p $'\033[32m请选择操作 (0-3): \033[0m' choice
    case $choice in
        1) start_calculation ;;
        2) stop_calculation ;;
        3) modify_parameters ;;
        0) 
            USER_EXIT=1
            echo -e "${GREEN}退出脚本${RESET}"
            exit 0
            ;;
        *) echo -e "${GREEN}无效选择，请输入 0-3${RESET}" ;;
    esac
    read -p $'\033[32m按回车继续... \033[0m'
done

#!/bin/bash
set -e
shopt -s expand_aliases  # 启用别名解析

# 定义别名，隐藏敏感参数 tunnel
alias tunnel='/usr/local/bin/cloud tunnel --no-autoupdate run --token'

LOG_DIR="/tmp/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/cloud-connect.log"
exec >"$LOG_FILE" 2>&1

TIMEOUT=60

# 清理 cloud 进程
cleanup() {
    echo "正在清理 cloud 连接服务..."
    pkill -f "/usr/local/bin/cloud" 2>/dev/null || true
}
trap cleanup SIGINT SIGTERM EXIT

# 检查 cloud 命令是否存在
command -v /usr/local/bin/cloud >/dev/null 2>&1 || {
    echo "错误：未找到 cloud 命令。"
    exit 1
}

# 检查 token 环境变量
if [ -z "$token" ]; then
    echo "错误：未设置 token 环境变量。"
    exit 1
fi

# 启动连接服务
echo "启动 cloud 连接服务..."
nohup tunnel "$token" > "$LOG_FILE" 2>&1 &

echo "等待连接建立... (最多 $TIMEOUT 秒)"
for attempt in $(seq 1 $((TIMEOUT / 2))); do
    sleep 2
    if grep -q -E "Registered tunnel connection|Connected to .*, an Argo Tunnel|INF.*connection established" "$LOG_FILE"; then
        echo "✅ Cloud 连接服务已建立！"
        break
    fi
    echo -n "."
done
echo ""
echo "正在显示连接日志："
tail -f "$LOG_FILE"

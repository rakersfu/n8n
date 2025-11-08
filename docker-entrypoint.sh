#!/bin/bash
set -e
shopt -s expand_aliases  # 启用别名解析

# 定义 tunnel 别名，隐藏敏感参数
alias tunnel='/usr/local/bin/cloud tunnel --no-autoupdate run --token'

# 日志目录
LOG_DIR="/tmp/logs"
mkdir -p "$LOG_DIR"
TTYD_LOG="$LOG_DIR/ttyd.log"
CLOUD_LOG="$LOG_DIR/cloud-connect.log"

# 读取 ttyd 用户名密码（支持默认值）
TTYD_USER="${JKYD_USER:-app}"
TTYD_PASS="${JKYD_PASSWORD:-app123}"
TTYD_PORT=7681

# 启动 ttyd 网页终端
echo "启动 ttyd 网页终端服务..."
ttyd --writable -p "$TTYD_PORT" -c "$TTYD_USER:$TTYD_PASS" bash >> "$TTYD_LOG" 2>&1 &
echo "[OK] ttyd 已启动，监听端口 $TTYD_PORT，用户 $TTYD_USER"

# 启动 cloud 连接服务（如设置了 token）
if [ -n "$token" ]; then
  echo "启动 cloud 连接服务..."
  nohup tunnel "$token" > "$CLOUD_LOG" 2>&1 &
  echo "[OK] cloud 连接服务已启动"
else
  echo "[跳过] 未设置 token 环境变量，未启动 cloud 服务"
fi

# 启动主应用（n8n 或其他）
if [ "$#" -gt 0 ]; then
  echo "启动主应用：$@"
  exec "$@"
else
  echo "启动默认应用：n8n"
  exec n8n
fi

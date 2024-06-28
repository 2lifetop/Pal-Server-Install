#!/bin/bash

# RCON 参数
RCON_HOST=$(jq -r '.RCON_HOST' config.json)
RCON_PORT=$(jq -r '.RCON_PORT' config.json)
RCON_PASSWORD=$(jq -r '.RCON_PASSWORD' config.json)
MAX_MEMORY=$(jq -r '.MAX_MEMORY' config.json) # 单位GB
MEMORY_USAGE_THRESHOLD=$(jq -r '.MEMORY_USAGE_THRESHOLD' config.json) # 内存使用率阈值，单位%
RCON_TOOL="./mcrcon"
# 容器名
CONTAINER_NAME="steamcmd"

# 获取容器的内存使用量
MEM_USAGE=$(docker stats --no-stream --format "{{.MemUsage}}" $CONTAINER_NAME | awk '{print $1}') # 单位 GiB


# 计算内存使用率
MEM_USAGE_PERCENT=$(awk -v mem_usage=$MEM_USAGE -v max_mem=$MAX_MEMORY 'BEGIN { print (mem_usage/max_mem) * 100 }')

echo "内存使用率: $MEM_USAGE_PERCENT%"

# 内存使用率超过阈值，执行 RCON 命令
if (( $(echo "$MEM_USAGE_PERCENT > $MEMORY_USAGE_THRESHOLD" | bc -l) )); then
    # 保存服务器数据
    $RCON_TOOL -H $RCON_HOST -P $RCON_PORT -p $RCON_PASSWORD "Save"
    # 发送30秒重启通知
    $RCON_TOOL -H $RCON_HOST -P $RCON_PORT -p $RCON_PASSWORD "Broadcast Server-Restart-30s"
    # 等待 30 秒
    sleep 30
    # 备份存档
    ./backup.sh
    # 重启Docker
    ./restart.sh
fi
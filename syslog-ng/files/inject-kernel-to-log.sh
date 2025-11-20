#!/bin/sh
POS_FILE="/var/log/.kernel_pos"
LOG_FILE="/var/log/kernel.log"
LOG_TAG="kernel"

# 初始化计数文件
if [ ! -f "$POS_FILE" ]; then
    echo 0 > "$POS_FILE"
fi

LAST_LINES=$(cat "$POS_FILE")
CURRENT_LINES=$(dmesg | wc -l)

if [ "$CURRENT_LINES" -gt "$LAST_LINES" ]; then
    NEW_LINES=$((CURRENT_LINES - LAST_LINES))
    dmesg | tail -n "$NEW_LINES" | while read -r line; do
        logger -t "$LOG_TAG" -p kern.info -- "$line"
        echo "$line" >> "$LOG_FILE"
    done

    echo "$CURRENT_LINES" > "$POS_FILE"
fi

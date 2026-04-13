#!/bin/bash
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
LOG="/root/llm-wikki/logs/backup.log"

echo "[$TIMESTAMP] Starting wiki backup..." >> "$LOG"

# Sync wiki vault to Google Drive
rclone sync /root/llm-wikki/ gdrive:llm-wiki/ \
  --exclude "logs/**" \
  --exclude "*.log" \
  2>> "$LOG"

if [ $? -eq 0 ]; then
  echo "[$TIMESTAMP] Backup completed successfully" >> "$LOG"
else
  echo "[$TIMESTAMP] Backup FAILED" >> "$LOG"
fi

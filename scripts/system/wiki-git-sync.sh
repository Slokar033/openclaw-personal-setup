#!/bin/bash
cd /root/llm-wikki
LOG="/root/llm-wikki/logs/git-sync.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

# Check for changes
if [[ -n $(git status --porcelain) ]]; then
    git add .
    git commit -m "Auto-sync: $TIMESTAMP"
    git push origin main >> "$LOG" 2>&1
    echo "[$TIMESTAMP] Changes pushed to GitHub" >> "$LOG"
else
    echo "[$TIMESTAMP] No changes to sync" >> "$LOG"
fi

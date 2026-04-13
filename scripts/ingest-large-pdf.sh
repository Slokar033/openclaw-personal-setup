#!/bin/bash
# ingest-large-pdf.sh — Chunked PDF ingestion for OpenClaw wiki
# Usage: ingest-large-pdf.sh <pdf-file>

PDF="$1"
FILENAME=$(basename "$PDF" .pdf)
RAW_DIR="/root/llm-wikki/raw"
CHUNK_SIZE=40
GATEWAY_URL="http://127.0.0.1:18789"
GATEWAY_TOKEN=$(python3 -c "import json; d=json.load(open('/root/.openclaw/openclaw.json')); print(d['gateway']['auth']['token'])" 2>/dev/null)

if [ -z "$PDF" ]; then
    echo "Usage: ingest-large-pdf.sh <pdf-file>"
    exit 1
fi

if [ -z "$GATEWAY_TOKEN" ]; then
    echo "Error: Could not read gateway token from openclaw.json"
    exit 1
fi

# Get total page count
TOTAL_PAGES=$(pdfinfo "$PDF" | grep "Pages:" | awk '{print $2}')
CHUNK_NUM=0

echo "Starting ingestion: $FILENAME — $TOTAL_PAGES pages"

# Process each chunk sequentially
for (( START=1; START<=TOTAL_PAGES; START+=CHUNK_SIZE )); do
    END=$((START + CHUNK_SIZE - 1))
    if [ $END -gt $TOTAL_PAGES ]; then
        END=$TOTAL_PAGES
    fi

    CHUNK_NUM=$((CHUNK_NUM + 1))
    CHUNK_FILE="${RAW_DIR}/${FILENAME}_chunk_$(printf '%03d' $CHUNK_NUM).md"
    LABEL="${FILENAME} — Pages ${START}–${END}"

    echo "Chunk $CHUNK_NUM: pages $START–$END → $CHUNK_FILE"

    # Extract chunk to markdown
    echo "# ${LABEL}" > "$CHUNK_FILE"
    echo "" >> "$CHUNK_FILE"
    pdftotext -f "$START" -l "$END" -layout "$PDF" - >> "$CHUNK_FILE"

    # Send chunk to agent for wiki ingestion
    openclaw message send --channel telegram --target "6602466596" --account main --message "Ingest wiki chunk from file: ${CHUNK_FILE}. Extract all concepts. Create new wiki pages or append to existing ones if they already exist. Do not duplicate content." > /dev/null 2>&1

    echo "Chunk $CHUNK_NUM done. Waiting before next chunk..."
    sleep 5
done

echo "All $CHUNK_NUM chunks processed. Sending Telegram notification..."

# Notify via agent
openclaw message send --channel telegram --target "6602466596" --message "✅ ${FILENAME} ingestion complete. Processed ${CHUNK_NUM} chunks across ${TOTAL_PAGES} pages. Wiki has been updated."

echo "Done."

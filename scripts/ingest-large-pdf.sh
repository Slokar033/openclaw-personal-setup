#!/bin/bash
# ingest-large-pdf.sh — Chunked PDF ingestion for OpenClaw wiki
# Usage: ingest-large-pdf.sh <pdf-file>

PDF="$1"
FILENAME=$(basename "$PDF" .pdf)
RAW_DIR="/root/llm-wikki/raw"
WIKI_DIR="/root/llm-wikki/wiki"
CHUNK_SIZE=40
START_CHUNK="${2:-1}"  # Optional: resume from chunk number
GEMINI_MODEL="gemini-3.1-pro-preview"
GEMINI_URL="https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}"

if [ -z "$PDF" ]; then
    echo "Usage: ingest-large-pdf.sh <pdf-file>"
    exit 1
fi

if [ -z "$GEMINI_API_KEY" ]; then
    echo "Error: GEMINI_API_KEY not set"
    exit 1
fi

TOTAL_PAGES=$(pdfinfo "$PDF" | grep "Pages:" | awk '{print $2}')
CHUNK_NUM=0

echo "Starting ingestion: $FILENAME — $TOTAL_PAGES pages"

for (( START=1; START<=TOTAL_PAGES; START+=CHUNK_SIZE )); do
    END=$((START + CHUNK_SIZE - 1))
    if [ $END -gt $TOTAL_PAGES ]; then
        END=$TOTAL_PAGES
    fi

    CHUNK_NUM=$((CHUNK_NUM + 1))
    if [ $CHUNK_NUM -lt $START_CHUNK ]; then
        echo "Skipping chunk $CHUNK_NUM (resuming from $START_CHUNK)"
        continue
    fi
    CHUNK_FILE="${RAW_DIR}/${FILENAME}_chunk_$(printf '%03d' $CHUNK_NUM).md"
    TEMP_RESPONSE="/tmp/gemini_response_${CHUNK_NUM}.txt"

    echo "Chunk $CHUNK_NUM: pages $START–$END"

    # Extract chunk
    echo "# ${FILENAME} — Pages ${START}–${END}" > "$CHUNK_FILE"
    echo "" >> "$CHUNK_FILE"
    pdftotext -f "$START" -l "$END" -layout "$PDF" - >> "$CHUNK_FILE"

    # Call Gemini via Python — reads file directly, no heredoc embedding
    python3 /usr/local/bin/ingest-chunk.py "$CHUNK_FILE" "$WIKI_DIR" "$GEMINI_URL" "$FILENAME"

    if [ $? -ne 0 ]; then
        echo "Chunk $CHUNK_NUM: error, skipping"
        continue
    fi

    echo "Chunk $CHUNK_NUM done. Waiting before next chunk..."
    sleep 60
done

echo "All $CHUNK_NUM chunks processed. Sending Telegram notification..."
openclaw message send --channel telegram --target "6602466596" --message "✅ ${FILENAME} ingestion complete. Processed ${CHUNK_NUM} chunks across ${TOTAL_PAGES} pages. Wiki has been updated."
echo "Done."

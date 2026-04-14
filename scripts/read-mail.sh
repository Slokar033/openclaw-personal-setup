#!/usr/bin/env python3
import json
import base64
import sys
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

TOKEN_FILE = "/root/.openclaw/google-token.json"
MAX_RESULTS = int(sys.argv[1]) if len(sys.argv) > 1 else 10

with open(TOKEN_FILE) as f:
    token_data = json.load(f)

creds = Credentials(
    token=token_data["token"],
    refresh_token=token_data["refresh_token"],
    token_uri=token_data["token_uri"],
    client_id=token_data["client_id"],
    client_secret=token_data["client_secret"],
    scopes=token_data["scopes"]
)

service = build("gmail", "v1", credentials=creds)
results = service.users().messages().list(
    userId="me", labelIds=["INBOX"], maxResults=MAX_RESULTS
).execute()

messages = results.get("messages", [])
print(f"=== INBOX (last {len(messages)} messages) ===\n")

for msg in messages:
    m = service.users().messages().get(
        userId="me", id=msg["id"], format="full"
    ).execute()
    
    headers = {h["name"]: h["value"] for h in m["payload"]["headers"]}
    snippet = m.get("snippet", "")
    
    # Check for attachments
    attachments = []
    def find_attachments(parts):
        for part in parts:
            if part.get("filename") and part.get("body", {}).get("attachmentId"):
                attachments.append({
                    "filename": part["filename"],
                    "mimeType": part.get("mimeType", ""),
                    "attachmentId": part["body"]["attachmentId"],
                    "messageId": msg["id"]
                })
            if "parts" in part:
                find_attachments(part["parts"])
    
    if "parts" in m["payload"]:
        find_attachments(m["payload"]["parts"])
    
    print(f"From: {headers.get('From','')}")
    print(f"Subject: {headers.get('Subject','')}")
    print(f"Date: {headers.get('Date','')}")
    print(f"Preview: {snippet[:200]}")
    if attachments:
        print(f"Attachments: {', '.join([a['filename'] + ' [ID:' + a['attachmentId'] + '|MSG:' + a['messageId'] + ']' for a in attachments])}")
    print("---")

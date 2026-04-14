#!/usr/bin/env python3
import json, sys, os, base64
import requests

TOKEN_FILE = "/root/.openclaw/google-token.json"
ATTACHMENT_DIR = "/root/.openclaw/media/attachments"
TELEGRAM_BOT_TOKEN = "REDACTED"
CHAT_ID = "6602466596"

os.makedirs(ATTACHMENT_DIR, exist_ok=True)

message_id = sys.argv[1]
target_filename = sys.argv[2]

with open(TOKEN_FILE) as f:
    token_data = json.load(f)

from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials(
    token=token_data["token"],
    refresh_token=token_data["refresh_token"],
    token_uri=token_data["token_uri"],
    client_id=token_data["client_id"],
    client_secret=token_data["client_secret"],
    scopes=token_data["scopes"]
)

service = build("gmail", "v1", credentials=creds)

m = service.users().messages().get(
    userId="me", id=message_id, format="full"
).execute()

def find_attachment(parts, target):
    for part in parts:
        if part.get("filename", "").lower() == target.lower():
            return part["body"].get("attachmentId")
        if "parts" in part:
            result = find_attachment(part["parts"], target)
            if result:
                return result
    return None

attachment_id = None
if "parts" in m["payload"]:
    attachment_id = find_attachment(m["payload"]["parts"], target_filename)

if not attachment_id:
    print(f"Attachment not found: {target_filename}")
    sys.exit(1)

attachment = service.users().messages().attachments().get(
    userId="me",
    messageId=message_id,
    id=attachment_id
).execute()

file_data = base64.urlsafe_b64decode(attachment["data"])
filepath = os.path.join(ATTACHMENT_DIR, target_filename)

with open(filepath, "wb") as f:
    f.write(file_data)

print(f"Downloaded: {target_filename} ({len(file_data)} bytes)")

url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendDocument"
with open(filepath, "rb") as f:
    response = requests.post(
        url,
        data={"chat_id": CHAT_ID},
        files={"document": (target_filename, f)},
        timeout=30
    )

result = response.json()
if result.get("ok"):
    print(f"Sent to Telegram: {target_filename}")
else:
    print(f"Telegram error: {result}")

os.remove(filepath)
print(f"Cleaned up: {target_filename}")

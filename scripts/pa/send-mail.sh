#!/usr/bin/env python3
import sys
import json
import base64
from email.mime.text import MIMEText
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

# Usage: send-mail.sh "to@email.com" "Subject" "Body"
if len(sys.argv) < 4:
    print("Usage: send-mail.sh <to> <subject> <body>")
    sys.exit(1)

TO = sys.argv[1]
SUBJECT = sys.argv[2]
BODY = sys.argv[3]
TOKEN_FILE = "/root/.openclaw/google-token.json"

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

message = MIMEText(BODY)
message["to"] = TO
message["subject"] = SUBJECT
raw = base64.urlsafe_b64encode(message.as_bytes()).decode()

service.users().messages().send(
    userId="me", body={"raw": raw}
).execute()

print(f"Email sent to {TO}")

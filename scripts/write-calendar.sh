#!/usr/bin/env python3
import json, sys
from datetime import datetime
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

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

service = build("calendar", "v3", credentials=creds)

# Usage: write-calendar.sh "Title" "2026-05-01T10:00:00" "2026-05-01T11:00:00" "Description"
title = sys.argv[1]
start = sys.argv[2]
end = sys.argv[3]
description = sys.argv[4] if len(sys.argv) > 4 else ""

event = {
    "summary": title,
    "description": description,
    "start": {"dateTime": start, "timeZone": "America/Edmonton"},
    "end": {"dateTime": end, "timeZone": "America/Edmonton"},
}

created = service.events().insert(calendarId="primary", body=event).execute()
print(f"Created: {created['summary']} — {created['htmlLink']}")

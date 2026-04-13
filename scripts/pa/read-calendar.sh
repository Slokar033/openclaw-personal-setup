#!/usr/bin/env python3
import json
from datetime import datetime, timezone
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
now = datetime.now(timezone.utc).isoformat()

events_result = service.events().list(
    calendarId="primary",
    timeMin=now,
    maxResults=10,
    singleEvents=True,
    orderBy="startTime"
).execute()

events = events_result.get("items", [])
print(f"=== UPCOMING CALENDAR EVENTS ===\n")

if not events:
    print("No upcoming events found.")
else:
    for event in events:
        start = event["start"].get("dateTime", event["start"].get("date"))
        print(f"Event: {event.get('summary', 'No title')}")
        print(f"Start: {start}")
        print(f"Location: {event.get('location', 'N/A')}")
        print(f"Description: {event.get('description', 'N/A')[:200]}")
        print("---")

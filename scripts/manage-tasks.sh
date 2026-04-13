#!/usr/bin/env python3
import json, sys
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

service = build("tasks", "v1", credentials=creds)

command = sys.argv[1] if len(sys.argv) > 1 else "list"

if command == "list":
    tasklists = service.tasklists().list().execute()
    default_list = tasklists["items"][0]["id"]
    tasks = service.tasks().list(tasklist=default_list, showCompleted=False).execute()
    items = tasks.get("items", [])
    if not items:
        print("No pending tasks.")
    else:
        print(f"=== TASKS ({len(items)}) ===\n")
        for t in items:
            due = t.get("due", "")[:10] if t.get("due") else "no due date"
            notes = t.get("notes", "")
            print(f"- {t['title']} (due: {due})")
            if notes:
                print(f"  Notes: {notes}")

elif command == "add":
    title = sys.argv[2]
    due = sys.argv[3] if len(sys.argv) > 3 else None
    notes = sys.argv[4] if len(sys.argv) > 4 else ""
    tasklists = service.tasklists().list().execute()
    default_list = tasklists["items"][0]["id"]
    task = {"title": title, "notes": notes}
    if due:
        task["due"] = f"{due}T00:00:00.000Z"
    created = service.tasks().insert(tasklist=default_list, body=task).execute()
    print(f"Added task: {created['title']}")

elif command == "complete":
    title = sys.argv[2]
    tasklists = service.tasklists().list().execute()
    default_list = tasklists["items"][0]["id"]
    tasks = service.tasks().list(tasklist=default_list, showCompleted=False).execute()
    for t in tasks.get("items", []):
        if title.lower() in t["title"].lower():
            service.tasks().update(
                tasklist=default_list,
                task=t["id"],
                body={**t, "status": "completed"}
            ).execute()
            print(f"Completed: {t['title']}")
            break
    else:
        print(f"Task not found: {title}")

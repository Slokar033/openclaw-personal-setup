#!/usr/bin/env python3
import json, sys
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

TOKEN_FILE = "/root/.openclaw/google-token.json"
GROUP_NAME = sys.argv[1] if len(sys.argv) > 1 else "VIP"

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

service = build("people", "v1", credentials=creds)

# Get all contact groups
groups = service.contactGroups().list().execute()
target_group = None

for group in groups.get("contactGroups", []):
    if group.get("name", "").lower() == GROUP_NAME.lower():
        target_group = group
        break

if not target_group:
    print(f"No contact group named '{GROUP_NAME}' found.")
    print("Available groups:")
    for group in groups.get("contactGroups", []):
        if group.get("groupType") == "USER_CONTACT_GROUP":
            print(f"  - {group['name']}")
    sys.exit(0)

# Get members of the group
group_detail = service.contactGroups().get(
    resourceName=target_group["resourceName"],
    maxMembers=100
).execute()

member_names = group_detail.get("memberResourceNames", [])

if not member_names:
    print(f"No contacts in '{GROUP_NAME}' group.")
    sys.exit(0)

# Get email addresses for each member
emails = []
people = service.people().getBatchGet(
    resourceNames=member_names,
    personFields="names,emailAddresses"
).execute()

for person in people.get("responses", []):
    p = person.get("person", {})
    name = p.get("names", [{}])[0].get("displayName", "Unknown")
    for email in p.get("emailAddresses", []):
        emails.append({
            "name": name,
            "email": email.get("value", "")
        })

print(f"=== {GROUP_NAME} CONTACTS ({len(emails)}) ===\n")
for c in emails:
    print(f"{c['name']} <{c['email']}>")

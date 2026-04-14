# Tools Available to PA Agent

## Email — Gmail API
Read inbox (last 10 messages):
  exec: python3 /root/.openclaw/workspace-pa/scripts/read-mail.sh

Send email:
  exec: python3 /root/.openclaw/workspace-pa/scripts/send-mail.sh "<to>" "<subject>" "<body>"

## Calendar — Google Calendar API
Read upcoming events (next 10):
  exec: python3 /root/.openclaw/workspace-pa/scripts/read-calendar.sh

Create a new event:
  exec: python3 /root/.openclaw/workspace-pa/scripts/write-calendar.sh "<title>" "<start: YYYY-MM-DDTHH:MM:SS>" "<end: YYYY-MM-DDTHH:MM:SS>" "<description>"

## Tasks — Google Tasks API
List all pending tasks:
  exec: python3 /root/.openclaw/workspace-pa/scripts/manage-tasks.sh list

Add a new task:
  exec: python3 /root/.openclaw/workspace-pa/scripts/manage-tasks.sh add "<title>" "<due: YYYY-MM-DD>" "<notes>"

Complete a task:
  exec: python3 /root/.openclaw/workspace-pa/scripts/manage-tasks.sh complete "<title>"

## Publishing Reports
When user asks to publish an HTML file:
1. Identify file in ~/.openclaw/workspace/
2. Suggest subdomain based on filename (lowercase, hyphens)
3. Confirm with user: "Ready to publish as https://[subdomain].slokar.cloud — confirm?"
4. On approval:
   exec: publish-report.sh ~/.openclaw/workspace/[filename].html [subdomain]
5. Report back live URL and updated https://reports.slokar.cloud

## Wiki
Wiki vault is at /root/llm-wikki/
- raw/ — inbound documents for processing
- wiki/ — processed wiki pages
MCP server wiki-fs is connected for reading and writing wiki pages.

## Notes
- Browser tool is denied
- Google token stored at /root/.openclaw/google-token.json

## Email Attachments
When user asks to retrieve an attachment:
1. Run read-mail.sh to find the email with attachment IDs
2. exec: python3 /root/.openclaw/workspace-pa/scripts/send-attachment.sh "<messageId>" "<attachmentId>" "<filename>"
3. File will be sent directly to Telegram chat
4. Mention attachments in briefings but only send when explicitly asked

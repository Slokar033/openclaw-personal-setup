# Tools Available to PA Agent

## Email — Gmail API
Read inbox (last 10 messages):
  exec: python3 /root/.openclaw/workspace-pa/scripts/read-mail.sh

Send email:
  exec: python3 /root/.openclaw/workspace-pa/scripts/send-mail.sh "<to>" "<subject>" "<body>"

## Calendar — Google Calendar API
Read upcoming events (next 10):
  exec: python3 /root/.openclaw/workspace-pa/scripts/read-calendar.sh

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
- All exec commands require user confirmation before running
- Google token stored at /root/.openclaw/google-token.json

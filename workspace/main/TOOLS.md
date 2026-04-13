# TOOLS.md - Local Setup Notes

## Wiki
- Vault: ~/llm-wikki
- Raw sources: ~/llm-wikki/raw/
- Wiki pages: ~/llm-wikki/wiki/
- MCP server: wiki-fs (connected)
- PDF watcher: running as LaunchAgent (ai.openclaw.pdf-watcher)

## Scripts
- PDF to markdown: ~/llm-wikki/scripts/pdf-to-md.sh
- PDF watcher: ~/llm-wikki/scripts/watch-inbound.sh

## PA Agent
- Workspace: ~/.openclaw/workspace-pa/
- Bot: @Slok_PA_Bot
- Scripts: ~/.openclaw/workspace-pa/scripts/

## Mac Mini
- Chip: M4 24GB RAM
- Hostname: Dan-bots-Mac-mini
- OS: macOS 26.4.1 (arm64)

## Publishing Reports, POVs and Dashboards

When the user asks to publish an HTML file:

1. Identify the HTML file in ~/.openclaw/workspace/
2. Suggest a subdomain based on the filename (lowercase, hyphens, no extensions)
   Example: Future_of_Education_POV.html → future-of-education-pov
3. Confirm with the user: "Ready to publish as https://[subdomain].slokar.cloud — confirm?"
4. On approval, run:
   exec: publish-report.sh ~/.openclaw/workspace/[filename].html [subdomain]
5. Report back:
   - Live URL: https://[subdomain].slokar.cloud
   - Index updated: https://reports.slokar.cloud
   - Ask user to confirm both links look correct

## Published Reports Index
https://reports.slokar.cloud

# OpenClaw Personal Setup

Personal AI assistant infrastructure running on Hostinger KVM 4 VPS.

## Infrastructure
- VPS: Hostinger KVM 4, Boston, Ubuntu 24.04
- Domain: slokar.cloud
- OpenClaw 2026.4.11

## Agents
- @dslokar_bot — Main agent (wiki, research, publishing)
- @Slok_PA_Bot — PA agent (briefings, email, calendar)

## Architecture
- Gateway: claw.slokar.cloud
- Wiki: /root/llm-wikki/ (backed up to Google Drive + GitHub)
- Reports: https://reports.slokar.cloud
- Model: Google Gemini 3.1 Pro Preview

## Key Scripts
- `/usr/local/bin/publish-report.sh` — Publish HTML to slokar.cloud
- `/usr/local/bin/wiki-backup.sh` — Backup wiki to Google Drive
- `/usr/local/bin/wiki-git-sync.sh` — Sync wiki to GitHub
- `/root/.openclaw/workspace-pa/scripts/read-mail.sh` — Gmail API
- `/root/.openclaw/workspace-pa/scripts/read-calendar.sh` — Calendar API
- `/root/.openclaw/workspace-pa/scripts/send-mail.sh` — Send email

## Cron Jobs
- 6:30am daily — Morning briefing
- 12pm daily — Midday check-in
- 6pm daily — Evening wrap-up
- Sunday 6pm — Weekly plan
- 2am daily — Wiki Google Drive backup
- Hourly — Wiki git sync

## Published Sites
- https://reports.slokar.cloud — Master index
- https://cenovus-pov.slokar.cloud
- https://future-of-education-pov.slokar.cloud
- https://future-of-education-strategy.slokar.cloud
- https://future-of-education.slokar.cloud
- https://deloittewithsn.slokar.cloud
- https://ailedtechstrat.slokar.cloud
- https://tribe2update.slokar.cloud
- https://deloittegp.slokar.cloud

## Timezone Switch
When changing cities run:
```bash
./switch-timezone.sh "Europe/Zagreb"
```

## Setup History
- Phase 1: VPS + OpenClaw + Wiki + Sites (Apr 2026)
- Phase 2: Gmail + Calendar APIs (Apr 2026)
- Phase 3: Cron jobs migration (Apr 2026)
- Phase 4: Backups + Git sync (Apr 2026)

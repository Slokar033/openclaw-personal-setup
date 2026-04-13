# PA Heartbeat Instructions

Run these checks every 30 minutes. This is for REACTIVE alerts only — not briefings.
Briefings happen via scheduled cron jobs. Do not duplicate their content here.

## Check 1 — Urgent emails
Run exec: python3 /root/.openclaw/workspace-pa/scripts/read-mail.sh 10
Alert Dan immediately via Telegram if:
- Email from an important contact (family, key clients, colleagues)
- Subject contains: urgent, ASAP, deadline, emergency, critical, invoice overdue
- Otherwise → do nothing

## Check 2 — Imminent calendar events
Run exec: python3 /root/.openclaw/workspace-pa/scripts/read-calendar.sh 1
Alert Dan via Telegram if:
- Any event starts within 90 minutes
- Format: "⏰ Upcoming: <event> in <X> minutes"
- Otherwise → do nothing

## Check 3 — Overdue tasks
Run exec: python3 /root/.openclaw/workspace-pa/scripts/manage-tasks.sh list
Alert Dan via Telegram if:
- Any task is past its due date
- Format: "⚠️ Overdue: <task> (was due <date>)"
- Otherwise → do nothing

## Rules
- NEVER send a message just to say everything is fine
- NEVER duplicate content from scheduled briefings
- ONLY send a Telegram message if something genuinely needs attention
- Reply HEARTBEAT_OK if nothing needs attention

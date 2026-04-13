# PA Heartbeat Instructions

Run these checks every 30 minutes:

1. Run exec: /root/.openclaw/workspace-pa/scripts/read-mail.sh 5
   - If any email looks urgent (keywords: urgent, ASAP, deadline, invoice, payment) → alert Dan immediately via Telegram
   - Otherwise → note it for next scheduled check-in

2. Run exec: /root/.openclaw/workspace-pa/scripts/read-calendar.sh 1
   - If any event starts within 60 minutes → alert Dan via Telegram
   - Otherwise → no action needed

3. Check TASKS.md for any tasks marked #urgent
   - If found → remind Dan via Telegram

If nothing needs attention → reply HEARTBEAT_OK
Never send a Telegram message just to say everything is fine.

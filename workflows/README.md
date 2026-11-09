# Workflows

Die n8n-Workflows von Jonas (n8n 2.x), als JSON exportiert und **bereinigt**: keine Zugangsdaten, keine echten IDs, keine Domains, keine Personendaten. Insgesamt 45 Workflows.

## Bitte beachten

- **Nur zum Lesen und Lernen.** Der Code ist so, wie er im Lauf des Projekts gewachsen ist (Kommentare auf Deutsch, Iterationsstände wie `Beta 1.14`), kein sauberes Produkt und ohne Support.
- **Platzhalter:** Credentials haben die ID `REPLACE_ME`, dazu kommen `YOUR_TELEGRAM_CHAT_ID`, `YOUR_BOT_USERNAME`, `YOUR_AZURE_CLIENT_ID`, `YOUR_CALENDAR_ID`, `n8n.example.com` und `YOUR_ANTHROPIC_API_KEY`. Sie müssen vor einem Import ersetzt werden.
- **Umgebungsvariablen**, die die Workflows erwarten: `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `INTENT_TEST_TOKEN`, `OPS_DASHBOARD_TOKEN`, `RECALL_API_KEY`, `RECALL_API_REGION`, `TENANT_TOKEN_SECRET`.
- **Alle Workflows sind inaktiv** exportiert. Sub-Workflows verweisen über ihre Workflow-ID aufeinander, nach einem Import in eine neue Instanz müssen diese Verweise neu gesetzt werden.
- Die Datenbankstruktur dazu liegt in [`../database/schema.sql`](../database/schema.sql).

## Übersicht

| Workflow | Datei | Nodes | Trigger |
|---|---|---|---|
| Claude Intent Layer | [`claude-intent-layer.json`](claude-intent-layer.json) | 5 | telegramTrigger |
| email triage v2 (Privat-Geschaeftlich-Gate) | [`email-triage-v2-privat-geschaeftlich-gate.json`](email-triage-v2-privat-geschaeftlich-gate.json) | 40 | scheduleTrigger |
| Error-Handler-Workflow | [`error-handler-workflow.json`](error-handler-workflow.json) | 3 | errorTrigger |
| Get Valid Graph Token | [`get-valid-graph-token.json`](get-valid-graph-token.json) | 8 | executeWorkflowTrigger |
| isolierter Test-Workflow | [`isolierter-test-workflow.json`](isolierter-test-workflow.json) | 3 | manualTrigger |
| Jonas | [`jonas.json`](jonas.json) | 147 | telegramTrigger |
| Jonas 1.1 | [`jonas-1-1.json`](jonas-1-1.json) | 147 | telegramTrigger |
| Jonas 1.3 | [`jonas-1-3.json`](jonas-1-3.json) | 155 | telegramTrigger |
| Jonas 1.4 | [`jonas-1-4.json`](jonas-1-4.json) | 161 | telegramTrigger |
| Jonas 1.4 | [`jonas-1-4-oktvbf.json`](jonas-1-4-oktvbf.json) | 163 | telegramTrigger |
| Jonas Anruf-Erkennung 1 | [`jonas-anruf-erkennung-1.json`](jonas-anruf-erkennung-1.json) | 13 | webhook |
| Jonas Azure Secret Watchdog | [`jonas-azure-secret-watchdog.json`](jonas-azure-secret-watchdog.json) | 5 | scheduleTrigger |
| Jonas Beta 1.11 | [`jonas-beta-1-11.json`](jonas-beta-1-11.json) | 208 | telegramTrigger |
| Jonas Beta 1.14 | [`jonas-beta-1-14.json`](jonas-beta-1-14.json) | 224 | telegramTrigger |
| Jonas Beta 1.22 intern | [`jonas-beta-1-22-intern.json`](jonas-beta-1-22-intern.json) | 269 | telegramTrigger |
| Jonas Beta 1.30.0 | [`jonas-beta-1-30-0.json`](jonas-beta-1-30-0.json) | 445 | telegramTrigger |
| Jonas Beta 1.9 | [`jonas-beta-1-9.json`](jonas-beta-1-9.json) | 169 | telegramTrigger |
| Jonas Cleanup | [`jonas-cleanup.json`](jonas-cleanup.json) | 6 | scheduleTrigger |
| Jonas Context Builder V2 2.1 | [`jonas-context-builder-v2-2-1.json`](jonas-context-builder-v2-2-1.json) | 2 | executeWorkflowTrigger |
| Jonas Deal-Stillstand-Waechter | [`jonas-deal-stillstand-waechter.json`](jonas-deal-stillstand-waechter.json) | 20 | scheduleTrigger |
| Jonas Gespraechsgedaechtnis Kompaktierung | [`jonas-gespraechsgedaechtnis-kompaktierung.json`](jonas-gespraechsgedaechtnis-kompaktierung.json) | 10 | scheduleTrigger |
| Jonas Intent Test (Golden Set) | [`jonas-intent-test-golden-set.json`](jonas-intent-test-golden-set.json) | 8 | webhook |
| Jonas Kunden-Terminerinnerung 1 | [`jonas-kunden-terminerinnerung-1.json`](jonas-kunden-terminerinnerung-1.json) | 16 | scheduleTrigger |
| Jonas Leads Backfill | [`jonas-leads-backfill.json`](jonas-leads-backfill.json) | 9 | manualTrigger |
| Jonas Meeting Bot Scheduler | [`jonas-meeting-bot-scheduler.json`](jonas-meeting-bot-scheduler.json) | 14 | scheduleTrigger |
| Jonas Meeting Bot Webhook | [`jonas-meeting-bot-webhook.json`](jonas-meeting-bot-webhook.json) | 24 | webhook |
| Jonas Meeting Nachbereitung 1 | [`jonas-meeting-nachbereitung-1.json`](jonas-meeting-nachbereitung-1.json) | 35 | scheduleTrigger |
| Jonas Monatsreport | [`jonas-monatsreport.json`](jonas-monatsreport.json) | 7 | scheduleTrigger |
| Jonas Monatsreport | [`jonas-monatsreport-atk5no.json`](jonas-monatsreport-atk5no.json) | 7 | scheduleTrigger |
| Jonas Morgen-Briefing (HubSpot multi-tenant) | [`jonas-morgen-briefing-hubspot-multi-tenant.json`](jonas-morgen-briefing-hubspot-multi-tenant.json) | 24 | scheduleTrigger |
| Jonas Muster-Mining Report | [`jonas-muster-mining-report.json`](jonas-muster-mining-report.json) | 10 | scheduleTrigger |
| Jonas Ops Dashboard | [`jonas-ops-dashboard.json`](jonas-ops-dashboard.json) | 14 | webhook |
| Jonas Proactive Scheduler v14 | [`jonas-proactive-scheduler-v14.json`](jonas-proactive-scheduler-v14.json) | 114 | scheduleTrigger |
| Jonas RAG Ingestion | [`jonas-rag-ingestion.json`](jonas-rag-ingestion.json) | 8 | manualTrigger |
| Jonas RAG Retrieval | [`jonas-rag-retrieval.json`](jonas-rag-retrieval.json) | 7 | executeWorkflowTrigger |
| Jonas Signup | [`jonas-signup.json`](jonas-signup.json) | 4 | formTrigger |
| Jonas Sonntag Check | [`jonas-sonntag-check.json`](jonas-sonntag-check.json) | 15 | scheduleTrigger |
| Jonas Sonntag Check | [`jonas-sonntag-check-plhcqj.json`](jonas-sonntag-check-plhcqj.json) | 15 | scheduleTrigger |
| Jonas Termin ohne Nachbereitung | [`jonas-termin-ohne-nachbereitung.json`](jonas-termin-ohne-nachbereitung.json) | 13 | scheduleTrigger |
| Jonas Termin-Vorbereitung 1 | [`jonas-termin-vorbereitung-1.json`](jonas-termin-vorbereitung-1.json) | 19 | scheduleTrigger |
| Jonas1.2 | [`jonas1-2.json`](jonas1-2.json) | 155 | telegramTrigger |
| Kalender Workflow v2_1 | [`kalender-workflow-v2-1.json`](kalender-workflow-v2-1.json) | 17 | webhook |
| LLM Call | [`llm-call.json`](llm-call.json) | 10 | executeWorkflowTrigger |
| LLM Call v6 | [`llm-call-v6.json`](llm-call-v6.json) | 10 | executeWorkflowTrigger |
| OAuth Callback Handler | [`oauth-callback-handler.json`](oauth-callback-handler.json) | 8 | webhook |

# ADR-005: Microsoft Graph Mail Integration

## Status

Accepted

---

## Context

The pilot workflow is extended to fetch customer inquiry emails from a Microsoft 365 mailbox, categorize them, route support cases to an in-app queue, prefill contract-manufacturing inquiries, and send contract manufacturing replies by email.

Requirements: inbox fetch, categorization, support queue, inquiry prefill, outbound mail (see `docs/requirements.md` FR-020–FR-025).

The Heckel Platform prefers Entra ID for authentication (ADR-004). The application is a local WPF desktop client with SQLite persistence (ADR-002).

---

## Decision

Integrate **Microsoft 365 mail** via **Microsoft Graph** using **MSAL** (`Microsoft.Identity.Client`) as a **public client** with **delegated permissions**:

| Permission | Purpose |
|------------|---------|
| `Mail.Read.Shared` | Fetch inbox messages and attachments (own mailbox and shared/delegated mailboxes) |
| `Mail.Send.Shared` | Send auto-replies and contract manufacturing replies from shared or delegated mailboxes |
| `offline_access` | Refresh tokens without repeated interactive login |
| `User.Read` | Identify signed-in account |

Mail settings (tenant id, client id, mailbox address, folder name) are stored in SQLite. OAuth refresh tokens are stored in **Windows Credential Manager** via an Infrastructure wrapper — not in the repository or logs.

The **Inbox** vertical slice owns domain models and application commands/queries. **Infrastructure** implements `IMailClient` (`GraphMailClient`), repositories, and categorization/extraction services.

Support cases use an **in-app queue** in SQLite; no external ticket system API in the pilot.

---

## Rationale

- Aligns with Heckel Entra ID preference for production mail scenarios
- Delegated permissions limit access to the configured mailbox the user consents to
- Graph provides unified fetch, attachment download, and send/reply APIs
- MSAL public client fits portable WPF deployment without a backend token broker

Alternatives considered:

| Alternative | Rejected because |
|-------------|------------------|
| IMAP/SMTP | User selected M365/Graph; less aligned with Entra |
| Application permissions | Requires admin consent and broad org access for a desktop pilot |
| External ticket API | Out of pilot scope; in-app queue sufficient for demo |

---

## Consequences

**Positive**

- End-to-end demo: email in → categorize → contract manufacturing → email out
- Reuses existing inquiry, matching, and export slices

**Negative**

- Requires Entra app registration and user/admin consent per tenant
- Customer email content stored locally in SQLite (see `docs/security.md`)
- Graph SDK and MSAL add dependencies and package vulnerability surface

**Mitigations**

- User must connect explicitly in Settings; no background fetch without action
- Auto-replies require preview and confirm before send
- AI categorization/extraction follows existing hosted-AI consent model
- Attachment size limits configurable; PDFs copied to app data folder only

---

## Document History

| Version | Date | Change |
|---------|------|--------|
| 0.1 | 2026-06-22 | Initial ADR for Graph mail integration |

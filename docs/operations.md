# Operations

Handbook version: **v1.3.1**

## Environments

| Environment | Purpose | Location |
|-------------|---------|----------|
| Development | Local build and test | Developer workstation |
| Demonstration | Workshops and management demos | MSI install on business laptop |
| Production | Not applicable for pilot | — |

There is no cloud hosting, staging URL, or Azure infrastructure for this pilot.

---

## Deployment

### Distribution format

Primary deliverable: **MSI installer** published via [GitHub Releases](https://github.com/HeckelRobert/contract-manufacturing-assistant/releases).

```text
Contract-manufacturing-Setup.msi
└── Installs to Program Files:
    ├── Contract manufacturing.exe
    ├── sample-data/
    ├── appsettings.json
    └── quotation-accelerator.db    (created on first run if missing)
```

End users download the MSI from the README or Releases page. A portable ZIP build is no longer the primary distribution path for demos; developers can still build the MSI locally with `scripts/publish-installer.ps1`.

### Prerequisites (target machine)

| Prerequisite | Required | Notes |
|--------------|----------|-------|
| Windows 10 or 11 x64 | Yes | |
| Administrator rights | Yes (install only) | Per-machine MSI install under Program Files |
| WebView2 Runtime | Yes | For embedded PDF preview |
| .NET runtime | Bundled | Self-contained publish |
| Ollama | No | Recommended for Hybrid demo path |
| Network share access | No | Only if project root points to SMB path |

### Deployment steps

1. Download **Contract-manufacturing-Setup.msi** from [GitHub Releases](https://github.com/HeckelRobert/contract-manufacturing-assistant/releases/latest) (see [user guide](user-guide.md) for non-technical steps).
2. Run the installer and complete the wizard (requires administrator rights).
3. Start **Contract manufacturing** from the Start menu or desktop shortcut.
4. On first launch, bundled `sample-data/` is used automatically if no project root is configured.
5. Optionally install Ollama and pull recommended models:

   ```bash
   ollama pull qwen3:8b
   ollama pull nomic-embed-text
   ```

6. Configure **Settings** as needed for workshop (language, matching strategy, project root).

### Rollback

1. Close the application.
2. Uninstall via **Windows Settings → Apps**, or install a previous MSI release from GitHub Releases.

### Release process (project team)

Push a version tag to trigger the release workflow:

```powershell
git tag v0.1.2
git push origin v0.1.2
```

The workflow runs tests, builds the MSI, and publishes it to GitHub Releases. See `.github/workflows/release.yml`.

---

## Configuration

| Setting | Description | Secret |
|---------|-------------|--------|
| Active project root | Path to `PRJ-*` project folders | No |
| UI language | `de` / `en` | No |
| Matching strategy | Rule-based / AI-assisted / Hybrid | No |
| Ollama base URL | Default `http://localhost:11434` | No |
| Chat model | e.g. `qwen3:8b` | No |
| Embedding model | e.g. `nomic-embed-text` | No |
| OpenAI-compatible base URL + API key | Hosted provider | Yes (key) |
| Azure OpenAI endpoint + key + deployment | Hosted provider | Yes (key) |
| Debug logging enabled | Technical logs in app folder | No |

Configuration is stored in `quotation-accelerator.db` and defaults in `appsettings.json`.

---

## Monitoring

| Signal | Tool | Alert |
|--------|------|-------|
| Application logs | Optional local debug log files | None (pilot) |
| Metrics | Not collected | — |
| Health probes | N/A (desktop app) | — |
| AI cost | User's hosted provider billing | User-managed |

---

## Backup and Restore

### Backup

| Asset | Procedure |
|-------|-----------|
| Application + settings | Reinstall MSI, or copy `%ProgramFiles%\Contract manufacturing\` including `quotation-accelerator.db` |
| Historical projects | Backup project root file share separately (out of app scope) |

### Restore

1. Reinstall from MSI, or restore the install folder under Program Files.
2. Restore `quotation-accelerator.db` if settings and index should be preserved.
3. Point project root to valid `PRJ-*` directory in **Settings**.

---

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|--------------|--------|
| No projects found | Wrong project root or empty folder | Select path containing `PRJ-*` folders; click **Rescan Projects** |
| AI-assisted / Hybrid disabled | Ollama not running; no API key | Start Ollama; pull models; or configure hosted provider |
| PDF preview blank | WebView2 missing or file locked | Install WebView2; open file externally |
| Network share slow | SMB latency | Wait for rescan to complete; use local copy for demos |
| Hosted AI blocked | Consent not granted | Confirm disclosure in Settings |
| Poor match results | Wrong strategy or sparse metadata | Verify `metadata.json`; try Hybrid with Ollama |

---

## Support Responsibilities

| Area | Owner |
|------|-------|
| MSI build and GitHub release | Project team (tag push triggers `.github/workflows/release.yml`) |
| Demo laptop setup | Presenter / customer IT |
| Ollama installation | End user |
| Real customer data in live demos | Presenter (GDPR responsibility) |
| Historical project folder content | Customer |

---

## Document History

| Version | Date | Change |
|---------|------|--------|
| 0.1 | 2026-06-21 | Initial operations document for portable desktop pilot |
| 0.2 | 2026-06-29 | MSI via GitHub Releases as primary distribution; user guide added |

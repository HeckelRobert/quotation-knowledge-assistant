# Contract manufacturing

Prototype desktop application for contract manufacturing: **find similar past projects quickly** and reuse drawings, manufacturing steps, and historical job knowledge when preparing a new contract manufacturing job.

**Core question the demo answers:** *Have we manufactured something like this before?*

## Screenshots

### Inbox

Retrieve customer inquiries, categorize messages, and send automated replies for straightforward requests.

![Inbox — retrieve and respond to customer inquiries](docs/images/inbox.png)

### Inquiry

Review inquiry details pre-filled from email, attach drawings, and start analysis.

![Inquiry — review and analyze customer request](docs/images/inquiry.png)

### Catalog

Browse similar past projects with similarity scores, match reasoning, and drawing preview.

![Catalog — review matches from historical projects](docs/images/catalog.png)

### Contract manufacturing workspace

Review suggested manufacturing steps and the contract manufacturing draft after analysis.

![Contract manufacturing workspace](docs/images/contract-manufacturing-workspace.png)

## What you get in the workshop

| Step | What happens |
|------|----------------|
| Enter a customer inquiry | Material, quantity, surface treatment, short description |
| Analyze | The app searches your historical project catalog |
| Review top 3 matches | Similarity score and plain-language reasons |
| Open documents | Project folder and drawing PDF from a past job |
| Contract manufacturing workspace | Suggested manufacturing steps and contract manufacturing draft — copy into your process |

Bundled sample data is included so you can see results **without configuring anything** on first launch.

## Quick start (workshop / pilot)

You receive **`Contract manufacturing Setup.msi`** from your presenter or IT (the technical repository and build identifiers may still use `QuotationAccelerator`).

1. Double-click the installer and complete the wizard.
2. Start **Contract manufacturing** from the desktop shortcut or the Windows Start menu.
3. Follow the short demo below — no SDK, no command line, no repository checkout required.

Uninstall later via **Windows Settings → Apps** if needed.

### 5-minute demo path

1. Tab **Inquiry**: Material *Stainless Steel 1.4301*, surface *Powder Coated*, quantity *20*, description *Stainless enclosure*.
2. Click **Analyze Inquiry**.
3. Tab **Catalog**: best match **PRJ-2019-0142** — try another match, review the drawing preview, then **Open project folder** or **Open drawing**.
4. Tab **Contract manufacturing**: review the draft → copy content to the clipboard.

Default UI language is German (labels differ slightly); switch to English under **Settings**.

## Requirements (pilot PC)

- Windows 10 or 11 (64-bit)
- No .NET SDK required — the installer is self-contained

## For developers and presenters

Use this section only if you maintain the prototype or **build the MSI** before a workshop.

### Run from source

```powershell
dotnet restore QuotationAccelerator.sln
dotnet build QuotationAccelerator.sln
dotnet run --project src/Desktop/QuotationAccelerator.Desktop.csproj
```

Prerequisites: Windows 10/11, [.NET 10 SDK](https://dotnet.microsoft.com/download) (version pinned in `global.json`).

### Build the installer for distribution

```powershell
.\scripts\publish-installer.ps1
```

Output: `publish/installer/Contract manufacturing Setup.msi` — share this file with workshop attendees.

Demo PDFs for the flagship sample project are generated automatically during that script. To regenerate them only:

```powershell
.\scripts\generate-sample-pdfs.ps1
```

### Manual installer build

```powershell
dotnet build installer/QuotationAccelerator.Installer.wixproj -c Release
```

MSI path: `installer/bin/Release/Contract manufacturing Setup.msi`

## Solution structure

```text
src/
  Desktop/           WPF shell (primary tabs)
  Catalog/           Project discovery and indexing
  Inquiry/           Customer inquiry domain
  Matching/          Rule-based and hybrid similarity search
  Infrastructure/    SQLite, file system, dispatcher, module registration
  SharedKernel/      Dispatcher abstractions and shared types
installer/           WiX MSI installer project
sample-data/         Bundled demonstration projects
scripts/             Installer and sample-data scripts
tests/               Unit and architecture tests
```

## Documentation

- [Requirements](docs/requirements.md)
- [Architecture](docs/architecture.md)
- [Security](docs/security.md)
- [Operations](docs/operations.md)

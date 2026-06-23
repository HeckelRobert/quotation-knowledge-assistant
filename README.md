# Contract manufacturing

**Built for engineers** who prepare *Lohnfertigung* (contract manufacturing) from customer drawings — find similar past projects in seconds and reuse drawings, manufacturing steps, and historical job knowledge instead of starting from zero.

**The question it answers:** *Have we manufactured something like this before?*

---

## The problem

Preparing a *Lohnfertigung* is repetitive and time-consuming. For each new inquiry an engineer must locate comparable past jobs, read drawings, work out manufacturing steps, and draft the technical content — often by digging through project folders and relying on memory. That work adds up across many inquiries and slows down quotation and technical review.

Much of this can be automated: the app matches new inquiries to your catalog and drafts manufacturing steps and *Lohnfertigung* content from the best historical match. For AI-assisted matching and text generation, a **local model** (e.g. via [Ollama](https://ollama.com)) keeps customer data, drawings, and inquiry details **on your machine** — no cloud upload required. Hosted providers remain optional if you explicitly configure them.

## What is it?

Contract manufacturing is a Windows desktop application for engineers. It connects a new customer inquiry to your historical project catalog: you enter material, quantity, surface treatment, and a short description (or pull details from an email inbox), and the app searches past jobs for the best matches.

For each match you get a similarity score, plain-language reasons, and direct access to project folders and drawing PDFs. The contract manufacturing workspace then suggests manufacturing steps and a *Lohnfertigung* draft you can review, edit, and copy into your existing process — cutting the manual rework that usually takes the most time.

Bundled sample data is included so you can explore the full workflow **without configuring anything** on first launch.

## Why use it?

| Challenge | How the app helps |
|-----------|-------------------|
| *Lohnfertigung* prep takes too long | Reuses manufacturing steps and drafts from comparable past jobs |
| Every new inquiry starts from scratch | Surfaces the three most similar projects immediately |
| Knowledge lives in folders and people's heads | Makes historical jobs searchable and explains *why* a match fits |
| Drawings are hard to find | Opens the right project folder and drawing PDF in one click |
| Sensitive data must stay in-house | Local AI (Ollama) runs on your PC; inquiry and document text never leave the machine unless you choose a hosted provider |

The goal is faster, more consistent technical review and shorter paths from inquiry to a usable *Lohnfertigung* draft.

## Who is it for?

**Primary audience: engineers** who perform technical reviews and prepare *Lohnfertigung* documentation from customer drawings.

Also relevant for:

- **Sales and contract manufacturing staff** who need quick orientation on whether you have done similar work before
- **Engineering management** evaluating whether structured knowledge reuse and local AI are worth investing in

If your team repeatedly asks *"have we done this before?"* and spends hours rebuilding manufacturing steps for each new job, this prototype shows what an engineer-focused workflow could look like.

---

## Interested? Request a demo

We are happy to walk you through the application and discuss how it could fit your process.

**Email:** [info@heckel-informatik.de](mailto:info@heckel-informatik.de?subject=Demo%20-%20Contract%20manufacturing)

**Subject:** `Demo - Contract manufacturing`

No commitment required — just tell us briefly what you manufacture and we will set up a short session.

---

## Or try it yourself

### Requirements

- Windows 10 or 11 (64-bit)
- No .NET SDK required — the installer is self-contained

### Install and run

1. Download **`Contract manufacturing Setup.msi`** (from your Heckel contact, or build it yourself — see [For developers](#for-developers) below).
2. Double-click the installer and complete the wizard.
3. Start **Contract manufacturing** from the desktop shortcut or the Windows Start menu.

Uninstall later via **Windows Settings → Apps** if needed.

> The technical repository and build identifiers may still use the name `QuotationAccelerator`.

### 5-minute walkthrough

1. Tab **Inquiry**: Material *Stainless Steel 1.4301*, surface *Powder Coated*, quantity *20*, description *Stainless enclosure*.
2. Click **Analyze Inquiry**.
3. Tab **Catalog**: best match **PRJ-2019-0142** — try another match, review the drawing preview, then **Open project folder** or **Open drawing**.
4. Tab **Contract manufacturing**: review the suggested *Lohnfertigung* draft → copy content to the clipboard.

Default UI language is German; switch to English under **Settings**.

### What you will see

| Step | What happens |
|------|----------------|
| Enter a customer inquiry | Material, quantity, surface treatment, short description |
| Analyze | The app searches your historical project catalog |
| Review top 3 matches | Similarity score and plain-language reasons |
| Open documents | Project folder and drawing PDF from a past job |
| Contract manufacturing workspace | Suggested manufacturing steps and *Lohnfertigung* draft — review, edit, copy into your process |

---

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

---

## For developers

Use this section if you maintain the prototype or **build the MSI** for distribution.

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

Output: `publish/installer/Contract manufacturing Setup.msi`

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

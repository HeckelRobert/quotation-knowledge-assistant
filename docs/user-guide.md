# Contract manufacturing — User guide

**Beta demo — not for production use.** This guide helps you install and try the demonstration prototype. The application is for evaluation and workshops only. It is not a finished product and is not supported for day-to-day business use.

---

## Before you download

### What this application is

Contract manufacturing is a **Windows desktop demo** that shows how engineers can find similar past manufacturing projects and reuse drawings, steps, and knowledge when preparing new jobs.

It answers one question: **"Have we manufactured something like this before?"**

The installer includes **sample project data** so you can explore the full workflow immediately — no setup required.

### What this application is not

- **Not a production system** — do not rely on it for real quotations or live customer work.
- **Not officially supported software** — features may change or be removed without notice.
- **Not connected to your company data** — unless you deliberately point it at your own project folders in Settings (optional, for advanced demos).

If you need a guided walkthrough or want to discuss a real implementation, email [info@heckel-informatik.de](mailto:info@heckel-informatik.de?subject=Demo%20-%20Contract%20manufacturing).

---

## What you need

| Requirement | Details |
|-------------|---------|
| **Computer** | Windows 10 or Windows 11, 64-bit |
| **Install rights** | You need permission to install software (administrator rights). Running the app after install does not require admin rights. |
| **Internet** | Only needed to download the installer. The demo works offline after installation. |
| **Microsoft Edge WebView2** | Required for PDF previews. Usually already installed on Windows 11. On Windows 10, install it from [Microsoft](https://developer.microsoft.com/microsoft-edge/webview2/) if the app shows an error about WebView2. |

You do **not** need to install .NET or any other development tools.

---

## Download

1. Open the download page: [Latest release](https://github.com/HeckelRobert/contract-manufacturing-assistant/releases/latest)
2. Under **Assets**, click **Contract-manufacturing-Setup.msi** to download the installer.

Direct link: [Download latest installer (MSI)](https://github.com/HeckelRobert/contract-manufacturing-assistant/releases/latest/download/Contract-manufacturing-Setup.msi)

---

## Install

1. Open your **Downloads** folder and double-click **Contract-manufacturing-Setup.msi**.
2. If Windows shows a security warning ("Windows protected your PC"):
   - Click **More info**
   - Click **Run anyway**  
   This appears because the demo installer is not code-signed. It is safe for evaluation purposes from Heckel Informatik.
3. Follow the installation wizard:
   - Accept the license agreement (beta demonstration terms).
   - Choose an install location if prompted, or keep the default.
   - Click **Install**, then **Finish**.
4. The installer creates a **desktop shortcut** and a **Start menu** entry named **Contract manufacturing**.

---

## Open the application

After installation, start the app in either way:

- Double-click the **Contract manufacturing** shortcut on your desktop, or
- Open the Windows **Start** menu, find **Contract manufacturing**, and click it.

On first launch, the app loads bundled sample projects automatically. You do not need to configure anything to try the demo.

---

## Try the built-in demo (about 5 minutes)

Follow these steps to see the main workflow.

### Step 1 — Enter an inquiry

1. Click the **Inquiry** tab at the top.
2. Enter or select these example values:
   - **Material:** Stainless Steel 1.4301
   - **Surface treatment:** Powder Coated
   - **Quantity:** 20
   - **Description:** Stainless enclosure
3. Click **Analyze Inquiry**.

![Inquiry — review and analyze customer request](images/inquiry.png)

### Step 2 — Review similar past projects

1. The app opens the **Results** tab (you may also see it labelled **Catalog** in some views).
2. Review the **top 3 similar projects** with similarity scores and short explanations.
3. Select the best match (for example **PRJ-2019-0142**).
4. Try **Open project folder** or **Open drawing** to view files from that past job.
5. Use the drawing preview panel to inspect the PDF.

![Catalog — review matches from historical projects](images/catalog.png)

### Step 3 — Review the contract manufacturing draft

1. Click the **Contract manufacturing** tab.
2. Scroll through the suggested **manufacturing steps** and the **contract manufacturing draft**.
3. Edit text if you like, then use **Copy to clipboard** to copy content into another document.

![Contract manufacturing workspace](images/contract-manufacturing-workspace.png)

### Optional — Explore the Inbox

The **Inbox** tab demonstrates email integration (requires Microsoft 365 configuration in Settings). For a quick demo, the Inquiry workflow above is enough.

![Inbox — retrieve and respond to customer inquiries](images/inbox.png)

---

## Change the language

The default language is **German**. To switch to English:

1. Click the **Settings** tab.
2. Change **UI language** to **English**.
3. The interface updates immediately.

---

## Uninstall

When you no longer need the demo:

1. Open **Windows Settings**.
2. Go to **Apps** → **Installed apps** (or **Apps & features** on Windows 10).
3. Find **Contract manufacturing**, click the menu (⋯), and choose **Uninstall**.
4. Follow the prompts.

---

## When something goes wrong

| Problem | What to try |
|---------|-------------|
| **Windows blocks the installer** | Click **More info** → **Run anyway**, or ask your IT department to allow the install for your demo session. |
| **Install fails — access denied** | You need administrator rights to install. Ask IT to install it for you, or use an account with install permissions. |
| **App will not start — WebView2 error** | Install [Microsoft Edge WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/). |
| **PDF preview is blank** | Install WebView2, or use **Open drawing** to view the PDF in your default PDF viewer. |
| **No projects shown** | On first run, sample data should load automatically. Open **Settings** and click **Rescan Projects**, or restart the application. |
| **Something else** | Email [info@heckel-informatik.de](mailto:info@heckel-informatik.de?subject=Contract%20manufacturing%20demo%20help) with a short description of what happened. |

---

## Need help or a live demo?

Email [info@heckel-informatik.de](mailto:info@heckel-informatik.de?subject=Demo%20-%20Contract%20manufacturing) to request a guided demonstration or to discuss how this prototype could fit your manufacturing process.

No commitment required.

# Builds a Windows MSI installer for pilot distribution.
param(
    [string]$OutputDirectory = "publish/installer",
    [string]$Runtime = "win-x64",
    [string]$ProductVersion = ""
)

$ErrorActionPreference = "Stop"
$InstallerFileName = "Contract-manufacturing-Setup.msi"
$repoRoot = Split-Path -Parent $PSScriptRoot

Push-Location $repoRoot

try {
    Write-Host "Restoring solution..."
    dotnet restore QuotationAccelerator.sln

    Write-Host "Running tests..."
    dotnet test QuotationAccelerator.sln --no-restore

    Write-Host "Ensuring demonstration PDFs..."
    & (Join-Path $PSScriptRoot "generate-sample-pdfs.ps1")

    Write-Host "Ensuring application icon..."
    & (Join-Path $PSScriptRoot "convert-app-icon.ps1")

    $outputPath = Join-Path $repoRoot $OutputDirectory
    if (Test-Path $outputPath) {
        Remove-Item $outputPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $outputPath | Out-Null

    Write-Host "Building installer..."
    $buildArgs = @(
        "build",
        "installer/QuotationAccelerator.Installer.wixproj",
        "-c", "Release"
    )
    if ($ProductVersion) {
        Write-Host "Using product version: $ProductVersion"
        $buildArgs += "-p:ProductVersion=$ProductVersion"
    }
    & dotnet @buildArgs

    $msiSource = Join-Path $repoRoot "installer\bin/Release\$InstallerFileName"
    if (-not (Test-Path $msiSource)) {
        throw "Installer build did not produce '$msiSource'."
    }

    $msiTarget = Join-Path $outputPath $InstallerFileName
    Copy-Item -Path $msiSource -Destination $msiTarget -Force

    Write-Host ""
    Write-Host "Done. Share this installer with end users:"
    Write-Host "  $msiTarget"
    Write-Host ""
    Write-Host "They double-click the installer, complete the wizard, then start"
    Write-Host "'Contract manufacturing' from the Start menu."
}
finally {
    Pop-Location
}

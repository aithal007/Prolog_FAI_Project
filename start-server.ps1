<#
Start-server.ps1
Automates creating a venv, installing requirements and the spaCy model, and running the Flask server.

Usage (PowerShell):
  .\start-server.ps1

If you already have a virtualenv, set the environment variable SKIP_INSTALL=1 to skip installs.
#>

param(
    [int]$Port = 8000
)

Write-Host "Project folder: $(Get-Location)"

if (-not (Test-Path -Path ".venv")) {
    Write-Host "Creating virtual environment .venv ..."
    python -m venv .venv
}

Write-Host "Activating virtual environment..."
. .\.venv\Scripts\Activate.ps1

if (-not $env:SKIP_INSTALL) {
    Write-Host "Installing requirements..."
    pip install --upgrade pip
    pip install -r requirements.txt
    Write-Host "Downloading spaCy model en_core_web_sm (may take a minute)..."
    python -m spacy download en_core_web_sm
}

Write-Host "Checking for swipl (SWI-Prolog) on PATH..."
$swipl = (Get-Command swipl -ErrorAction SilentlyContinue)
if ($swipl) {
    Write-Host "Found swipl at: $($swipl.Source)"
} else {
    Write-Host "swipl not found. The server will try pyswip first and fall back to calling swipl if available." -ForegroundColor Yellow
}

Write-Host "Starting Flask server on port $Port..."
python hybrid_translator.py

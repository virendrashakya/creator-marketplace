# Local development launcher for Windows.
#
# Handles two Windows-specific needs:
#   1. RUBY_DLL_PATH so the pg gem can find libpq.dll (PATH alone is not enough).
#   2. DATABASE_URL so Rails authenticates as the creator_marketplace role.
#
# Usage:  $env:PGPASSWORD_LOCAL = "<role password>"; .\bin\dev-local.ps1
# Optional args are passed through to `rails server`, e.g. .\bin\dev-local.ps1 -p 3001

param([Parameter(ValueFromRemainingArguments = $true)] $ServerArgs)

$ErrorActionPreference = "Stop"

$pgBin = "C:\Program Files\PostgreSQL\17\bin"
if (-not (Test-Path (Join-Path $pgBin "libpq.dll"))) {
  throw "libpq.dll not found in $pgBin - adjust the path in this script to your PostgreSQL install."
}

if (-not $env:PGPASSWORD_LOCAL) {
  throw "Set PGPASSWORD_LOCAL first, e.g.  `$env:PGPASSWORD_LOCAL = '<role password>'"
}

$env:RUBY_DLL_PATH = $pgBin
$env:Path = "$pgBin;$env:Path"

# URL-encode the password so special characters survive the connection string.
Add-Type -AssemblyName System.Web
$pw = [System.Web.HttpUtility]::UrlEncode($env:PGPASSWORD_LOCAL)
$env:DATABASE_URL = "postgres://creator_marketplace:$pw@localhost:5432/creator_marketplace_development"

Set-Location (Split-Path $PSScriptRoot -Parent)
& ruby bin/rails server @ServerArgs

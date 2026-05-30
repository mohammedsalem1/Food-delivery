# Run database seed from your PC against Render Postgres
# Usage: .\scripts\seed-local.ps1
# Or:    .\scripts\seed-local.ps1 -Mode admin   (admin only, no wipe)
# Or:    .\scripts\seed-local.ps1 -Mode full    (demo seed, wipes DB)

param(
    [ValidateSet("admin", "demo", "full")]
    [string]$Mode = "demo"
)

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

if (-not $env:DATABASE_URL) {
    Write-Host ""
    Write-Host "Paste Render EXTERNAL Database URL (Postgres -> Connections -> External):" -ForegroundColor Yellow
    $env:DATABASE_URL = Read-Host "DATABASE_URL"
}

if ($env:DATABASE_URL -match "localhost|127\.0\.0\.1") {
    Write-Host "ERROR: Use Render External URL, not localhost." -ForegroundColor Red
    exit 1
}

Write-Host "Using DB: $($env:DATABASE_URL.Substring(0, [Math]::Min(50, $env:DATABASE_URL.Length)))..." -ForegroundColor Cyan

Write-Host "Migrations..." -ForegroundColor Green
npx prisma migrate deploy
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

switch ($Mode) {
    "admin" {
        Write-Host "Admin only (no wipe)..." -ForegroundColor Green
        npm run seed:admin
    }
    "full" {
        Write-Host "Full seed (slow, wipes DB)..." -ForegroundColor Green
        npm run seed:full
    }
    default {
        Write-Host "Demo seed (wipes DB, ~1 min)..." -ForegroundColor Green
        npm run seed
    }
}

Write-Host ""
Write-Host "Done. Admin: admin@admin.com / 123456" -ForegroundColor Green

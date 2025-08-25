#Requires -Version 5.1
$ErrorActionPreference = "Stop"

Write-Host "pre-commit: JSON sanitize & validate..." -ForegroundColor Cyan

$repoRoot = (git rev-parse --show-toplevel)
Set-Location $repoRoot

# JSON files in staging
$jsonFiles = @( git diff --cached --name-only --diff-filter=ACMR | Where-Object { $_ -match '\.json$' } )
if ($jsonFiles.Count -eq 0) { Write-Host "  (no staged *.json)" }

foreach ($f in $jsonFiles) {
  if (-not (Test-Path $f)) { continue }
  Write-Host ("  * " + $f)

  $sr = New-Object IO.StreamReader($f, $true)  # autodetect BOM
  $t = $sr.ReadToEnd(); $sr.Close()

  # strip zero-width/control (keep \r \n \t)
  $t = $t -replace "[\uFEFF\u200B-\u200D\u2060]", ""
  $t = $t -replace "[^\u0009\u000A\u000D\u0020-\uFFFF]", ""

  # cut after last }
  $last = $t.LastIndexOf('}')
  if ($last -lt 0) { throw "Invalid JSON (no closing brace) in $f" }
  if ($last -lt $t.Length - 1) {
    Write-Host ("    trimming trailing bytes after position " + $last)
    $t = $t.Substring(0, $last + 1) + "`r`n"
  }

  $null = $t | ConvertFrom-Json

  $enc = New-Object System.Text.UTF8Encoding($false) # UTF-8 no BOM
  [IO.File]::WriteAllText($f, $t, $enc)
  git add -- "$f"
}

# Optional: PHP-CS-Fixer on staged PHP
$phpFiles = @( git diff --cached --name-only --diff-filter=ACMR | Where-Object { $_ -match '\.php$' } )
if ($phpFiles.Count -gt 0 -and (Get-Command composer -ErrorAction SilentlyContinue)) {
  Write-Host "PHP-CS-Fixer: autofix staged PHP..."
  & composer exec php-cs-fixer -- fix --path-mode=intersection -- $phpFiles
  git add -- $phpFiles
  Write-Host "PHP-CS-Fixer: check staged..."
  & composer exec php-cs-fixer -- fix --dry-run --diff --path-mode=intersection -- $phpFiles
}

Write-Host "pre-commit OK" -ForegroundColor Green
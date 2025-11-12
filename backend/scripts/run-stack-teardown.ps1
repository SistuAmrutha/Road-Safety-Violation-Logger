<#
.\run-stack-teardown.ps1
Stops the compose stack and removes volumes.
Usage (from backend folder):
  .\scripts\run-stack-teardown.ps1
#>

# Ensure we are in backend folder (script located in backend\scripts)
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
Push-Location -Path (Join-Path $scriptDir '..')

Write-Host "Stopping and removing compose stack and volumes..."
docker compose down -v
$code = $LASTEXITCODE
if ($code -eq 0) { Write-Host "Teardown complete" } else { Write-Error "docker compose down failed with exit code $code" }
Pop-Location
exit $code

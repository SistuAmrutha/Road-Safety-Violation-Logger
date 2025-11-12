<#
.\run-stack.ps1
Starts docker-compose for the backend, waits for MySQL and the app, runs a smoke test.
Usage (from backend folder):
  .\scripts\run-stack.ps1            # starts detached (default)
  .\scripts\run-stack.ps1 -Detached:$false  # starts in foreground

Parameters:
  -Detached (switch): start compose detached (default)
  -MaxTries (int): number of readiness polls (default 60)
  -DelaySeconds (int): delay between polls in seconds (default 3)
#>

param(
    [switch]$Detached = $true,
    [int]$MaxTries = 60,
    [int]$DelaySeconds = 3
)

# Ensure we are in backend folder (script located in backend\scripts)
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
Push-Location -Path (Join-Path $scriptDir '..')

Write-Host "Starting docker compose (detached = $Detached) ..."
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Warning "Docker CLI not found on this machine. Falling back to local runner `scripts/run-local.ps1`."
    $localRunner = Join-Path $scriptDir 'run-local.ps1'
    if (Test-Path $localRunner) {
        Write-Host "Invoking local runner with MySQL profile. Ensure a local MySQL server is running (or remove -Profile)."
        & $localRunner -Profile 'mysql'
        Pop-Location
        exit 0
    } else {
        Write-Error "Docker not found and local runner not available at $localRunner. Install Docker or run the app locally with the mvnw wrapper."
        Pop-Location
        exit 1
    }
}

if ($Detached) {
    docker compose up --build -d
    if ($LASTEXITCODE -ne 0) { Write-Error "docker compose up failed"; Pop-Location; exit 1 }
} else {
    docker compose up --build
    $code = $LASTEXITCODE
    Pop-Location
    exit $code
}

# Wait for MySQL to accept connections
Write-Host "Waiting for MySQL (container name: oops-mysql) to accept connections..."
for ($i = 1; $i -le $MaxTries; $i++) {
    $mysqlId = docker ps -qf "name=oops-mysql"
    if ($mysqlId) {
        docker exec $mysqlId mysqladmin ping -h localhost -uroot -pchangeme --silent 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Host "MySQL is ready"; break }
    }
    Start-Sleep -Seconds $DelaySeconds
    Write-Host "MySQL not ready yet ($i/$MaxTries)..."
}

# Wait for app readiness
Write-Host "Waiting for app to respond at http://localhost:8080/api/reports ..."
for ($i = 1; $i -le $MaxTries; $i++) {
    try {
        $resp = curl.exe --silent --fail http://localhost:8080/api/reports
        if ($LASTEXITCODE -eq 0) { Write-Host "App is ready"; break }
    } catch {}
    Start-Sleep -Seconds $DelaySeconds
    Write-Host "App not ready yet ($i/$MaxTries)..."
}

# Smoke test
Write-Host "Running smoke test against /api/reports"
try {
    $data = curl.exe -sSf http://localhost:8080/api/reports
    Write-Host "Smoke test response:"; Write-Host $data
    Write-Host "Smoke test OK"
} catch {
    Write-Error "Smoke test failed: $_"
    Write-Host "---- app logs ----"
    docker compose logs --tail 200 app
    Write-Host "---- mysql logs ----"
    docker compose logs --tail 200 mysql
    Pop-Location
    exit 1
}

Write-Host "Stack is up and healthy. To stop and remove volumes run: docker compose down -v or use scripts/run-stack-teardown.ps1"
Pop-Location

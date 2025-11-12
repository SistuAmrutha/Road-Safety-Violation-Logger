<#
scripts/run-local.ps1

Start the Spring Boot app locally using the Maven wrapper. Optionally set a Spring profile
(for example 'mysql') so the app uses `application-mysql.properties`.

Usage:
  .\scripts\run-local.ps1                    # start with default profile (H2)
  .\scripts\run-local.ps1 -Profile mysql     # set SPRING_PROFILES_ACTIVE=mysql before running
  .\scripts\run-local.ps1 -NoSmokeTest       # skip the GET /api/reports smoke test
#>

param(
    [string]$Profile = '',
    [switch]$NoSmokeTest
)

Set-StrictMode -Version Latest

# Resolve directories
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $scriptDir "..")

Write-Host "Working directory: $PWD"

# If profile requested, set environment variable
if ($Profile) {
    Write-Host "Setting SPRING_PROFILES_ACTIVE=$Profile"
    $env:SPRING_PROFILES_ACTIVE = $Profile
}

# If user requested mysql profile, wait for MySQL TCP port and optionally validate credentials
if ($Profile -and $Profile.ToLower() -eq 'mysql') {
    Write-Host "Profile is 'mysql' - checking local MySQL availability on localhost:3306..."
    $mysqlReady = $false
    for ($i = 0; $i -lt 60; $i++) {
        try {
            $client = New-Object System.Net.Sockets.TcpClient
            $async = $client.BeginConnect('localhost', 3306, $null, $null)
            $wait = $async.AsyncWaitHandle.WaitOne(2000)
            if ($wait) {
                $client.EndConnect($async)
                $client.Close()
                $mysqlReady = $true
                break
            }
            $client.Close()
        } catch {
            # ignore and retry
        }
        Start-Sleep -Seconds 2
        Write-Host "Waiting for MySQL TCP (localhost:3306) - attempt $($i+1)/60"
    }

    if (-not $mysqlReady) {
        Write-Warning "MySQL TCP port 3306 didn't respond in time. Ensure MySQL server is running and accessible."
        Write-Host "You can start MySQL via Services, MySQL Workbench, or Docker. Proceeding anyway to start the app (it may fail to connect)."
    } else {
        Write-Host "MySQL TCP port is open."
        # If mysql client exists, try a quick credential check using configured defaults
        if (Get-Command mysql -ErrorAction SilentlyContinue) {
            Write-Host "mysql client found - attempting quick credential check with user 'oops'"
            try {
                & mysql -u oops -poops_pass -e "SELECT 1;"
                if ($LASTEXITCODE -eq 0) { 
                    Write-Host "MySQL credential check succeeded for user 'oops'."
                } else {
                    Write-Warning "MySQL credential check failed for user 'oops' - check credentials or update application-mysql.properties."
                }
            } catch {
                Write-Warning "Unable to run mysql client credential check: $_"
            }
        } else {
            Write-Host "mysql CLI not found - skipping credential check."
        }
    }
}

# Ensure the maven wrapper exists (download helper available)
$mvnw = Join-Path $PWD 'mvnw.cmd'
if (-not (Test-Path $mvnw)) {
    Write-Host "Maven wrapper not found at $mvnw. Attempting to download wrapper jar using scripts/get-maven-wrapper.ps1..."
    $getWrapper = Join-Path $scriptDir 'get-maven-wrapper.ps1'
    if (Test-Path $getWrapper) {
        & $getWrapper
        if (-not (Test-Path $mvnw)) {
            Write-Error "mvnw.cmd still not present after running get-maven-wrapper.ps1. Please install Maven or add the wrapper manually."
            exit 1
        }
    } else {
        Write-Error "Wrapper downloader not found at $getWrapper. Please install Maven or add the maven wrapper to the repo."
        exit 1
    }
}

Write-Host "Starting the application via the maven wrapper (this will run in the background)..."

# Start the app in a background process so we can run the smoke test from this script.
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $mvnw
$startInfo.Arguments = 'spring-boot:run'
$startInfo.WorkingDirectory = $PWD
$startInfo.UseShellExecute = $true

$process = [System.Diagnostics.Process]::Start($startInfo)
if (-not $process) {
    Write-Error 'Failed to start Maven process. Try running: .\\mvnw.cmd spring-boot:run'
    exit 1
}

Write-Host "Started mvnw (pid=$($process.Id)). Waiting for the application to respond on http://localhost:8080 ..."

# Wait for the app to respond (max ~2 minutes)
$success = $false
for ($i = 0; $i -lt 60; $i++) {
    try {
        $resp = Invoke-RestMethod -Uri 'http://localhost:8080/actuator/health' -Method Get -TimeoutSec 2 -ErrorAction Stop
        if ($resp.status -eq 'UP' -or $resp.Status -eq 'UP') { $success = $true; break }
    } catch {
        # ignore and retry
    }
    Start-Sleep -Seconds 2
}

if (-not $success) {
    Write-Warning "Application did not become healthy within timeout. Check Maven logs in the terminal or run .\mvnw.cmd spring-boot:run interactively to see output."
} else {
    Write-Host "Application is healthy."
    if (-not $NoSmokeTest) {
        Write-Host "Running smoke test: GET /api/reports"
        try {
            $result = Invoke-RestMethod -Uri 'http://localhost:8080/api/reports' -Method Get -ErrorAction Stop
            Write-Host "Smoke test succeeded. Response (first items):"
            $result | Select-Object -First 5 | ConvertTo-Json -Depth 5
        } catch {
            Write-Error "Smoke test failed: $_"
        }
    } else {
        Write-Host "Skipping smoke test as requested."
    }
}

Write-Host "To stop the app started by this script:"
Write-Host ('  Stop-Process -Id {0}' -f $process.Id)

Exit 0

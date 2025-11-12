<#
scripts/connect-backend.ps1

Creates the `oopsdb` database and a dedicated `oops` user, then starts the backend
with the `mysql` profile using the helper `run-local.ps1`.

This script will prompt once for the MySQL root password (used to run the CREATE/GRANT statements).

Usage (from the `backend` folder):
  .\scripts\connect-backend.ps1
#>

Set-StrictMode -Version Latest

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $scriptDir "..")

if (-not (Get-Command mysql -ErrorAction SilentlyContinue)) {
    Write-Error "mysql CLI not found. Please install MySQL client tools or use MySQL Workbench."
    exit 1
}

Write-Host "This script will create database 'oopsdb' and user 'oops' with password 'oops_pass'."
Write-Host "You will be prompted for the MySQL root password to run the SQL statements."

$sql = @"
CREATE DATABASE IF NOT EXISTS oopsdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'oops'@'localhost' IDENTIFIED BY 'oops_pass';
GRANT ALL PRIVILEGES ON oopsdb.* TO 'oops'@'localhost';
FLUSH PRIVILEGES;
"@

try {
    $sql | & mysql -u root -p
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to execute SQL statements (check root password and MySQL server)."
        exit 1
    }
    Write-Host "Database and user created/verified successfully."
} catch {
    Write-Error "Error running mysql client: $_"
    exit 1
}

Write-Host "Starting backend with MySQL profile..."
Write-Host "Starting backend with MySQL profile..."
# call the local runner from the backend folder
& "${PWD}\scripts\run-local.ps1" -Profile mysql

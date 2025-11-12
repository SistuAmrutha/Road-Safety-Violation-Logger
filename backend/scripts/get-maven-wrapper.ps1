<#
 downloads the takari maven-wrapper jar into .mvn/wrapper so the included mvnw.cmd will work
 Usage (PowerShell, run from backend folder):
 .\scripts\get-maven-wrapper.ps1
#>
$target = Join-Path -Path (Get-Location) -ChildPath '.mvn\wrapper\maven-wrapper.jar'
$dir = Split-Path -Path $target -Parent
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}
$uri = 'https://repo1.maven.org/maven2/io/takari/maven-wrapper/0.5.6/maven-wrapper-0.5.6.jar'
Write-Host "Downloading $uri to $target"
try {
    # Use System.Net.WebClient for older PowerShell compatibility
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($uri, $target)
    Write-Host "Downloaded maven-wrapper.jar to .mvn\\wrapper"
} catch {
    Write-Error "Failed to download maven-wrapper.jar: $_"
    exit 1
}

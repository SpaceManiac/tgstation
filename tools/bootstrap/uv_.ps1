# bootstrap/uv_.ps1
#
# Uses https://github.com/astral-sh/uv to:
# - Download and install Python.
# - Install PyPI dependencies.
# It does a better job than we could do ourselves.
#
# However, don't use their official installer yet because it doesn't check
# hashes: https://github.com/astral-sh/uv/issues/13074
#
# The underscore in the name is so that typing `bootstrap/uv` into
# PowerShell finds the `.bat` file first, which ensures this script executes
# regardless of ExecutionPolicy.
$ErrorActionPreference = "Stop"

# Change these variables to update uv.
$UV_VERSION = "0.9.18"
$ExpectedSha256 = "28cbe5d30907a774bfe27a517a39b494ec6f7d3816bda8bbf6f9645490449182"

# Convenience variables
$Bootstrap = Split-Path $script:MyInvocation.MyCommand.Path
$Tools = Split-Path $Bootstrap
$Cache = "$Bootstrap/.cache"
if ($Env:TG_BOOTSTRAP_CACHE) {
    $Cache = $Env:TG_BOOTSTRAP_CACHE
}
$UvDir = "$Cache/uv-Windows-$UV_VERSION"
$UvExe = "$UvDir/uv.exe"

# Download and unzip uv binary, validate it, and commit it if validation succeeded
if (!(Test-Path $UvExe -PathType Leaf)) {
    # Download
    New-Item $Cache -ItemType Directory -ErrorAction silentlyContinue | Out-Null
    $Url = "https://github.com/astral-sh/uv/releases/download/$UV_VERSION/uv-x86_64-pc-windows-msvc.zip"
    $Archive = "$UvDir.zip"
    (New-Object Net.Webclient).downloadFile($Url, $Archive)

    # Verify
    $sha256 = New-Object System.Security.Cryptography.SHA256CryptoServiceProvider
    function CheckHash {
        param([string] $File, [string] $Sha)
        $got = $sha256.ComputeHash([System.IO.File]::ReadAllBytes("$File"))
        $got = [System.BitConverter]::ToString($got).Replace('-', '').ToLower()
        if ($got -ne $Sha) {
            Write-Output "${File}: FAILED"
            exit 1
        } else {
            Write-Output "${File}: OK"
        }
    }
    CheckHash -File "$Archive" -Sha "$ExpectedSha256"

    # Unzip
    $TmpDir = "$UvDir.tmp"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($Archive, $TmpDir)
    Remove-Item $Archive

    # Commit
    Rename-Item $TmpDir $UvDir
}

# Invoke with all command-line arguments
$env:PYTHONPATH = "$Tools"
& "$UvExe" $args
exit $LastExitCode

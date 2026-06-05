param(
    [string]$Target = "$HOME\.agent-skills"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path -LiteralPath (Join-Path $scriptDir "..")
$targetPath = [System.IO.Path]::GetFullPath($Target)

function Test-ReparsePoint {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }
    $item = Get-Item -LiteralPath $Path -Force
    return (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

Write-Host "Source: $repoRoot"
Write-Host "Target: $targetPath"

if (Test-Path -LiteralPath $targetPath) {
    if (Test-ReparsePoint -Path $targetPath) {
        Remove-Item -LiteralPath $targetPath -Force
    } else {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupPath = "$targetPath.backup-$timestamp"
        Move-Item -LiteralPath $targetPath -Destination $backupPath
        Write-Host "Backed up existing target to: $backupPath"
    }
}

New-Item -ItemType Junction -Path $targetPath -Target $repoRoot | Out-Null
Write-Host "Installed Agent Skills link."
Write-Host "Restart Codex or the target AI agent so it reloads skills."

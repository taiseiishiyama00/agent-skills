param(
    [string]$Target = "$HOME\.agent-skills",
    [string]$ClaudeTarget = "$HOME\.claude\skills"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path -LiteralPath (Join-Path $scriptDir "..")

function Test-ReparsePoint {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }
    $item = Get-Item -LiteralPath $Path -Force
    return (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Remove-ReparsePoint {
    param([string]$Path)

    $item = Get-Item -LiteralPath $Path -Force
    if ($item.PSIsContainer) {
        [System.IO.Directory]::Delete($Path)
    } else {
        Remove-Item -LiteralPath $Path -Force
    }
}

function Install-SkillsLink {
    param(
        [string]$Name,
        [string]$Path
    )

    $targetPath = [System.IO.Path]::GetFullPath($Path)
    $parentPath = Split-Path -Parent $targetPath

    Write-Host "$Name target: $targetPath"

    if (-not (Test-Path -LiteralPath $parentPath)) {
        New-Item -ItemType Directory -Path $parentPath | Out-Null
    }

    if (Test-Path -LiteralPath $targetPath) {
        if (Test-ReparsePoint -Path $targetPath) {
            Remove-ReparsePoint -Path $targetPath
        } else {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $backupPath = "$targetPath.backup-$timestamp"
            Move-Item -LiteralPath $targetPath -Destination $backupPath
            Write-Host "Backed up existing $Name target to: $backupPath"
        }
    }

    New-Item -ItemType Junction -Path $targetPath -Target $repoRoot | Out-Null
    Write-Host "Installed $Name skills link."
}

Write-Host "Source: $repoRoot"
Install-SkillsLink -Name "Codex" -Path $Target
Install-SkillsLink -Name "Claude Code" -Path $ClaudeTarget
Write-Host "Restart Codex and Claude Code so they reload skills."

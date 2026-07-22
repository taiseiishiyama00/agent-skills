[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Workspace,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Include
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (@($Include).Count -eq 0) {
    throw 'Include requires at least one C# file.'
}

$workspacePath = (Resolve-Path -LiteralPath $Workspace).Path
$workspaceExtension = [System.IO.Path]::GetExtension($workspacePath)
if ($workspaceExtension -ne '.csproj') {
    throw "Workspace must be a .csproj file: $workspacePath"
}

$workspaceDirectory = [System.IO.Path]::GetDirectoryName($workspacePath)
$relativeFiles = @(@(
    foreach ($file in $Include) {
        $candidate = if ([System.IO.Path]::IsPathRooted($file)) {
            (Resolve-Path -LiteralPath $file).Path
        }
        else {
            (Resolve-Path -LiteralPath (Join-Path $workspaceDirectory $file)).Path
        }

        if ([System.IO.Path]::GetExtension($candidate) -ne '.cs') {
            throw "Include accepts only .cs files: $candidate"
        }

        $relativePath = [System.IO.Path]::GetRelativePath($workspaceDirectory, $candidate)
        if ($relativePath -eq '..' -or $relativePath.StartsWith("..$([System.IO.Path]::DirectorySeparatorChar)")) {
            throw "Included file must be under the workspace directory: $candidate"
        }

        if ($relativePath -match '(^|[\\/])(bin|obj)([\\/]|$)') {
            throw "Generated output directories cannot be included: $candidate"
        }

        $relativePath
    }
) | Sort-Object -Unique)

function Invoke-DotnetFormat {
    param(
        [Parameter(Mandatory)]
        [string[]]$FormatArguments
    )

    & dotnet format @FormatArguments
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet format failed with exit code ${LASTEXITCODE}: dotnet format $($FormatArguments -join ' ')"
    }
}

Push-Location $workspaceDirectory
try {
    $includeArguments = @('--include') + $relativeFiles

    Invoke-DotnetFormat -FormatArguments (@('whitespace', $workspacePath) + $includeArguments + @('--verbosity', 'minimal'))
    Invoke-DotnetFormat -FormatArguments (@('style', $workspacePath) + $includeArguments + @('--diagnostics', 'IDE0005', '--severity', 'info', '--no-restore', '--verbosity', 'minimal'))
    Invoke-DotnetFormat -FormatArguments (@('whitespace', $workspacePath) + $includeArguments + @('--no-restore', '--verify-no-changes', '--verbosity', 'minimal'))
    Invoke-DotnetFormat -FormatArguments (@('style', $workspacePath) + $includeArguments + @('--diagnostics', 'IDE0005', '--severity', 'info', '--no-restore', '--verify-no-changes', '--verbosity', 'minimal'))
}
finally {
    Pop-Location
}

Write-Output "C# cleanup reached a fixed point for $(@($relativeFiles).Count) file(s)."

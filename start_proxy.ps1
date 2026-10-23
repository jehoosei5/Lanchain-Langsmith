# Loads variables from .env into this PowerShell session, then starts the LiteLLM proxy.
# Run from the folder that contains .env and the yaml:   .\start_proxy.ps1
param(
    [string]$Config = "litellm_config_azure_full.yaml",
    [int]$Port = 4000,
    [string]$EnvFile = ".env"
)

if (-not (Test-Path $EnvFile)) { Write-Error "Env file not found: $EnvFile"; exit 1 }
if (-not (Test-Path $Config)) { Write-Error "Config not found: $Config"; exit 1 }

# Load KEY=VALUE lines (skips blanks and # comments, strips surrounding quotes)
Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^\s*([^#=\s][^=]*)=(.*)$') {
        $name  = $matches[1].Trim()
        $value = $matches[2].Trim().Trim('"').Trim("'")
        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
}

if (-not $env:LITELLM_MASTER_KEY) { Write-Error "LITELLM_MASTER_KEY is not set in $EnvFile"; exit 1 }

# Find litellm: PATH first, then the all_env conda environment
$cmd = Get-Command litellm -ErrorAction SilentlyContinue
if ($cmd) {
    $exe = $cmd.Source
} else {
    $exe = "$env:USERPROFILE\AppData\Local\anaconda3\envs\all_env\Scripts\litellm.exe"
}
if (-not (Test-Path $exe)) { Write-Error "litellm not found. Activate your env (conda activate all_env) or fix the path in this script."; exit 1 }

Write-Host "Starting LiteLLM proxy on port $Port with $Config ..."
& $exe --config $Config --port $Port

# --- End-Game Sync Script ---
$REPO_BASE = "https://raw.githubusercontent.com/damarus12/terminal-config/main"

Write-Host "--- Syncing Terminal Environment ---" -ForegroundColor Cyan

# 1. Ensure Binaries exist
$apps = @("starship.starship", "ajeetdsouza.zoxide", "sharkdp.bat", "junegunn.fzf", "BurntSushi.ripgrep.MSVC", "sharkdp.fd", "jesseduffield.lazygit", "Schniz.fnm")
foreach ($app in $apps) { winget install --id $app --silent --accept-package-agreements --accept-source-agreements }

# 2. Sync Starship Config
$configDir = "$HOME\.config"
if (!(Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir }
Invoke-RestMethod "$REPO_BASE/starship.toml" | Out-File -FilePath "$configDir\starship.toml" -Encoding utf8

# 3. Sync PowerShell Profile
$profileDir = Split-Path $PROFILE
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir }
Invoke-RestMethod "$REPO_BASE/powershell_profile.ps1" | Out-File -FilePath $PROFILE -Encoding utf8

# 4. Font Check
if (!((Get-ChildItem -Path C:\Windows\Fonts).Name -contains "JetBrainsMono")) {
  Write-Host "FONT MISSING: Download and install JetBrainsMono Nerd Font." -ForegroundColor Yellow
  Start-Process "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
}

Write-Host "Sync Complete. Restart Terminal or run '. `$PROFILE'" -ForegroundColor Green
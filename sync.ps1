# --- End-Game Sync Script ---
$REPO_BASE = "https://raw.githubusercontent.com/damarus12/w10-terminal/main"

Write-Host "--- Syncing Terminal Environment ---" -ForegroundColor Cyan

# 1. Quietly check for dependencies
$apps = @(
  @{id = "starship.starship"; cmd = "starship" },
  @{id = "ajeetdsouza.zoxide"; cmd = "zoxide" },
  @{id = "sharkdp.bat"; cmd = "bat" },
  @{id = "junegunn.fzf"; cmd = "fzf" },
  @{id = "BurntSushi.ripgrep.MSVC"; cmd = "rg" },
  @{id = "sharkdp.fd"; cmd = "fd" },
  @{id = "jesseduffield.lazygit"; cmd = "lazygit" },
  @{id = "Schniz.fnm"; cmd = "fnm" }
)

foreach ($app in $apps) {
  if (!(Get-Command $app.cmd -ErrorAction SilentlyContinue)) {
    Write-Host "Installing $($app.id)..." -ForegroundColor Gray
    winget install --id $app.id --silent --accept-package-agreements --accept-source-agreements
  }
}

# 2. Sync Starship Config
$configDir = "$HOME\.config"
if (!(Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir }

try {
  Write-Host "Downloading Starship config..." -ForegroundColor Gray
  Invoke-RestMethod "$REPO_BASE/starship.toml" -ErrorAction Stop | Out-File -FilePath "$configDir\starship.toml" -Encoding utf8
}
catch {
  Write-Host "ERROR: Could not find starship.toml at $REPO_BASE/starship.toml" -ForegroundColor Red
}

# 3. Sync PowerShell Profile
$profileDir = Split-Path $PROFILE
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir }

try {
  Write-Host "Downloading PowerShell profile..." -ForegroundColor Gray
  Invoke-RestMethod "$REPO_BASE/powershell_profile.ps1" -ErrorAction Stop | Out-File -FilePath $PROFILE -Encoding utf8
}
catch {
  Write-Host "ERROR: Could not find powershell_profile.ps1 at $REPO_BASE/powershell_profile.ps1" -ForegroundColor Red
}

# 4. Font Check (only triggers if font is missing)
if (!(Get-ChildItem -Path C:\Windows\Fonts -ErrorAction SilentlyContinue | Where-Object Name -like "*JetBrainsMono*")) {
  Write-Host "FONT MISSING: Download and install JetBrainsMono Nerd Font." -ForegroundColor Yellow
  Start-Process "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
}

Write-Host "`nSync Complete! Restart Terminal or run: . `$PROFILE" -ForegroundColor Green
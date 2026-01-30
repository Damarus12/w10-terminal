function sync-terminal {
  irm "https://raw.githubusercontent.com/damarus12/w10-terminal/main/sync.ps1" | iex
}

# --- 1. PROMPT & TOOLS ---
# Init Starship (UI), Zoxide (Navigation), and FNM (Node Versioning)
(& starship init powershell) | Out-String | Invoke-Expression
(& zoxide init powershell) | Out-String | Invoke-Expression
fnm env --use-on-cd | Out-String | Invoke-Expression

# --- 2. PSREADLINE (The "Zsh" Experience) ---
if ($host.Name -eq 'ConsoleHost' -or $host.Name -eq 'Visual Studio Code Host') {
  Import-Module PSReadLine
    
  # Behavior: History-based ghost text + List View menu
  Set-PSReadLineOption -PredictionSource History
  Set-PSReadLineOption -PredictionViewStyle ListView
  Set-PSReadLineOption -EditMode Emacs
  Set-PSReadLineOption -Colors @{ InlinePrediction = '#717171' }

  # Keybindings: Standard completions
  Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardWord
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

  # FIXED: Robust History Search (Ctrl+R)
  # Replaces the flickering version with a stable UI redraw
  Set-PSReadLineKeyHandler -Key "Ctrl+r" -ScriptBlock {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (-not (Test-Path $historyPath)) { return }

    # Capture current line content for fzf query
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # Run fzf: --tac (newest first), --query (current typing)
    $selection = Get-Content $historyPath | 
    Select-Object -Unique | 
    fzf --height 40% --reverse --query "$line" --tac

    if ($selection) {
      [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)
    }

    # Force UI redraw to fix the 'flash' / ghosting
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
  }
}

# --- 3. WORKFLOW ALIASES & FUNCTIONS ---
# Bat: Syntax highlighting cat
function cat {
  param([Parameter(ValueFromRemainingArguments = $true)]$RemainingArgs)
  & bat --paging=never $RemainingArgs
}

# Ripgrep: High-speed grep
function grep {
  param([Parameter(ValueFromRemainingArguments = $true)]$RemainingArgs)
  & rg $RemainingArgs
}

# Tail logs with syntax highlighting
function taillog {
  param([Parameter(ValueFromRemainingArguments = $true)]$RemainingArgs)
  & bat --tail 100 -f $RemainingArgs
}

# Modern 'find' replacement
function find { fd $args }

# Git Terminal UI
function lg { lazygit }

# --- 4. ENVIRONMENT TUNING ---
# Ensure Claude Code/Tools detect git roots properly on Windows
$env:GIT_DISCOVERY_ACROSS_FILESYSTEM = 1
# Ensure UTF-8 for Go/Rust toolchains
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
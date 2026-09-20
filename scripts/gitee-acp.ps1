<#
.SYNOPSIS
  One-click git add/commit/push to a Gitee repository.
.DESCRIPTION
  Encapsulates the full Gitee commit flow so a Codex skill can trigger it with one
  command instead of running many git commands. Maps Conventional Commits types to
  Gitmoji, resolves the Gitee remote, stages, commits, and optionally pushes.
.PARAMETER Type
  Conventional Commits type: feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert
.PARAMETER Scope
  Optional scope, e.g. "export".
.PARAMETER Subject
  Short imperative commit subject. Required.
.PARAMETER Body
  Optional body lines; use "`n" for newlines. Add "BREAKING CHANGE: ..." for breaking changes.
.PARAMETER Paths
  Specific files to stage. Omit or leave empty to stage everything ("git add -A").
.PARAMETER Remote
  Gitee remote name. Omit to auto-detect (origin if it points to gitee.com, otherwise a remote named gitee).
.PARAMETER Branch
  Branch to push. Omit to use the current branch.
.PARAMETER Push
  Push after committing. Default is commit-only (a bare "submit" does not push).
.PARAMETER Breaking
  Mark the change as breaking: appends "!" and a "BREAKING CHANGE:" footer.
.PARAMETER NoEmoji
  Omit the Gitmoji prefix.
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('feat','fix','docs','style','refactor','perf','test','build','ci','chore','revert')]
    [string]$Type,

    [string]$Scope = '',
    [Parameter(Mandatory=$true)][string]$Subject,
    [string]$Body = '',
    [string[]]$Paths = @(),
    [string]$Remote = '',
    [string]$Branch = '',
    [switch]$Push,
    [switch]$Breaking,
    [switch]$NoEmoji
)

$ErrorActionPreference = 'Stop'

$emoji = @{
    feat     = [char]0x2728   # ✨
    fix      = [char]::ConvertFromUtf32(0x1F41B)  # 🐛
    docs     = [char]::ConvertFromUtf32(0x1F4DD)  # 📝
    style    = [char]::ConvertFromUtf32(0x1F484)  # 💄
    refactor = [char]::ConvertFromUtf32(0x267B) + [char]0xFE0F  # ♻️
    perf     = [char]0x26A1   # ⚡
    test     = [char]0x2705   # ✅
    build    = [char]::ConvertFromUtf32(0x1F4E6)  # 📦
    ci       = [char]::ConvertFromUtf32(0x1F477)  # 👷
    chore    = [char]::ConvertFromUtf32(0x1F527)  # 🔧
    revert   = [char]::ConvertFromUtf32(0x23EA)   # ⏪
}

function Fail([string]$m) {
    Write-Host ("[gitee-acp] ERROR: " + $m) -ForegroundColor Red
    exit 1
}
function Info([string]$m) {
    Write-Host ("[gitee-acp] " + $m)
}

# 1. Verify we are inside a git repository
git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Fail "not a git repository; run this from the repository root"
}

# 2. Current branch
$currentBranch = (git branch --show-current 2>$null)
if ([string]::IsNullOrWhiteSpace($currentBranch)) {
    Fail "cannot determine the current branch (detached HEAD?)"
}
$currentBranch = $currentBranch.Trim()

# 3. Resolve the Gitee remote
if ($Remote) {
    $remoteName = $Remote
} else {
    $remoteLines = @(git remote -v)
    $giteeLine = $remoteLines | Where-Object { $_ -match 'gitee\.com' } | Select-Object -First 1
    if ($giteeLine) {
        $remoteName = (($giteeLine -split '\s+')[0]).Trim()
    } elseif ($remoteLines -match 'origin') {
        $remoteName = 'origin'
    } else {
        Fail "no Gitee remote found; add one with: git remote add gitee https://gitee.com/<owner>/<repo>.git"
    }
}

# 4. Build the commit message
$prefix = if ($NoEmoji) { $Type } else { $emoji[$Type] + ' ' + $Type }
$scoped = if ($Scope) { '(' + $Scope + ')' } else { '' }
$bang   = if ($Breaking) { '!' } else { '' }
$header = "${prefix}${scoped}${bang}: $Subject"

$message = $header
if ($Breaking) {
    $message += "`n`nBREAKING CHANGE: $Subject"
}
if ($Body) {
    $message += "`n`n" + $Body
}

# 5. Stage
if ($Paths.Count -gt 0) {
    git add -- $Paths
    if ($LASTEXITCODE -ne 0) { Fail "git add failed for: $($Paths -join ', ')" }
} else {
    git add -A
    if ($LASTEXITCODE -ne 0) { Fail "git add -A failed" }
}

git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Info "nothing staged to commit; working tree is clean"
    exit 0
}

# 6. Commit (message written to a UTF-8 file so emoji/Chinese survive any shell)
$tmpMsg = Join-Path $env:TEMP ("gitee-acp-msg-" + [guid]::NewGuid().ToString('N') + ".txt")
[System.IO.File]::WriteAllText($tmpMsg, $message, (New-Object System.Text.UTF8Encoding($false)))
try {
    git commit -F $tmpMsg
    if ($LASTEXITCODE -ne 0) { Fail "git commit failed" }
} finally {
    Remove-Item -LiteralPath $tmpMsg -ErrorAction SilentlyContinue
}
$shortHash = (git rev-parse --short HEAD).Trim()
Info "committed $shortHash on $currentBranch"

# 7. Push (only when requested)
if ($Push) {
    $pushBranch = if ($Branch) { $Branch } else { $currentBranch }
    git push $remoteName $pushBranch
    if ($LASTEXITCODE -ne 0) {
        git push -u $remoteName $pushBranch
        if ($LASTEXITCODE -ne 0) { Fail "git push to '$remoteName' failed" }
    }
    Info "pushed $pushBranch to remote '$remoteName'"
} else {
    Info "committed only (no push); add -Push to push to '$remoteName'"
}
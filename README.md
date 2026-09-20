# gitee-acp

One-click `git add` → `commit` → `push` to a **Gitee** repository, packaged as a Codex skill that delegates to a single bundled PowerShell script.

The goal is to reduce per-request token cost: instead of the skill instructing the model to run a dozen `git` commands and reason about each one, the model just picks a Conventional Commits type and runs one script call.

## What it does

- Detects the Gitee remote automatically (`gitee` or `origin` pointing to `gitee.com`).
- Builds a Conventional Commits message with a leading Gitmoji.
- Stages, commits, and optionally pushes to Gitee.
- Writes the commit message to a UTF-8 file so emoji and non-ASCII subjects survive any shell.

## Layout

```
gitee-acp/
├── SKILL.md                  # the Codex skill (concise; delegates to the script)
├── scripts/
│   └── gitee-acp.ps1         # the actual implementation
├── agents/openai.yaml        # skill interface metadata
└── references/gitee-push.md  # credential / TLS fallback notes
```

## Install

Copy the whole folder into your Codex skills directory:

```powershell
robocopy "gitee-acp" "C:\Users\<you>\.codex\skills\gitee-acp" /E
```

## Usage

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill_dir>\scripts\gitee-acp.ps1" `
  -Type feat -Scope export -Subject "add STEP exporter" -Push
```

Parameters:

| flag | meaning |
| --- | --- |
| `-Type` | Conventional Commits type (required) |
| `-Scope` | optional scope |
| `-Subject` | short imperative subject (required) |
| `-Body` | optional body lines |
| `-Breaking` | add `!` and a `BREAKING CHANGE:` footer |
| `-Paths` | specific files to stage (default: all) |
| `-Remote` / `-Branch` | override auto-detected remote / branch |
| `-Push` | push after commit (default: commit only) |
| `-NoEmoji` | omit the Gitmoji prefix |

## Requirements

- `git` on `PATH`
- PowerShell (Windows PowerShell or PowerShell 7)
- For pushing over HTTPS, `GITEE_USERNAME` and `GITEE_TOKEN` (a Gitee personal access token)

## Safety

The script defaults to commit-only; it only pushes when `-Push` is passed. It never force-pushes, never writes credentials into repo config, and stops on the first failing step.
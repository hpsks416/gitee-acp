---
name: gitee-acp
description: One-click git add/commit/push to a Gitee repository using the local gacpee-studio panel first to reduce token usage, with a bundled PowerShell script as fallback. Use when the user asks to commit or submit work to Gitee.
---

# Gitee ACP (One-Click Commit to Gitee)

Turn a "提交到 Gitee / 推送到码云" request into one safe flow: `git add` → `git commit` → push to the Gitee remote.

## Preferred path: local gacpee-studio

To keep token usage low, delegate git inspection and execution to the local gacpee-studio panel first. It binds to `127.0.0.1` and performs the real `git add / commit / push gitee` commands.

- Studio directory: `C:\Users\Razer\Documents\Codex\2026-09-20\y\gacpee-studio` (override with `GACPEE_STUDIO_DIR`).
- Start it headless: `python "<GACPEE_STUDIO_DIR>\server.py" --no-browser`.
- Base URL: `http://127.0.0.1:8788` (port override: `GACPEE_STUDIO_PORT`).
- Verify with `GET /api/health`.

Use these compact JSON endpoints instead of rendering the web UI:

1. Inspect: `GET /api/repo?repo=<absolute repo path>` returns branch, Gitee remote, ahead/behind, staged/unstaged/untracked files, and recent commits. If there is nothing to commit, stop and say so.
2. Commit + optional push: `POST /api/commit` with `{"repo_path":"<absolute path>","message":"<emoji> <type>(<scope>): <subject>","push":true|false}`.
3. Push only: `POST /api/push` with `{"repo_path":"<absolute path>"}`.

gacpee-studio pushes to the Gitee remote (`gitee`, or `origin` pointing to `gitee.com`) with OpenSSL and Gitee credentials. Still build the message yourself with the table below. If gacpee-studio is missing, cannot be started, or `/api/health` fails, fall back to the bundled script.

## Fallback: bundled PowerShell script

Run `scripts/gitee-acp.ps1` once from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill_dir>\scripts\gitee-acp.ps1" -Type <type> [-Scope <scope>] -Subject "<subject>" [-Body "<body>"] [-Breaking] [-Push]
```

## Types and emoji

| type | emoji | use when |
| --- | --- | --- |
| feat | ✨ | new feature |
| fix | 🐛 | bug fix |
| docs | 📝 | documentation only |
| style | 💄 | formatting, no logic change |
| refactor | ♻️ | code restructure, no behavior change |
| perf | ⚡ | performance improvement |
| test | ✅ | tests |
| build | 📦 | build system or dependencies |
| ci | 👷 | CI configuration |
| chore | 🔧 | maintenance, no production code |
| revert | ⏪ | reverting a commit |

## Safety

- Only push when the user asked to push; a bare "提交" means commit only.
- Never force-push (`--force`, `-f`) unless the user explicitly asked.
- Never commit secrets, `.env`, credentials, or large binaries; report them instead.
- Gitee credentials come from `GITEE_USERNAME` and `GITEE_TOKEN` (or gacpee-studio `config.json`); never write them into repo config.
- New Gitee repositories default to public; after creating, verify with the GET API and PATCH `private=false` if Gitee returned private (set `private: true` only when the user explicitly asks).
- If a step fails, show the output and stop; do not retry blindly.
- For TLS or credential failures, read [references/gitee-push.md](references/gitee-push.md).

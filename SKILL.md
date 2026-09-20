---
name: gitee-acp
description: One-click git add/commit/push to a Gitee repository via a bundled PowerShell script. Use when the user asks to commit or submit work to Gitee.
---

# Gitee ACP (One-Click Commit to Gitee)

Commit to Gitee by running the bundled script `scripts/gitee-acp.ps1`. Do not run individual `git` commands yourself; the script handles remote detection, message assembly, staging, committing, and pushing in a single call.

## Steps

1. Choose a Conventional Commits type from the table below, an optional scope, and a short imperative subject.
2. Run the script once from the repository root. Add `-Push` only when the user asked to push; a bare "提交" means commit only.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill_dir>\scripts\gitee-acp.ps1" -Type <type> [-Scope <scope>] -Subject "<subject>" [-Body "<body>"] [-Breaking] [-Push]
```

Replace `<skill_dir>` with the directory that contains this `SKILL.md`.

## Types

| type | use when |
| --- | --- |
| feat | new feature |
| fix | bug fix |
| docs | documentation only |
| style | formatting, no logic change |
| refactor | code restructure, no behavior change |
| perf | performance improvement |
| test | tests |
| build | build system or dependencies |
| ci | CI configuration |
| chore | maintenance, no production code |
| revert | reverting a commit |

## Safety

- Only push when the user asked to push; a bare "提交" means commit only.
- Never force-push unless the user explicitly asked.
- Never commit secrets, `.env`, credentials, or large binaries; report them instead.
- Gitee credentials come from `GITEE_USERNAME` and `GITEE_TOKEN`; never write them into repo config.
- New Gitee repositories default to public; set private only when the user explicitly asks.
- If the script fails, show its output and stop; do not retry blindly.
- For TLS or credential failures, read [references/gitee-push.md](references/gitee-push.md).
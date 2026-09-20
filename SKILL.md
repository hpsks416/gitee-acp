---
name: gitee-acp
description: One-click git add/commit/push to a Gitee (gitee.com) repository: stage changes, write a Conventional Commits + Gitmoji message, commit, and push to Gitee. Use when the user asks to commit or submit work to Gitee.
---

# Gitee ACP (One-Click Commit to Gitee)

Turn a "提交到 Gitee / 推送到码云" request into one safe, deterministic flow: `git add` → `git commit` → push to the Gitee remote.

## Workflow

1. Inspect first. Run `git status --porcelain=v1 -b`, `git branch --show-current`, and `git remote -v`. Identify the Gitee remote (usually named `gitee` or `origin` pointing to `gitee.com`).
2. Resolve the remote. If no Gitee remote exists, ask for the repo URL (`https://gitee.com/<owner>/<repo>.git`) and add it with `git remote add gitee <url>`.
3. Build the message. Pick the closest type from the table below, add an optional scope, keep the subject imperative and short. Add `!` and a `BREAKING CHANGE:` footer only for breaking changes.
4. Stage with `git add -A`, unless the user named specific paths.
5. Commit with `git commit -m "<emoji> <type>(<scope>): <subject>"`.
6. Push to Gitee with `git push gitee <branch>`; if the branch has no upstream on that remote, use `git push -u gitee <branch>`. Gitee's default branch is often `master`, so check rather than assuming `main`.

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
- Gitee credentials are a username plus a personal access token, never a plain password. Read them from `GITEE_USERNAME` and `GITEE_TOKEN`, and never write them into repo config.
- If a step fails, show the git output and stop; do not retry blindly.
- For TLS or credential failures, read [references/gitee-push.md](references/gitee-push.md).
# gitee-acp

One-click `git add` → `commit` → `push` to a **Gitee** repository, packaged as a Codex skill.

The goal is to reduce per-request token cost: instead of the skill instructing the model to run a dozen `git` commands and reason about each one, the model delegates inspection and execution to the local **gacpee-studio** panel (or, as a fallback, to one bundled PowerShell script call).

## 参考依赖

- [`gacpee-studio`](https://github.com/hpsks416/gacpee-studio)：首选路径使用的本地可视化 Gitee 提交面板（端口 `8788`）。本项目 SKILL 优先调用它。
- [`gacp-studio`](https://github.com/hpsks416/gacp-studio)：gacpee-studio 的原型，结构与其一致，仅推送目标不同。

## What it does

- Preferred path: start gacpee-studio headless and use its compact JSON API (`/api/repo`, `/api/commit`, `/api/push`) to reduce token usage.
- Fallback path: run the bundled `scripts/gitee-acp.ps1` in a single call; it detects the Gitee remote, builds a Conventional Commits + Gitmoji message, and stages/commits/pushes.
- New Gitee repositories default to public + MIT; after creation, verify visibility and force public if Gitee returned private.

## Layout

```
gitee-acp/
├── SKILL.md                  # the Codex skill (concise; delegates to the studio)
├── scripts/
│   └── gitee-acp.ps1         # fallback implementation
├── agents/openai.yaml        # skill interface metadata
└── references/gitee-push.md  # credential / TLS fallback notes
```

## Install

Copy the whole folder into your Codex skills directory:

```powershell
robocopy "gitee-acp" "C:\Users\<you>\.codex\skills\gitee-acp" /E
```

## Usage

Preferred (visual panel): start `gacpee-studio` and use `http://127.0.0.1:8788` or its JSON API.

Fallback (script), from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill_dir>\scripts\gitee-acp.ps1" `
  -Type feat -Scope export -Subject "add STEP exporter" -Push
```

## Requirements

- `git` on `PATH`
- Python 3.9+ (for gacpee-studio preferred path) or PowerShell (for script fallback)
- For pushing over HTTPS, `GITEE_USERNAME` and `GITEE_TOKEN` (a Gitee personal access token)

## Safety

Both paths default to commit-only unless push is requested, never force-push, never write credentials into repo config, and stop on the first failing step.

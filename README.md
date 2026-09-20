# gitee-acp

一个 Codex 专用技能：把“提交到 Gitee / 推送到码云”变成一条安全的 `git add` → `git commit` → push 流程，提交信息使用 Conventional Commits + Gitmoji。

## 功能

- 识别 Gitee 远端（`gitee` / 指向 `gitee.com` 的 `origin`），缺失时引导补上。
- 用 `<emoji> <type>(<scope>): <subject>` 组装提交信息，内置 11 种类型与 emoji 映射。
- 一键暂存、提交、推送到 Gitee，兼容 `master`/`main`。
- 新建 Gitee 仓库默认公开，建仓后校验可见性，若被建成私有则自动 PATCH 为公开。
- 内置 Gitee 专属的 TLS / 凭据兜底：OpenSSL 后端、私人令牌内联推送、API 最后兜底。
- 凭据只从环境变量 `GITEE_USERNAME` / `GITEE_TOKEN` 读取，不落盘。

## 安装为 Codex 技能

把 `SKILL.md`、`agents/`、`references/` 复制到 `$CODEX_HOME/skills/gitee-acp/`（默认 `~/.codex/skills/gitee-acp/`），下个会话即可用“提交到 Gitee”触发，或显式 `$gitee-acp`。

## 目录结构

```
gitee-acp/
├── SKILL.md                 # 技能入口与工作流
├── agents/openai.yaml       # 界面元数据
├── references/gitee-push.md # Gitee 推送与凭据兜底
├── LICENSE                  # MIT
└── README.md
```

## 快速开始（直接当脚本用）

无需安装依赖，按 `SKILL.md` 的流程执行即可；关键命令：

```bash
git add -A
git commit -m "✨ feat: 初始化"
git push -u gitee master
```

## 许可证

本项目采用 [MIT License](LICENSE)。

## 免责声明

本技能会执行真实的 `git add / commit / push`，请在推送前确认目标仓库与提交信息无误，并妥善保管私人令牌。

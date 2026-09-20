# Gitee push and credentials

Use this when the Gitee push fails or when credentials are needed. Read only the sections that apply.

## Remote URL formats

- HTTPS: `https://gitee.com/<owner>/<repo>.git`
- SSH: `git@gitee.com:<owner>/<repo>.git`

## Create a new repository (public by default)

When the target Gitee repo does not exist yet, create it with the OpenAPI. Default to public unless the user explicitly asked for private:

```text
POST https://gitee.com/api/v5/user/repos
form: access_token=$GITEE_TOKEN, name=<repo>, private=false, auto_init=false
```

- `private=false` means public (公开); set `private=true` only when the user explicitly asks for a private repo.
- Use `auto_init=false` so the first push can set branches cleanly.
- If the API reports the repo already exists, skip creation and just push.

### Verify visibility and force public

Gitee sometimes creates a repo as private even when `private=false` was sent. After creating, verify and correct it:

```text
GET https://gitee.com/api/v5/repos/<owner>/<repo>
query: access_token=$GITEE_TOKEN
```

- If the response `private` is `true`, the create defaulted to private — PATCH it back to public (the PATCH endpoint requires `name` as well):

```text
PATCH https://gitee.com/api/v5/repos/<owner>/<repo>
form: access_token=$GITEE_TOKEN, name=<repo>, private=false
```

- Re-check `private` is `false` after the PATCH before pushing.

## HTTPS credentials

Gitee HTTPS uses a **username** plus a **personal access token** as the password (a plain login password does not work for git operations).

- Read them from environment variables `GITEE_USERNAME` and `GITEE_TOKEN`; never hardcode.
- Create a token at Gitee → 设置 → 私人令牌: `https://gitee.com/profile/personal_access_tokens` (scopes: projects / 仓库 read-write).

## TLS fallback

If the error mentions `schannel` or `SEC_E_NO_CREDENTIALS`, retry with OpenSSL:

```bash
git -c http.sslBackend=openssl push gitee <branch>
```

## Inline-token push

If git still asks for a username/password, push with the token inline and redact it from any output:

```bash
git -c http.sslBackend=openssl push "https://<username>:$(echo $GITEE_TOKEN)@gitee.com/<owner>/<repo>.git" <branch>
```

- Use the Gitee login (or bound email/phone) as `<username>`.
- Never write the token into `.git/config` or any committed file.
- Replace the token in captured output with `***` before showing it.

## Branch and remote notes

- Gitee repos commonly default to `master`; check `git branch --show-current` and the remote's default branch instead of assuming `main`.
- Keep GitHub and Gitee remotes distinct (for example `origin` = GitHub, `gitee` = Gitee) when pushing the same repo to both.

## Last resort: Gitee API

When git HTTPS is fully blocked, Gitee's OpenAPI can create a file via `POST https://gitee.com/api/v5/repos/<owner>/<repo>/contents/<path>` with the token in an `access_token` query or `Authorization` header. Prefer this only when git push fails entirely.

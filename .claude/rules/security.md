# Security Rules

- **Service role / admin keys** — ONLY in server-side files and workers. Never in browser bundles.
- **Auth verification** — Always verify authentication server-side. Never trust client-provided tokens or claims without validation.
- **No API keys in client code** — Check that no secrets leak into `NEXT_PUBLIC_*` variables or client components.
- **Webhook signature verification** — Always verify webhook signatures before processing payloads.
- **Encrypt sensitive data at rest** — Use AES-256-GCM or equivalent for tokens, credentials, PII.
- **No secrets in git** — Never commit `.env` files, API keys, or credentials. Use `.gitignore` and secret scanning.
- **Timing-safe comparison** — Use `crypto.timingSafeEqual()` for token/secret comparison, never `===`.
- **Input validation** — Validate and sanitize all user input at API boundaries (XSS, SQL injection, command injection).

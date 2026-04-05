# Security Rules

These rules apply to any project. Add project-specific security constraints to your own CLAUDE.md.

- **Admin/service keys belong on the server only.** Never import service-role keys, admin tokens, or database credentials in client-side code. Check your bundler's output if unsure.
- **Always verify auth server-side.** Never trust client-provided auth state. Re-verify the session or token in every API route handler, not just in middleware.
- **No secrets in the browser bundle.** API keys, signing secrets, encryption keys, and webhook secrets must never appear in client-side JavaScript. Use server-side environment variables.
- **Timing-safe comparison for tokens.** Use `crypto.timingSafeEqual()` (Node.js) or equivalent when comparing session tokens, magic links, or API keys. String equality (`===`) is vulnerable to timing attacks.
- **Encrypt sensitive tokens at rest.** OAuth tokens, API keys stored in the database, and integration credentials should be encrypted (AES-256-GCM or equivalent) before storage. Never store plaintext secrets in the database.
- **Verify webhook signatures.** Any incoming webhook (Stripe, GitHub, Slack, etc.) must have its signature verified before processing the payload.
- **Never commit secrets.** `.env` files, credential JSON files, private keys, and signing secrets must be in `.gitignore`. Use `.env.example` with placeholder values.
- **Validate and sanitize all user input.** Never pass raw user input to database queries, shell commands, or template engines without validation.

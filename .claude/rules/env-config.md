# Environment & Config Rules

- **Worktree `.env.local` is independent** (not symlinked by default). When adding env vars, update both root and worktree copies.
- **Zod schema validation** — If your project uses a Zod schema for env vars (e.g., `lib/env.ts`), adding a new required var without adding the value to `.env.local` crashes the entire app. Always add the value first.
- **CSP headers are production-only.** `Content-Security-Policy` without `'unsafe-eval'` in `script-src` breaks all React hydration in dev mode (webpack HMR uses eval). Gate CSP behind `process.env.NODE_ENV === 'production'`.
- **Never commit `.env` files.** Use `.env.example` with placeholder values for documentation.
- **`allowedDevOrigins`** does not exist in Next.js 14.x (15+ only). Remove if present in older projects.

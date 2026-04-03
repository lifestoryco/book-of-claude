# Taskflow — Project Constitution

**Updated:** 2026-03-15 | **Status:** Week 4/8 — Core Product Sprint

> **Session Start:** Always read `docs/state/project-state.md` first.
> **Context Budget:** Load only CLAUDE.md + project-state.md. Load `docs/reference/` and `docs/adr/` on demand.

---

## Project Overview

Taskflow is a B2B task management SaaS for small teams (5-50 people). Three roles: Admin (workspace owner), Member (full task CRUD), Guest (read-only invite). Teams create projects, assign tasks, track progress. Core differentiator: automated status updates via Slack and email without any manual check-ins.

**Primary actors:**
| Actor | Auth method | Core permission |
|-------|-------------|----------------|
| Admin | Google OAuth | Full workspace CRUD, billing, member management |
| Member | Google OAuth | Full task and project CRUD within their workspace |
| Guest | Magic Link (30-day TTL) | Read-only: assigned tasks and project timelines only |

---

## Non-Negotiable Rules

| # | Rule |
|---|------|
| 1 | Every task mutation (create/update/delete/assign) must call `await logTaskEvent()` — never skip, never swallow. |
| 2 | Guest users must never see tasks with `visibility: 'internal'`. RLS policy must include `visibility != 'internal'` filter. |
| 3 | `archive` = soft-delete. Never hard-delete tasks or projects. Set `archived_at = NOW()`. |
| 4 | All API routes under `/api/` must verify auth via `requireAuth()` before any DB access. No exceptions. |
| 5 | Slack notification tokens are encrypted at rest with AES-256-GCM. Never store or log plaintext tokens. |

---

## Auth Pattern

```typescript
// CORRECT — always use this pattern in API routes and server components
import { cookies } from 'next/headers';
import { db } from '@/lib/db';
import { redirect } from 'next/navigation';

export async function requireAuth() {
  const cookieStore = await cookies();
  const sessionToken = cookieStore.get('session_token')?.value;
  if (!sessionToken) redirect('/login');

  const { data: session } = await db
    .from('sessions')
    .select('user_id, workspace_id, expires_at')
    .eq('token', sessionToken)
    .gt('expires_at', new Date().toISOString())
    .single();

  if (!session) redirect('/login');
  return session;
}
```

**BANNED auth patterns:**
- Any Supabase SSR helper functions — banned per ADR-003. Use `db` from `lib/db.ts` with manual cookie checks instead.
- Checking auth in middleware only — always re-verify in the route handler itself.
- `getSession()` from any auth package — use token-based session lookup against the `sessions` table.

---

## Banned Patterns

| Pattern | Reason |
|---------|--------|
| `prisma.$executeRaw()` without parameterization | SQL injection risk — use parameterized queries or ORM methods |
| `JSON.parse(req.body)` in API routes | Next.js parses body automatically — double-parsing causes bugs |
| `any` TypeScript type in database query results | Defeats type safety — always type results against generated schema types |
| `console.log` in production code paths | Use `logger.info()` from `lib/logger.ts` — structured logging with request IDs |

---

## Key Architecture

- **Database:** Supabase (Postgres) — RLS enabled on all tables. Guest policy must include `visibility != 'internal'` filter.
- **Frontend:** Next.js 14 App Router — server components by default, client components only for interactivity
- **Auth:** Custom session tokens — see Auth Pattern section above
- **Background jobs:** Inngest — all async operations (email, Slack notifications, digest generation)
- **File storage:** Supabase Storage — attachments bucket, 50MB limit per file
- **Deployment:** Vercel — production and preview environments

**Critical schema notes:**
- `tasks.due_date` is stored as UTC `TIMESTAMPTZ`, never local time
- `task_events` table is append-only — no UPDATE or DELETE queries against it, ever
- `workspaces.slug` is the URL identifier — must be globally unique, enforced at DB level

**Soft-delete convention:** `archived_at TIMESTAMPTZ` = soft-delete for both `tasks` and `projects`. Never hard-delete either table.

---

## Domain Rules

See `.claude/rules/` for domain-specific rules:
- `security.md` — token encryption, RLS policy requirements, guest access restrictions
- `frontend.md` — design system tokens, component patterns, dark mode implementation
- `business-logic.md` — task state machine, notification triggers, digest timing

---

## Self-Verification

After writing code, always run these commands and fix any errors before marking work complete:

```bash
# Type check
npx tsc --noEmit

# Build (skip in worktrees if Inngest/Slack env vars unavailable — tsc is the gate)
npm run build

# Lint
npm run lint
```

**Worktree note:** Worktrees only have 9 of 22 env vars. Build will fail on missing Inngest and Slack vars. `npx tsc --noEmit` is the minimum gate.

---

## Git Commit Format

```bash
git commit -m "feat: your message"
```

Prefixes: `feat:` · `fix:` · `refactor:` · `docs:` · `test:` · `chore:`

**Never commit:** `.env.local` files, Slack tokens, Inngest signing secrets, `node_modules/`

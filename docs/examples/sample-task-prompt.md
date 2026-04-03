---
task: TASK-2.6
title: Slack Notification Integration
phase: Phase 2 — Core Product
size: L
depends_on: [TASK-2.4, TASK-1.5]
created: 2026-03-18
---

# TASK-2.6: Slack Notification Integration

## Context

Task assignment is the core collaboration action in Taskflow. Right now, when a Member assigns a task to someone, the assignee has no idea — they have to check the app manually. This is the friction that our Slack integration removes.

TASK-2.4 (task detail modal) is complete, so the assignment action exists and `logTaskEvent()` is being called correctly on assignment. TASK-1.5 established the `logTaskEvent()` utility. We now need to hook into that event and fire a Slack DM to the assignee when a task is assigned to them.

Slack tokens are stored in `workspace_settings.slack_bot_token` — AES-256-GCM encrypted at rest (see `lib/crypto.ts`). Never log or expose the decrypted token.

**Current state:** Assignment works, events are logged, no Slack notifications exist.
**Why now:** This is the last blocker before Phase 3. TASK-2.7 (email digest) also depends on understanding how we handle async notification delivery.
**Constraints:** Do not modify `logTaskEvent()` itself — hook into Inngest instead. Keep the Slack API call isolated in `lib/notifications/slack.ts`.

---

## Goal

When a task is assigned to a user who has Slack connected, that user receives a Slack DM within 30 seconds of the assignment.

---

## Steps

### Step 1 — Inngest event definition

In `lib/inngest/events.ts`, add a new event type:

```typescript
export type TaskAssignedEvent = {
  name: 'task/assigned';
  data: {
    taskId: string;
    assigneeId: string;
    assignedById: string;
    workspaceId: string;
  };
};
```

Add it to the union type `AppEvents` in that file.

In the existing task assignment API route (`app/api/tasks/[taskId]/assign/route.ts`), after the successful `logTaskEvent()` call, send the Inngest event:

```typescript
await inngest.send({
  name: 'task/assigned',
  data: {
    taskId,
    assigneeId: body.assigneeId,
    assignedById: session.userId,
    workspaceId: session.workspaceId,
  },
});
```

---

### Step 2 — Slack utility

Create `lib/notifications/slack.ts`:

```typescript
import { WebClient } from '@slack/web-api';
import { decrypt } from '@/lib/crypto';

export async function sendSlackDM(
  encryptedBotToken: string,
  slackUserId: string,
  message: string
): Promise<void> {
  const botToken = decrypt(encryptedBotToken);
  const client = new WebClient(botToken);

  await client.chat.postMessage({
    channel: slackUserId,
    text: message,
  });
}
```

This function accepts an already-fetched encrypted token. It is the only place in the codebase that decrypts Slack tokens. Do not add token fetching logic here — that belongs in the Inngest function.

---

**HUMAN GATE:** Stop after Step 2. Before continuing:
- [ ] Confirm the event type looks right — does the data shape match what the assignment route has available?
- [ ] Confirm you're okay with the `sendSlackDM` signature (encrypted token in, no token caching)
- [ ] Check: does `lib/crypto.ts` export a `decrypt` function, or is it named something else?

Tell me "proceed" or flag any issues before I write the Inngest function.

---

### Step 3 — Inngest function

Create `lib/inngest/functions/notify-task-assigned.ts`:

```typescript
import { inngest } from '@/lib/inngest/client';
import { db } from '@/lib/db';
import { sendSlackDM } from '@/lib/notifications/slack';

export const notifyTaskAssigned = inngest.createFunction(
  { id: 'notify-task-assigned' },
  { event: 'task/assigned' },
  async ({ event, step }) => {
    const { taskId, assigneeId, workspaceId } = event.data;

    // Fetch task and assignee in parallel
    const [task, assignee, workspaceSettings] = await step.run(
      'fetch-data',
      async () => {
        const [taskResult, assigneeResult, settingsResult] = await Promise.all([
          db.from('tasks').select('title, project_id').eq('id', taskId).single(),
          db.from('users').select('name, slack_user_id').eq('id', assigneeId).single(),
          db
            .from('workspace_settings')
            .select('slack_bot_token')
            .eq('workspace_id', workspaceId)
            .single(),
        ]);
        return [taskResult.data, assigneeResult.data, settingsResult.data];
      }
    );

    // Skip if Slack not configured or assignee has no Slack ID
    if (!workspaceSettings?.slack_bot_token || !assignee?.slack_user_id) {
      return { skipped: true, reason: 'Slack not configured' };
    }

    await step.run('send-slack-dm', async () => {
      await sendSlackDM(
        workspaceSettings.slack_bot_token,
        assignee.slack_user_id,
        `You've been assigned a task: *${task?.title}*\nView it in Taskflow.`
      );
    });

    return { sent: true, assigneeId };
  }
);
```

Register the function in `lib/inngest/functions/index.ts` (add to the exports array).

---

### Step 4 — Error handling and graceful degradation

Update `notify-task-assigned.ts` to add retry config and a failure handler:

```typescript
export const notifyTaskAssigned = inngest.createFunction(
  {
    id: 'notify-task-assigned',
    retries: 3,
    onFailure: async ({ error, event }) => {
      // Log to your error tracking but don't surface to user
      console.error('Slack notification failed after retries', {
        event: event.data,
        error: error.message,
      });
    },
  },
  // ... rest unchanged
);
```

The notification is best-effort. A Slack API failure must never fail the task assignment itself. The `inngest.send()` call in Step 1 is fire-and-forget — the assignment response does not wait for Slack.

---

## Verification

```bash
# Type check
npx tsc --noEmit

# Build
npm run build
```

**Manual verification — local Inngest dev server:**

```bash
npx inngest-cli dev
```

1. Assign a task to a user who has `slack_user_id` set in the `users` table
2. Watch the Inngest dev UI at `http://localhost:8288` — confirm the `task/assigned` event appears
3. Confirm the `notify-task-assigned` function runs and shows as complete
4. Confirm the Slack DM arrives (requires a real Slack bot token in `.env.local`)

**If Slack bot token is unavailable locally:** Verify the Inngest function runs to the "skip" branch (no token → skipped: true) without errors. That is sufficient for the type check gate.

---

## Definition of Done

- [ ] `TaskAssignedEvent` type added to `lib/inngest/events.ts`
- [ ] `inngest.send()` called from the assignment route after successful `logTaskEvent()`
- [ ] `lib/notifications/slack.ts` created with `sendSlackDM` function
- [ ] Inngest function created and registered
- [ ] `npx tsc --noEmit` passes
- [ ] `npm run build` passes
- [ ] Inngest dev UI shows function executing on task assignment
- [ ] Slack notification failure does not fail the assignment API response

---

## Rollback

If something goes wrong:

```bash
# Remove the Inngest event send from the assignment route
git checkout HEAD -- app/api/tasks/[taskId]/assign/route.ts

# The Inngest function can be left in place — it won't fire without the event
# Or remove it entirely:
git checkout HEAD -- lib/inngest/functions/notify-task-assigned.ts
git checkout HEAD -- lib/inngest/functions/index.ts
```

**Known risks:**
- If `lib/crypto.ts` has a different function name than `decrypt`, Step 2 will have a type error. Confirm in Step 2 human gate.
- Inngest function registration (index.ts exports array) — if the shape of that file differs from what's expected, Step 3 will need adjustment. Read the file before writing.

---

## Notes for Next Session

_Leave blank until work begins. Update during execution if the session spans multiple days._

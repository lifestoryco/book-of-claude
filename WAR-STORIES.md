# War Stories

Gotchas that cost me real time. Each one has a root cause, a fix, and a signal for how to know if you're hitting it. No fluff — these are production bugs, not hypotheticals.

---

### BullMQ jobId dedup silently drops the second enqueue

**What happened:** Two code paths could enqueue the same job type for the same resource, each using the same static `jobId`. The second enqueue returned silently with no error. The job never ran.

**Why:** BullMQ treats a `jobId` as a unique key. If a job with that ID already exists in the queue (even completed), a new `queue.add()` call with the same ID is silently dropped — no exception, no warning, no log.

**The fix:** Use a unique suffix on every enqueue: `'job-${resourceId}-${Date.now()}'`. Only use a static `jobId` when you explicitly want deduplication and you understand the consequences.

**How to detect:** A job that should have run didn't, and there's no error in your logs anywhere. Add a log line immediately after `queue.add()` that prints the returned job ID. If two calls return the same ID, the second was a no-op.

---

### merge2 does not forward source stream errors

**What happened:** A pipeline merged multiple source streams with `merge2`. One source stream emitted an error mid-run. The merged output stream never received the error event and never emitted `'end'`. The pipeline hung forever.

**Why:** `merge2` does not forward errors from individual source streams to the merged output stream. It only forwards data and end events. Error events on sources go nowhere unless you listen to them directly.

**The fix:** Attach an `error` listener to every source stream individually. Inside that handler, destroy the merged stream manually. Never rely on `merged.on('error', ...)` to catch source failures.

**How to detect:** A streaming pipeline that hangs with no timeout and no error log. Add `source.on('error', (err) => console.error('source error', err))` to every individual stream.

---

### Framer Motion cannot interpolate 'transparent'

**What happened:** A component used `'transparent'` as a CSS color value in a Framer Motion `animate` prop. At runtime, Framer Motion threw an interpolation error and the component crashed.

**Why:** Framer Motion's color interpolation engine doesn't recognize the keyword `'transparent'` as a color it can animate between. It expects a parseable color value.

**The fix:** Replace `'transparent'` with `'rgba(0,0,0,0)'` everywhere it appears in Framer Motion `animate`, `initial`, or `exit` props. This applies to `backgroundColor`, `boxShadow`, and any motion value that takes a color.

**How to detect:** Runtime error mentioning color interpolation or "Cannot parse color". Search your codebase for `transparent` in any object passed to `animate={}` or `initial={}`.

---

### backdrop-filter: blur() creates a new stacking context

**What happened:** A modal overlay used `position: fixed` to cover the screen. Its parent element had `backdrop-filter: blur()` applied. The modal appeared behind other elements and couldn't escape the parent's stacking context no matter what `z-index` was set.

**Why:** `backdrop-filter` (and `filter`, `transform`, `will-change`) on a parent creates a new stacking context. Any `position: fixed` child is positioned relative to that context, not the viewport. `z-index` has no effect across stacking context boundaries.

**The fix:** Use `createPortal(overlay, document.body)` to render the overlay outside the problematic parent entirely. Add an SSR guard: `useEffect(() => setMounted(true), [])` and only render the portal after mount.

**How to detect:** A fixed-position element that refuses to appear on top despite a high `z-index`, and there's a `backdrop-filter` or `filter` somewhere in its ancestor chain.

---

### Supabase TUS signed upload uses a completely different endpoint than JWT auth

**What happened:** A large file upload used a signed upload URL from `createSignedUploadUrl()`, then sent the TUS request to the standard resumable upload endpoint with an `Authorization: Bearer` header. The upload returned 403.

**Why:** These are two separate endpoint/auth systems. The standard `/upload/resumable` endpoint validates via JWT claims (`sub`, `role`) and enforces Postgres RLS. The signed endpoint `/upload/resumable/sign` validates via an `x-signature` header and runs as a superuser, bypassing RLS entirely. Signed tokens have no JWT claims and only work with the `/sign` endpoint. Sending them to the JWT endpoint fails auth every time.

**The fix:** When using `createSignedUploadUrl()`, send the TUS request to the `/upload/resumable/sign` endpoint with an `x-signature` header. Use the project's direct storage hostname for large file uploads.

**How to detect:** 403 on TUS upload despite a freshly generated signed URL. Check which endpoint you're targeting and which auth header you're sending.

---

### Next.js client routing preserves component state across soft navigations

**What happened:** Navigating to a page that was already mounted (e.g., `window.location.href = '/same-page'` from that page) did not remount the component. React state from the previous render persisted. An initialization effect that was supposed to run fresh did not run.

**Why:** Next.js client-side routing reuses mounted components when the route hasn't changed. Assigning `window.location.href` to the current URL triggers a soft navigation, not a full page reload. React's reconciler sees the same component tree and keeps the existing instance.

**The fix:** Navigate to a different route first to force a dismount, then navigate back. Or use `router.replace()` with a cache-busting query param. Or refactor so the initialization logic doesn't depend on a clean mount.

**How to detect:** State that should reset on navigation doesn't reset. Add a `console.log('mounted')` inside a `useEffect(()=> {}, [])` — if it doesn't fire after navigation, the component wasn't remounted.

---

### npm warn lines corrupted when piping CLI output to files

**What happened:** Running a CLI command via `npx` and piping stdout to a file resulted in the file starting with an npm warning line (`npm warn exec The following package was not found...`) on line 1 of the output. Downstream tooling that expected structured output on line 1 broke with parse errors.

**Why:** `npx` writes warning messages to stdout (not stderr) in some versions. When the output is piped to a file, the warning becomes line 1, corrupting the file for any consumer that expects the real content to start immediately.

**The fix:** After running any `npx` command that writes to a file, inspect line 1 of the output file before using it. Strip any lines that start with `npm warn` or `npm notice`. Add this as a post-step in any script that pipes CLI output to files.

**How to detect:** Unexpected parse errors or type errors in files generated by `npx` commands. Always run `head -1 output-file` after generation.

---

### AnimatePresence mode="wait" + Turbopack HMR breaks tab switching in dev

**What happened:** Tabs controlled by `AnimatePresence mode="wait"` worked fine in production but broke completely in local development with Turbopack. Clicking a tab triggered the exit animation, which never completed — the new tab content never mounted.

**Why:** Turbopack's HMR holds stale module references. When `AnimatePresence mode="wait"` waits for the exit animation to complete before mounting the new child, the stale module reference prevents the animation completion signal from firing. The component hangs in exit state indefinitely.

**The fix:** Replace `AnimatePresence` tab transitions with CSS animation utilities (`animate-in fade-in slide-in-from-bottom-1 duration-200`) on a plain `<div>` with `key={activeTab}`. This works reliably in both dev and prod and avoids the HMR issue entirely.

**How to detect:** Tab content that stops appearing after a click in dev but works in production. Check if `AnimatePresence mode="wait"` is in the ancestor tree.

---

### useRef synced from props is stale in same-tick async loops

**What happened:** A component used a `useRef` to mirror an array prop (for use in async callbacks). An async function called `onChange()` to add an item to the array, then immediately read `ref.current` in the same tick to iterate over the updated array. The ref still held the old array. A second `onChange()` call inside the loop overwrote the first addition entirely.

**Why:** `useRef` is synced from props in a `useEffect`, which runs after render. When `onChange()` is called and React hasn't re-rendered yet, the ref still holds the value from the previous render. Any code that reads the ref in the same tick as an `onChange()` call is reading stale state.

**The fix:** Eagerly update `ref.current` to the new value before calling `onChange()`. This keeps the ref in sync for any code that runs in the same tick, without waiting for the React render cycle.

**How to detect:** An async loop where only the first item from multiple `onChange()` calls survives. Add logging inside the loop to print `ref.current.length` — if it's not increasing after each `onChange()`, the ref is stale.

---

### Set-Cookie headers are silently dropped on 307 redirects

**What happened:** A logout route set cookies to expire them, then returned a `NextResponse.redirect()`. The redirect worked — the user landed on the login page — but the cookies were never cleared. On the next page load, the old session cookies were still present.

**Why:** Browsers comply with RFC 7231, which states that `Set-Cookie` headers on redirect responses (3xx) should be ignored. `NextResponse.redirect()` returns a 307. The browser follows the redirect and silently discards the cookie headers on the 307 response.

**The fix:** Return a 200 response with an HTML page that uses `<meta http-equiv="refresh" content="0; url=/login">` instead of a redirect. Set the cookies on the 200 response — browsers honor `Set-Cookie` on 200s.

**How to detect:** Cookies that should be cleared after logout are still present. Open DevTools > Application > Cookies immediately after the logout request fires and check if they were actually removed.

---

### response.cookies.delete() doesn't clear cookies set with a path

**What happened:** Cookies were originally set with `{ path: '/' }`. On logout, `response.cookies.delete('session')` was called. The cookie was not cleared. The browser kept sending it on subsequent requests.

**Why:** `cookies.delete()` sets a `Set-Cookie` header without specifying a path. The browser treats this as a different cookie from the one set with `path: '/'`. Two cookies with the same name but different paths can coexist, and clearing one doesn't affect the other.

**The fix:** Clear cookies by setting them to an empty value with an expired date, explicitly matching the original path: `response.cookies.set('session', '', { path: '/', expires: new Date(0) })`.

**How to detect:** `cookies.delete()` runs without error but the cookie is still present in the browser after the response. Check the `Set-Cookie` response header — if it's missing the `Path` attribute, it won't clear the right cookie.

---

### Multi-part archive streams silently hang when connections are opened upfront

**What happened:** A pipeline that processed multi-part archive files (numbered segments of a single large export) fetched all HTTP connections upfront before beginning extraction. Connections that weren't immediately read were dropped by the CDN after an idle timeout. The pipeline hung silently on the dropped connection — no error, no timeout, no progress.

**Why:** CDNs and object storage systems enforce idle read timeouts. If you open an HTTP connection and don't read from it within the timeout window, the server closes it. A pipeline that queues up all connections before processing any of them will hit this on everything after the first part.

**The fix:** Fetch and fully process each archive part serially before opening the next connection. Never hold multiple idle HTTP connections open. Process one part completely, then fetch the next.

**How to detect:** A multi-part download pipeline that processes part 1 successfully then hangs indefinitely on part 2 with no error. Add a log line at the start of each part's fetch — if part 2's log never fires, the hang is before the read, not during it.

---

### BullMQ requires maxRetriesPerRequest: null on the ioredis connection

**What happened:** BullMQ queues and workers used the default ioredis connection config. Under load, the Redis connection experienced brief interruptions. ioredis hit its default retry limit (20 retries) and threw `MaxRetriesPerRequestError`. This cascaded into a flood of connection errors across all queue operations.

**Why:** ioredis defaults to 20 retries per request before giving up. BullMQ's internal protocol relies on long-lived blocking commands that are expected to wait indefinitely. The ioredis retry limit is incompatible with this — it causes ioredis to give up on commands that BullMQ expects to eventually complete.

**The fix:** Set `maxRetriesPerRequest: null` on every ioredis connection used by BullMQ (both Queue and Worker instances). Put this in a shared connection config that all workers import.

**How to detect:** `MaxRetriesPerRequestError` in logs, followed by cascading queue failures. Check your ioredis connection config for a missing or non-null `maxRetriesPerRequest`.

---

### Supabase free plan has a hardcoded 50 MB upload cap

**What happened:** File uploads over 50 MB returned a 413 error from Supabase Storage. The error message was generic. Several hours were spent investigating the TUS upload implementation before discovering the real cause.

**Why:** Supabase's free plan enforces a 50 MB per-file limit at the infrastructure level. This is not a configurable setting — it cannot be changed in the dashboard, via policy, or via storage config. It is a hard cap on the free tier.

**The fix:** Upgrade to the Pro plan. The limit becomes configurable up to 500 GB per file on Pro.

**How to detect:** 413 errors on file uploads above ~50 MB. Check the response body — if it mentions "Payload Too Large" and you're on the free plan, this is the cause before anything else.

---

### Framer Motion Reorder requires the layout prop on child elements

**What happened:** A drag-to-reorder list used `Reorder.Item` from Framer Motion. Dragging items caused jarring jumps and incorrect layout calculations. Items did not animate smoothly into their new positions.

**Why:** `Reorder.Item` relies on layout animations to calculate and animate position changes. The child elements inside `Reorder.Item` must also have the `layout` prop to participate in the layout animation tree. Without it, Framer Motion doesn't know the children need to reflow, and the animation is calculated only for the outer item.

**The fix:** Add `layout` to every direct child element inside `Reorder.Item`. Also, never mutate the items array directly — always use the `onReorder` callback to update state.

**How to detect:** Drag-and-drop list items that jump or don't animate smoothly when reordered. Check whether `layout` is present on `Reorder.Item` children.

---

### Raw img tags break Next.js image optimization

**What happened:** A component used a plain HTML `<img>` tag. The image loaded but bypassed all of Next.js's automatic optimization: no lazy loading, no size optimization, no format conversion, no LCP hints. Lighthouse flagged it as a performance issue.

**Why:** Next.js's `<Image>` component from `next/image` handles lazy loading, automatic WebP/AVIF conversion, responsive sizing, and CLS prevention. Raw `<img>` tags bypass all of this. In newer Next.js versions, using raw `<img>` also generates a build warning.

**The fix:** Replace every `<img>` with `<Image>` from `next/image`. Provide explicit `width` and `height` props (or use `fill` with a positioned parent) to prevent layout shift.

**How to detect:** Build warnings about unoptimized images, or Lighthouse scores flagging images without explicit dimensions. Grep for `<img ` in your JSX/TSX files.

---

### CSS variable flash on mount with global transition-property

**What happened:** An overlay component that should appear instantly opaque flashed from transparent to its background color on mount. The flash was a single frame but visible and jarring.

**Why:** A global CSS rule applied `transition-property: background-color` with a duration to all elements (or a broad selector). On mount, the element briefly existed with no background before the CSS variable resolved and the transition played. The result was a transparent-to-opaque flash.

**The fix:** For elements that must be immediately opaque (modals, overlays, drawers), use an inline `style={{ backgroundColor: 'var(--background)' }}` or add a `transition-none` Tailwind utility. This bypasses the global transition rule for that element.

**How to detect:** A brief flash of transparency on mount for overlays that should be solid. Slow down the transition duration globally in dev to make the flash more visible and confirm the cause.

---

### Fixed overlays need a portal when a parent has backdrop-filter

**What happened:** A dropdown menu used `position: fixed` to anchor to the viewport. A parent container had `backdrop-filter: blur(8px)` for a frosted glass effect. The dropdown appeared clipped inside the parent container and couldn't escape it, regardless of `z-index`.

**Why:** This is the stacking context issue again (see the backdrop-filter war story), manifesting specifically for dropdowns and tooltips. `position: fixed` elements are positioned relative to the nearest stacking context ancestor, not the viewport, when that ancestor has `backdrop-filter` applied.

**The fix:** Render the overlay using `ReactDOM.createPortal(content, document.body)`. Gate the portal render behind `useEffect(() => setMounted(true), [])` to avoid SSR hydration mismatches.

**How to detect:** A fixed-position dropdown or tooltip that appears in the wrong position or is clipped. Inspect the ancestor chain for `backdrop-filter`, `filter`, `transform`, or `will-change` properties.

---

### Video player requires a playback ID even when using signed tokens

**What happened:** A video player was wired up with a signed JWT token for secure playback but no `playbackId` prop, following a strict "never send the ID to the browser" interpretation of a security rule. The player refused to initialize and threw a missing-prop error.

**Why:** The video player component requires a `playbackId` to construct the playback URL, even when a signed token is also provided. The signed token alone is not a complete URL — it's an auth token that must be combined with the ID. The security concern (preventing unauthorized access) is addressed by the time-limited signed token, not by keeping the ID secret. The ID without a valid token is useless.

**The fix:** Send the `playbackId` alongside the signed token. The ID is safe to expose when the playback policy is set to `signed` — the ID cannot stream video without a valid token.

**How to detect:** Video player initialization errors mentioning a missing or required `playbackId` prop, after a signed-token-only implementation.

---

### Claude settings.json hooks section can silently disappear

**What happened:** A `.claude/settings.json` file was edited — either manually or by a tool. The hooks section that registered all PreToolUse and PostToolUse handlers was removed without any warning. The hook scripts remained on disk in `.claude/hooks/` but were no longer registered and stopped running entirely.

**Why:** JSON editing tools (and humans) can remove sections without realizing they're load-bearing. Claude Code reads the hooks config from `settings.json` on startup — if the `hooks` key is gone, no hooks run, regardless of what scripts exist in the hooks directory.

**The fix:** After any edit to `settings.json`, run `git diff .claude/settings.json` and verify the `hooks` key is still present with all its registered commands. If it disappeared, restore it from git: `git checkout HEAD -- .claude/settings.json`.

**How to detect:** Hook behavior that should be blocking dangerous commands stops working. Or run `cat .claude/settings.json | jq '.hooks'` — if it returns `null`, the hooks are not registered.

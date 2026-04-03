# Frontend Rules

- **Portal required for fixed overlays:** `backdrop-filter: blur()` on a parent creates a new stacking context. `position: fixed` children can't escape it. Use `createPortal(overlay, document.body)` with a `useEffect(() => setMounted(true), [])` SSR guard.
- **Framer Motion screenshot timing:** Screenshots capture the page before `animate={{ opacity: 1 }}` fires. Add a short delay after navigation before screenshotting, or check `getComputedStyle(el).opacity`.
- **CSS variable flash:** Global `transition-property: background-color` can cause transparent-to-opaque flash on mount. For immediately-opaque overlays: use inline `style={{ backgroundColor: 'var(--background)' }}` or `transition-none` utility.
- **WCAG AA badge contrast:** Use `-700` text on light backgrounds, `-300` on dark. Pattern: `text-red-700 dark:text-red-300`.
- **Theme pattern:** `darkMode: "class"` in Tailwind + `next-themes` ThemeProvider with `attribute="class"`. Never `darkMode: "media"`. All colors as CSS variables in `:root` (light) and `.dark` (override). Use semantic tokens (`bg-background`, `text-foreground`), never hardcoded colors.
- **Framer Motion Reorder:** Requires `layout` prop on `Reorder.Item` children. Never mutate arrays directly — use `onReorder` callback.
- **`next/image` only** — never use raw `<img>` tags.
- **Framer Motion color interpolation:** Cannot interpolate `'transparent'`. Always use `'rgba(0,0,0,0)'` instead.

# Frontend Rules

Common frontend gotchas. Keep what applies to your stack, remove what doesn't.

## CSS & Layout
- **Portal required for fixed overlays.** `backdrop-filter: blur()` on a parent creates a new stacking context. `position: fixed` children can't escape it. Use `createPortal(overlay, document.body)` with an SSR guard (`useEffect(() => setMounted(true), [])`) if your framework requires it.
- **CSS variable flash on mount.** Global `transition-property: background-color` can cause a transparent-to-opaque flash on mount. For immediately-opaque overlays, use inline styles or a `transition-none` utility.

## Images
- **Use your framework's image component.** Next.js has `next/image`, Nuxt has `nuxt-img`, etc. Raw `<img>` tags bypass lazy loading, format optimization, and size hints. Use the framework component unless you have a specific reason not to.

## Accessibility
- **WCAG AA contrast on badges and tags.** Use darker text shades (`-700`) on light backgrounds, lighter shades (`-300`) on dark backgrounds. Test with a contrast checker.

## Animation (Framer Motion)
- **Cannot interpolate `'transparent'`.** Use `'rgba(0,0,0,0)'` instead. Applies to `backgroundColor`, `boxShadow`, and any color-typed motion value.
- **Reorder needs `layout` prop.** Add `layout` to every direct child inside `Reorder.Item`. Never mutate arrays directly — use the `onReorder` callback.
- **Screenshot timing.** Screenshots capture the page before `animate={{ opacity: 1 }}` fires. Add a short delay after navigation before screenshotting.

## Theming
- **Use CSS variables for theming.** Define tokens in `:root` (light) and `.dark` (override). Use semantic names (`bg-background`, `text-foreground`), never hardcoded color values in components.
- **`darkMode: "class"`** (Tailwind) or equivalent class-based toggle. Never `darkMode: "media"` if you want user-controlled theme switching.

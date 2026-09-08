---
name: frontend-patterns
description: React and Next.js pattern checklist - which pattern to reach for and when. Use when building or reviewing components, hooks, state management, forms, or when a UI is slow or inaccessible.
---

# Frontend Patterns

A checklist of options, not a mandate. Reach for these when the situation calls for it.

## Components
- **Composition over inheritance** - default. Pass children and props rather than subclassing.
- **Compound components** - when parts must share implicit state (tabs, accordion, select).
- **Render props / hooks** - when behaviour is reused but markup differs.

## Hooks
- Extract a hook when stateful logic appears in two components, not before.
- **Async data** - handle loading, error, and empty as first-class states, not afterthoughts.
- **Debounce** - for search-as-you-type and anything firing on every keystroke.

## State
- Local state first. Lift only when a second component needs it.
- **Context + reducer** - for state that is genuinely app-wide. Context re-renders every consumer, so split contexts by update frequency.
- Server data belongs in a data-fetching layer, not in global state.

## Performance
Measure before optimising - profile, don't guess.
- **Memoization** - only for expensive renders or referentially-unstable props. It has a cost.
- **Code splitting / lazy loading** - route level first, then heavy components below the fold.
- **Virtualization** - long lists. Rendering thousands of rows is the problem, not the row.

## Forms
- Controlled inputs with validation at submit and on blur, not on every keystroke.
- Validate with a schema, and reuse that schema server-side.

## Errors
- **Error boundaries** at route level so one broken component can't blank the page.
- Show the user something actionable; log the detail.

## Accessibility
- Keyboard navigation for every interactive element - tab order, Enter and Escape.
- Manage focus on route change, dialog open, and dialog close.
- Semantic elements before ARIA. A `button` beats a `div` with a role.

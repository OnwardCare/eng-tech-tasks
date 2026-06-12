# INTERVIEWER NOTES — ⚠️ DELETE THIS FILE BEFORE SENDING TO CANDIDATES ⚠️

This is the answer key for the Pokédex take-home (Ember 6.12, `<template>` tag
/ `.gjs` components, Vite build). It documents the two required tasks and every
planted defect. None of this is hinted at in the code or the candidate README.

Total expected effort: **~4–5 hours** (≈1–1.5h on the two tasks, ≈2.5–3h on
finding/fixing the planted defects and general cleanup).

---

## The two required tasks

### Task 1 — Evolution chain (~45–60 min)

`app/components/evolution-chain.gjs` is a static placeholder.

**Done looks like:** fetch `pokemon-species/{id}` → follow
`evolution_chain.url` → walk the recursive `chain` / `evolves_to[]` structure →
render the line in order, each stage a `<LinkTo>` to its detail route. The
Pokémon id for each stage must be derived from `species.url` (the species
payload has no id field) to build links and sprites.

- **Junior bar:** chain renders in order for a 3-stage line (Bulbasaur →
  Ivysaur → Venusaur) and links work.
- **Senior bar:** handles 1-stage Pokémon (e.g. Tauros) and branching chains
  (Eevee) gracefully, loads in the route or a service rather than a component
  constructor (i.e. doesn't copy the broken pattern in `pokemon-detail`), shows
  loading/error states, un-skips and finishes the evolution-chain test.

### Task 2 — Persistent, reactive favorites (~30–45 min)

Builds directly on planted defect #1 (see below). Candidate must make the
favorites service tracked/reactive **and** persist to `localStorage`.

- **Junior bar:** `@tracked items` with immutable reassignment, JSON
  serialize/restore on add/remove/init; nav count and stars update live and
  survive refresh; the failing favorites unit test now passes.
- **Senior bar:** also removes the duplicated local `@tracked isFavorite` state
  in `favorite-button.gjs` (derives from the service instead), handles corrupt/
  missing localStorage payloads, and keeps the storage key/shape tidy
  (e.g. stores minimal fields, not whole API payloads).

---

## Planted defects (the "rough edges")

### Defect 1 — Non-reactive favorites state

- **File:** `app/services/favorites.js` (plus `app/components/favorite-button.gjs`)
- **Symptom:** starring a Pokémon never updates the nav count (it stays stale
  until a full page reload — which then resets everything, since favorites are
  in-memory only). The star itself toggles only because `favorite-button`
  keeps a *duplicate* local `@tracked isFavorite`, so the service and buttons
  can disagree. `tests/unit/services/favorites-test.gjs` fails because of this
  defect — that is intentional.
- **Why it's wrong:** `items` is a plain (non-`@tracked`) array mutated with
  `.push()`/`.splice()`; Glimmer never invalidates, so `count` and
  `isFavorite()` results are stale in rendered output.
- **Strong fix:** `@tracked items = []` with immutable reassignment
  (`this.items = [...this.items, pokemon]`), derive button state from the
  service, delete the duplicated component state. (This is also the foundation
  of Task 2.)

### Defect 2 — Data fetched in a component constructor

- **File:** `app/components/pokemon-detail.gjs`
- **Symptom:** the detail page works, but there is no loading or error state
  (blank page while fetching, silently blank on failure/offline). Navigating
  between two detail pages without leaving the route (e.g. once evolution-chain
  links exist, or via the featured banner from a detail page) shows **stale
  data**: the constructor never re-runs when `@pokemonId` changes. Fast
  back-navigation sets state on a torn-down component.
- **Why it's wrong:** data loading belongs in the route's `model()` hook (or a
  data service), where Ember gives you loading/error substates, automatic
  re-fetch on param change, and cancellation semantics for free.
- **Strong fix:** move the fetches into `app/routes/pokemon.js` `model()` (or
  `poke-data`), add `pokemon-loading.gjs` / `pokemon-error.gjs` substates, and
  make the component a pure presenter of `@model`. Also note the leftover
  `console.log`.

### Defect 3 — Sequential fetch waterfall, no caching

- **Files:** `app/routes/index.js`, `app/components/pokemon-list.gjs`
  (`nextPage`), `app/services/poke-data.js`
- **Symptom:** initial load fires 21 requests **one at a time** (list + 20
  details in a `for…await` loop); the grid takes several seconds. Every revisit
  of the index refetches everything. The same waterfall is copy-pasted in
  `pokemon-list`'s `nextPage`.
- **Why it's wrong:** the per-Pokémon requests are independent — awaiting them
  serially multiplies latency by 20. Nothing is cached even though the data is
  immutable. The route and the component also duplicate fetching/mapping logic.
- **Strong fix:** `Promise.all` over the detail fetches (or skip them entirely
  — the sprite URL is derivable from the id, and the id from `entry.url`), plus
  a simple cache in `poke-data` keyed by url/id. Bonus points for moving all
  fetching behind the service.

### Defect 4 — Leaked interval in the featured rotator

- **File:** `app/components/featured-rotator.gjs`
- **Symptom:** the index page starts a `setInterval` that is never cleared.
  Navigate away and the timer (and its fetch every 8s) keeps running forever;
  every return to the index stacks another interval. Watch the network tab to
  see it.
- **Why it's wrong:** the component owns a timer but has no teardown;
  `willDestroy` is never implemented. The interval also keeps setting state on
  a destroyed component. (There's an unused `later` import left behind, too.)
- **Strong fix:** store the interval id and `clearInterval` in `willDestroy()`,
  or use a cleanup-aware modifier/helper. Guard async callbacks with
  `isDestroyed`/`isDestroying` (or use a task library pattern).

### Defect 5 — Broken search, page state not in the URL, mutating sort, dead Previous button

- **File:** `app/components/pokemon-list.gjs`
- **Symptoms (several in one place):**
  - The search box only filters **the 20 Pokémon already loaded on the current
    page** — searching "mew" on page 1 finds nothing, which is misleading.
  - Pagination `offset` is component-local `@tracked` state, **not a query
    param**: the URL never changes, refresh/share always lands you back on
    page 1, and the browser back button doesn't step through pages.
  - The "Previous" button renders but is a no-op (`console.log` only).
  - `filteredPokemon` re-filters and re-sorts on **every keystroke** with no
    debounce or memoization.
  - The sort getter calls `this.pokemon.sort(...)` — `Array#sort` mutates the
    model/page array in place, so the original API order is silently destroyed
    (subtle: when a search term is active, `filter()` makes a copy first, so it
    only corrupts the source when *not* searching).
  - `currentPage`/`@pokemon` juggling (`this.currentPage || this.args.pokemon`)
    is fragile derived state, and the component re-implements fetching the
    route already does.
- **Strong fix:** drive pagination (and ideally `searchTerm`/`sortBy`) from
  query params — add a controller with `queryParams` + `refreshModel: true` (or
  use the router service) so the route loads the right page and URLs are
  shareable; implement Previous; debounce search input; sort a copy
  (`[...results].sort(...)`); consider searching against the full Gen-1 name
  list (one cheap request for `?limit=151`) rather than the loaded page.

### Bonus rough edges (fine if candidates fix, fine if they don't)

- Types render as plain text via a bare `type-badge.gjs` stub — turning it
  into a real colored badge component is a nice-to-have refactor, not required.
- Favorites saved from the detail page have an `artwork` field instead of
  `sprite`, so their cards on `/favorites` render a broken/empty image —
  inconsistent data shapes across the app.
- `tests/acceptance/list-test.js` is brittle: over-specific selectors, a magic
  row count of 20, and it hits the real network.
- Lint smells: `console.log`s, a blanket `/* eslint-disable no-console */` in
  `pokemon-list.gjs`, unused `later` import, inconsistent quote style in
  `poke-data.js`.
- Flavor text is rendered raw, including `\n`/`\f` control characters from the
  API.
- The blueprint's WarpDrive store service (`app/services/store.js`) is dead
  weight — the app never uses it; everything goes through raw `fetch`.

---

## Suggested time budget

| Item | Estimate |
| --- | --- |
| Task 1 — evolution chain | 45–60 min |
| Task 2 — persistent favorites (incl. defect 1) | 30–45 min |
| Defect 2 — move detail fetch to route + substates | 30–40 min |
| Defect 3 — parallelize + cache list loading | 25–35 min |
| Defect 4 — clear the interval | 10–15 min |
| Defect 5 — query params, search, sort, Previous | 45–60 min |
| Cleanup, tests, commits | 20–30 min |
| **Total** | **≈ 4–5 h** |

## Quick grading signals

- Did they notice the failing favorites test and connect it to the service?
- Did they reach for query params (controller or router service), or keep
  hacking around component-local state?
- `Promise.all` (good) vs. leaving the waterfall (miss) vs. deriving sprites
  from ids and deleting 20 requests (great).
- Did they copy the `pokemon-detail` constructor-fetch pattern into the
  evolution chain (bad sign), or move loading to the route/service (good sign)?
- Comfort with `<template>` tag: clean imports, no resolver-style indirection,
  template-only components where a class isn't needed.
- Commit history: small, scoped commits with rationale vs. one big dump.

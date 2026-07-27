# Pokédex Challenge

A small Gen-1 Pokédex built with Ember 6.12 (`<template>` tag components, Vite)
on top of the public [PokéAPI](https://pokeapi.co/) (no API key needed). The
app runs, but it is unfinished and has some rough edges — that's where you come
in.

What exists today:

- `/` — a paginated grid of the first-generation Pokémon (ids 1–151, 20 per
  page) with a search box, a sort control, and a rotating "featured Pokémon"
  banner.
- `/pokemon/:id` — a detail page with artwork, types, abilities, base stats,
  and flavor text.
- `/favorites` — a list of Pokémon you have starred.
- A favorite toggle (star) on cards and the detail page, and a favorites count
  in the nav.

## Setup

```sh
npm install
npm start
```

Then open <http://localhost:4200>. Node 20.19+ or 22 required.

Run the test suite with `npm test`.

## Time box

Plan for about **5 hours** total. We'd rather see fewer things done well than
everything done halfway. Commit as you go so we can follow your thinking.

## Your tasks

1. **Implement the evolution chain on the detail page.** The detail page
   currently shows an "Evolution chain coming soon" placeholder. Fetch
   `pokemon-species/{id}`, follow its `evolution_chain.url`, walk the recursive
   `chain` structure, and render the evolution line in order (e.g. Bulbasaur →
   Ivysaur → Venusaur), with each stage linking to its own detail page.
   _Done when:_ every detail page shows its full evolution line in the right
   order, and clicking a stage navigates to that Pokémon.

2. **Persist favorites across reloads.** Favorites currently live only in
   memory. Persist them with `localStorage` and make the favorites experience
   fully reactive: the nav count and star states update immediately everywhere,
   survive a refresh, and `/favorites` reflects the persisted set.
   _Done when:_ you can star a Pokémon, reload the browser, and the star, the
   nav count, and the `/favorites` route all still agree.

## Beyond the tasks

The codebase has correctness, state-management, and performance issues. Fix
what you find and improve the code where it matters; commit as you go. You
don't need to gold-plate everything — prioritize like you would on a real team.

## What we look at

- Correctness — does it work, including edge cases?
- Ember/Octane idioms and state management
- Data-layer boundaries (who fetches, who caches, who owns state)
- Error and loading handling
- Performance awareness
- Tests
- Commit hygiene and clarity

Have fun — gotta catch 'em all.

## Notes for reviewers

Commits are ordered so each one is a self-contained, reviewable step; see the
git log for the full breakdown. Summary of what changed and why:

- **Favorites reactivity + persistence.** `items` was a plain array mutated
  with `push`/`splice`, which Glimmer doesn't track — that's why `count`
  never updated (the one failing test at the start). Switched to a
  `@tracked` array with immutable updates, added `localStorage`
  read/write-through, and made `favorite-button` derive `isFavorite` from
  the service instead of keeping its own stale copy. `/favorites` now reads
  the service directly instead of a route-model snapshot, which would
  otherwise go stale the moment `items` is reassigned.
- **Evolution chain.** Added `fetchSpecies`/`fetchEvolutionChain` to the
  `poke-data` service, walk the recursive chain into a tree, and render it
  in order with each stage linking to its own detail page. Branching chains
  (Eevee's three evolutions) render as multiple lines rather than assuming
  a single line. Building this surfaced a real bug: `pokemon-detail` only
  fetched in its constructor, but Ember reuses that component instance
  across `/pokemon/:id` route changes, so clicking an evolution stage
  changed the URL without changing the page. Fixed with an `ember-modifier`
  that reloads whenever `@pokemonId` changes.
- **Data-layer boundaries.** `pokemon-detail`, `featured-rotator`, the index
  route, and pagination all used to call `fetch()` directly with hand-built
  URLs. Everything now goes through `poke-data`, which also caches by
  request key (including in-flight promises, so concurrent callers share
  one request instead of duplicating it) and evicts failed requests so
  they're retried rather than cached forever.
- **Search/pagination.** Search only matched whichever 20 Pokémon happened
  to be on the current page, and "Previous" was a `console.log` no-op.
  Since Gen 1 is a small, fixed set (151), the index route now fetches the
  full name/id list once and the list component does search, sort, and
  pagination entirely client-side, only fetching full details (sprite,
  types) for whichever page is actually visible. Added proper
  loading/error states and disabled the Previous/Next buttons at the
  boundaries instead of relying on silent early-returns.
- **Other fixes:** `featured-rotator`'s `setInterval` was never cleared
  (kept fetching, and could write to a destroyed component, after leaving
  the page); `filteredPokemon` sorted the source array in place instead of
  a copy; removed an unused, dead `@warp-drive` store service left over
  from the scaffold.
- **Debounced search + loading feedback.** Every keystroke re-filtered the
  full list and could kick off a fresh burst of detail fetches for the
  newly-visible page, even mid-typing. Search now debounces 250ms after
  the last keystroke (via a manual `setTimeout` registered with
  `@ember/test-waiters` rather than `@ember/runloop`, per this project's
  lint rules) before it's applied, and the grid now surfaces a small
  "Loading…" indicator while a page's details are in flight, since
  `isLoading` existed but was never rendered.
- **Stale-response and post-destroy guards.** `pokemon-detail` and
  `pokemon-list` already ignored a slower request that resolved after a
  newer one started; `evolution-chain` didn't have that guard at all, so
  clicking through evolution stages quickly could show the wrong chain.
  Added the same guard there, plus `isDestroying`/`isDestroyed` checks
  across all three so navigating away mid-fetch can't throw trying to
  update a torn-down component.
- **Route-level loading/error substates.** The index route's `model()`
  awaits a network request before the transition completes; with no
  `loading`/`error` templates, a slow request left the page blank and a
  failed one fell back to Ember's default, unstyled error page. Added
  both substates, styled to match the app.

**Known trade-offs / what I'd do with more time:**

- The acceptance/integration tests hit the real PokéAPI rather than a mock
  layer (e.g. `msw` or a fixture-based fetch stub) — matches the existing
  test style in this repo, but a mocked HTTP layer would make the whole
  suite deterministic and fast regardless of network conditions.
- No request de-duplication/backoff for the featured-rotator's polling
  fetch beyond the cache — fine at this scale, but a longer-lived app would
  want retry/backoff on failure instead of silently trying again in 8s.
- Sorting/searching 151 lightweight entries client-side is effectively
  free; this approach wouldn't scale to a much larger dataset without
  moving filtering server-side.

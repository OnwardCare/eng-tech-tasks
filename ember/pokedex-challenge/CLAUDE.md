# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```sh
npm start          # dev server at http://localhost:4200
npm test           # build (dev mode) then run QUnit tests via testem
npm run lint       # run all linters (JS/TS via ESLint, HBS via ember-template-lint, CSS via stylelint, format via prettier)
npm run lint:fix   # auto-fix all linters + format
npm run format     # prettier only
npm run build      # production vite build
```

Node 20.19+ required.

## Architecture

**Stack:** Ember 6.12 + Vite (via `@embroider/vite`). No classic ember-cli pipeline — `vite.config.mjs` and `ember-cli-build.mjs` co-exist.

**Component format:** All components use Ember's `<template>` tag syntax (`.gjs` files — "Glimmer JS"). There are no separate `.hbs` files. Templates are co-located with JS class bodies.

**Routing:** Three routes defined in `app/router.js`:
- `index` → `/` — paginated Gen-1 grid
- `pokemon` → `/pokemon/:pokemon_id` — detail page
- `favorites` → `/favorites` — starred Pokémon

Routes live in `app/routes/`. Route `model()` hooks return plain objects/arrays, not Ember Data models. Templates live in `app/templates/` and receive `@model` from the route.

**Services:**
- `poke-data` (`app/services/poke-data.js`) — thin wrapper around PokéAPI (`https://pokeapi.co/api/v2`). No auth required.
- `favorites` (`app/services/favorites.js`) — owns the favorites list. Currently in-memory only (not persisted).
- `store` (`app/services/store.js`) — WarpDrive store stub (not actively used for data fetching yet).

**Data fetching pattern:** Mixed. `app/routes/index.js` fetches via `pokeData` service. `PokemonDetail` and `FeaturedRotator` components fetch directly inside their constructors/methods using `fetch()`. The PokéAPI data is not cached between navigations.

**Key known issues in the codebase:**
- `FavoritesService` uses a plain array (`items = []`) — not `@tracked`, so mutations (push/splice) won't trigger reactivity in templates.
- `FavoriteButton` stores `isFavorite` as a local `@tracked` copy rather than deriving it from the service, so it can desync.
- `FeaturedRotator` uses `setInterval` without cleanup (memory/timer leak on component teardown).
- `PokemonList.previousPage()` is a no-op stub.
- `EvolutionChain` component is an unimplemented placeholder.
- Favorites are not persisted to `localStorage`.

## Tests

Tests use QUnit + `@ember/test-helpers`. Test helpers are in `tests/helpers/index.js` (`setupApplicationTest` wraps `setupApplicationTest` from `ember-qunit`).

- Acceptance tests: `tests/acceptance/` — use `visit()`, `findAll()`, `assert.dom()`.
- Integration tests: `tests/integration/components/` (currently empty).
- Unit tests: `tests/unit/services/` (currently empty).

Run a single test file: pass `--filter` to testem, or open `http://localhost:4200/tests` while the dev server is running and use QUnit's filter UI.

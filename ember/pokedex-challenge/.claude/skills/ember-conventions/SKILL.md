---
name: ember-conventions
description: Conventions for writing Ember code in this repository (pokedex-challenge) — component format, template style, state management, service usage, and testing patterns. Use whenever creating or editing components, routes, services, templates, or tests in this Ember app.
---

# Ember conventions for this repository

This app is Ember 6.12 (Octane edition) on Embroider/Vite, using native `<template>` tag
components exclusively. Follow the patterns below exactly — do not introduce classic
`.hbs`/`.js` pairs, `@ember/component`, `Ember.Object`, or Ember Data models; none of
those exist in this codebase.

## 1. Edition & syntax

- `package.json` declares `"ember": { "edition": "octane" }`. Native ES class syntax only
  — no `Ember.Object.extend()`, no `.extend()` mixins anywhere in `app/`.
- Components are `@glimmer/component`, **never** `@ember/component`:

  ```js
  import Component from '@glimmer/component';
  import { tracked } from '@glimmer/tracking';
  import { action } from '@ember/object';
  import { service } from '@ember/service';

  export default class FavoriteButton extends Component {
    @service favorites;
    @tracked isFavorite;

    constructor() {
      super(...arguments);
      this.isFavorite = this.favorites.isFavorite(this.args.pokemon.id);
    }

    @action
    toggle() {
      this.favorites.toggle(this.args.pokemon);
      this.isFavorite = !this.isFavorite;
    }

    <template>
      <button type="button" {{on "click" this.toggle}}>
        {{if this.isFavorite "★" "☆"}}
      </button>
    </template>
  }
  ```
  (`app/components/favorite-button.gjs`)

- Routes and services are native classes extending `@ember/routing/route` /
  `@ember/service`, decorated with `@service`. See `app/routes/favorites.js`,
  `app/services/poke-data.js`.
- Modifiers/helpers used inline: `{{on}}` from `@ember/modifier`, `{{if}}` built-in. No
  custom helpers exist yet — if adding one, put it in `app/helpers/` as a plain export.

## 2. Component & file format — `.gjs` only

- **Every** component is a single `.gjs` file (Glimmer JS) under `app/components/`. There
  are **no** `.hbs` template files anywhere in `app/`. Do not create one.
- Two shapes are used, pick based on whether the component needs state/logic:
  - **Template-only** (no backing class) — just an exported `<template>`:
    ```js
    // app/components/type-badge.gjs
    <template>
      <span class="type-badge">{{@type}}</span>
    </template>
    ```
  - **Stateful** — class with the `<template>` tag as the last member of the class body
    (this is the co-location convention here; the template is *inside* `export default
    class ... { ... <template>...</template> }`, not a separate export):
    ```js
    // app/components/nav-bar.gjs
    export default class NavBar extends Component {
      @service favorites;

      <template>
        <nav class="main-nav">
          <LinkTo @route="index" class="nav-brand">Pokédex</LinkTo>
        </nav>
      </template>
    }
    ```
- Route templates live in `app/templates/*.gjs` as template-only `.gjs` files that import
  and render a top-level component with `@model`:
  ```js
  // app/templates/index.gjs
  import PokemonList from 'pokedex-challenge/components/pokemon-list';

  <template>
    <PokemonList @pokemon={{@model}} />
  </template>
  ```
- `app/templates/application.gjs` is the root layout — renders `<NavBar />` and
  `{{outlet}}` inside `<main class="page">`.

## 3. Template conventions

- **Angle-bracket component invocation only** — `<TypeBadge @type={{type}} />`, never
  `{{type-badge type=type}}`.
- Named/positional args use `@camelCase` (`@pokemon`, `@pokemonId`, `@type`).
- Local/class properties in templates use `this.` (`this.isFavorite`, `this.pokemon`).
- Imports for components used in a template go at the top of the `.gjs` file as regular
  JS imports, using the app's module prefix `pokedex-challenge/components/...`:
  ```js
  import FavoriteButton from 'pokedex-challenge/components/favorite-button';
  import TypeBadge from 'pokedex-challenge/components/type-badge';
  ```
- Built-in control flow: `{{#if}}`, `{{#each ... as |x|}}` — standard Glimmer syntax, no
  classic `{{#each-in}}`/curly component invocations in this codebase.
- `{{on "click" this.someAction}}` / `{{on "input" this.someAction}}` for event handling
  (see `app/components/pokemon-list.gjs`), paired with an `@action`-decorated method.
- Page titles are set per-route-template via `ember-page-title`:
  `{{pageTitle "Favorites"}}` at the top of the template (see
  `app/templates/favorites.gjs`, `app/templates/pokemon.gjs`).
- Routing links use the `LinkTo` component imported from `@ember/routing`:
  `<LinkTo @route="pokemon" @model={{@pokemon.id}}>`.

## 4. State management & data patterns

- **`@tracked`** from `@glimmer/tracking` is the reactivity primitive for component-local
  state (`@tracked isFavorite`, `@tracked featured = null`).
  - ⚠️ Known bug pattern to avoid replicating: `app/services/favorites.js` uses a plain
    `items = []` array with `push`/`splice`, which is **not** `@tracked` and won't
    trigger template updates reliably. When writing new service state that templates
    depend on, use `@tracked` (e.g. `@tracked items = [];` and reassign
    `this.items = [...this.items, newItem]` rather than mutating in place), not a
    plain mutable array.
  - Similarly, don't copy `FavoriteButton`'s pattern of caching a service value into a
    local `@tracked` copy (`this.isFavorite = this.favorites.isFavorite(...)` in the
    constructor) for new code — prefer a `get` that derives from the service directly,
    since the cached-copy pattern is called out as a known desync bug here.
- **Services** (`app/services/`) are the shared-state layer, injected via `@service name;`
  and referenced as `this.name` in JS or `this.name.prop` in templates
  (`this.favorites.count` in `nav-bar.gjs`). Existing services: `poke-data` (API
  wrapper), `favorites` (in-memory favorites list, not persisted to `localStorage`),
  `store` (WarpDrive stub, not wired to any route yet).
- **No Ember Data models.** Route `model()` hooks return plain fetched/mapped objects,
  e.g. `app/routes/index.js` maps raw PokéAPI JSON into `{ id, name, sprite, types }`
  objects. There is no `app/models/` directory — don't create one; keep shaping data as
  plain objects in the route or component.
- **No Ember Concurrency** — async work uses plain `async`/`await` with native `fetch()`,
  either in a route's `model()` or directly inside a component `constructor`/`@action`
  method (see `PokemonDetail.loadPokemon()`, `PokemonList.nextPage()`). Follow this
  pattern rather than introducing `ember-concurrency` tasks.
- `@glimmer/component` constructors that kick off async loads follow this shape:
  ```js
  constructor() {
    super(...arguments);
    this.loadPokemon();
  }

  async loadPokemon() {
    const response = await fetch(`https://pokeapi.co/api/v2/pokemon/${this.args.pokemonId}`);
    const data = await response.json();
    this.pokemon = { id: data.id, name: data.name, /* ...mapped shape... */ };
  }
  ```
  Note there is no request caching/dedup layer — each navigation refetches.

## 5. Testing setup

- **QUnit** + `@ember/test-helpers`, via `ember-qunit`. Wrapped setup helpers live in
  `tests/helpers/index.js` (`setupApplicationTest`, `setupRenderingTest`, `setupTest`) —
  import from `pokedex-challenge/tests/helpers`, not directly from `ember-qunit`.
- **No Mirage, no MSW.** Tests hit real fetch/services directly (acceptance test in
  `tests/acceptance/list-test.js` visits `/` and asserts on real DOM from the live
  service call — there's no mock server setup in this repo). If a test needs network
  isolation, that infrastructure doesn't exist yet — don't assume Mirage helpers like
  `this.server` are available.
- **Acceptance tests** (`tests/acceptance/`):
  ```js
  import { module, test } from 'qunit';
  import { visit, findAll } from '@ember/test-helpers';
  import { setupApplicationTest } from 'pokedex-challenge/tests/helpers';

  module('Acceptance | list', function (hooks) {
    setupApplicationTest(hooks);

    test('the index page shows the pokemon grid', async function (assert) {
      await visit('/');
      assert.strictEqual(findAll('.page > .pokemon-grid > .pokemon-card').length, 20);
    });
  });
  ```
- **Integration/component tests** (`tests/integration/components/`) use `.gjs` test files
  so the component under test can be rendered with an inline `<template>`:
  ```js
  import { module, test } from 'qunit';
  import { setupRenderingTest } from 'pokedex-challenge/tests/helpers';
  import { render } from '@ember/test-helpers';
  import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

  module('Integration | Component | evolution-chain', function (hooks) {
    setupRenderingTest(hooks);

    test('renders the evolution line in order', async function (assert) {
      await render(<template><EvolutionChain @pokemonId={{1}} /></template>);
      assert.ok(true);
    });
  });
  ```
- **Unit/service tests** (`tests/unit/services/`) here still use `setupRenderingTest` and
  render a throwaway `<template>` to assert on tracked-property reactivity via
  `this.owner.lookup('service:...')` + `settled()` — see
  `tests/unit/services/favorites-test.gjs`. Match this style for new service tests.
- Test file extension is `.gjs` whenever the test needs to render a `<template>` inline;
  plain `.js` is fine for tests with no rendering (none currently exist, but acceptance
  tests that only `visit()`/`findAll()` still use `.js`, e.g. `list-test.js`).
- Run: `npm test` (production-mode-free dev build + testem), or filter via
  `--filter` / the QUnit UI at `http://localhost:4200/tests`.

## 6. Directory & naming conventions

- **Standard layout, not pods.** Flat folders: `app/components/`, `app/routes/`,
  `app/services/`, `app/templates/`. No `app/pods/`, no colocated
  `component-name/index.gjs` folders — components are single files directly in
  `app/components/`.
- **kebab-case filenames** matching kebab-case module/import names:
  `favorite-button.gjs`, `pokemon-detail.gjs`, `featured-rotator.gjs`, `poke-data.js`,
  `type-badge.gjs`. Class names are PascalCase of the same
  (`FavoriteButton`, `PokemonDetail`, `PokeDataService`).
- Import components/services by full app-prefixed path:
  `pokedex-challenge/components/pokemon-card`,
  `pokedex-challenge/tests/helpers`. The app's module prefix is `pokedex-challenge`
  (from `app/config/environment.js`).
- Routes are declared in `app/router.js` with `this.route('name', { path: '...' })`;
  dynamic segments use `:snake_case_id` (e.g. `:pokemon_id`) per Ember convention, and
  the model hook returns `params.pokemon_id` as-is (see `app/routes/pokemon.js`).
- One route file per route name (`favorites.js`, `index.js` implicit for `/`,
  `pokemon.js`), matching template file names 1:1 (`favorites.gjs`, `index.gjs`,
  `pokemon.gjs`).
- Linting enforces style: `eslint` (JS/TS + `eslint-plugin-ember`), `ember-template-lint`
  (extends `recommended`, config at `.template-lintrc.mjs`), `stylelint` for CSS,
  `prettier` (with `prettier-plugin-ember-template-tag` for `.gjs` template formatting).
  Run `npm run lint:fix` before considering work done.

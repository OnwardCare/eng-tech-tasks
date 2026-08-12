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

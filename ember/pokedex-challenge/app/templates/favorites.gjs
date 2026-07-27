import { pageTitle } from 'ember-page-title';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

<template>
  {{pageTitle "Favorites"}}

  <h1>Favorites</h1>

  {{! Read from the controller's service ref so the list reacts to toggles immediately }}
  {{#if this.favorites.items.length}}
    <div class="pokemon-grid">
      {{#each this.favorites.items as |pokemon|}}
        <PokemonCard @pokemon={{pokemon}} />
      {{/each}}
    </div>
  {{else}}
    <p class="empty-state">
      No favorites yet. Star some Pokémon and they will show up here.
    </p>
  {{/if}}
</template>

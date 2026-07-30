import { LinkTo } from '@ember/routing';
import FavoriteButton from 'pokedex-challenge/components/favorite-button';
import TypeBadge from 'pokedex-challenge/components/type-badge';

<template>
  <div class="pokemon-card {{if @highlight 'is-highlighted'}}">
    {{#unless @simplified}}
      <FavoriteButton @pokemon={{@pokemon}} />
    {{/unless}}
    <LinkTo @route="pokemon" @model={{@pokemon.id}} class="pokemon-link">
      <img
        src={{@pokemon.sprite}}
        alt={{@pokemon.name}}
        class="pokemon-sprite"
      />
      <h3 class="pokemon-name">{{@pokemon.name}}</h3>
    </LinkTo>
    {{#unless @simplified}}
      <span class="pokemon-id">#{{@pokemon.id}}</span>
      <div class="pokemon-types">
        {{#each @pokemon.types as |type|}}
          <TypeBadge @type={{type}} />
        {{/each}}
      </div>
    {{/unless}}
  </div>
</template>

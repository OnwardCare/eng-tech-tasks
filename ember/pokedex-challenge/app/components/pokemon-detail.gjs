import FavoriteButton from 'pokedex-challenge/components/favorite-button';
import TypeBadge from 'pokedex-challenge/components/type-badge';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

<template>
  <div class="pokemon-detail" data-pokemon-id={{@pokemon.id}}>
    <div class="detail-header">
      <img
        src={{@pokemon.artwork}}
        alt={{@pokemon.name}}
        class="detail-artwork"
      />
      <div class="detail-summary">
        <h1 class="detail-name">
          {{@pokemon.name}}
          <span class="detail-id">#{{@pokemon.id}}</span>
          <FavoriteButton @pokemon={{@pokemon}} />
        </h1>
        <div class="pokemon-types">
          {{#each @pokemon.types as |type|}}
            <TypeBadge @type={{type}} />
          {{/each}}
        </div>
        <p class="flavor-text">{{@pokemon.flavorText}}</p>
        <p class="detail-measurements">
          Height:
          {{@pokemon.height}}
          &middot; Weight:
          {{@pokemon.weight}}
        </p>
      </div>
    </div>

    <section class="detail-section">
      <h2>Abilities</h2>
      <ul class="ability-list">
        {{#each @pokemon.abilities as |ability|}}
          <li>{{ability}}</li>
        {{/each}}
      </ul>
    </section>

    <section class="detail-section">
      <h2>Base stats</h2>
      <ul class="stat-list">
        {{#each @pokemon.stats as |stat|}}
          <li>
            <span class="stat-name">{{stat.name}}</span>
            <span class="stat-value">{{stat.value}}</span>
          </li>
        {{/each}}
      </ul>
    </section>

    <section class="detail-section">
      <h2>Evolution chain</h2>
      <EvolutionChain @stages={{@pokemon.evolutionStages}} />
    </section>
  </div>
</template>

import FavoriteButton from 'pokedex-challenge/components/favorite-button';
import TypeBadge from 'pokedex-challenge/components/type-badge';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

<template>
  <div class="pokemon-detail">
    <div class="detail-header">
      <img src={{@model.artwork}} alt={{@model.name}} class="detail-artwork" />
      <div class="detail-summary">
        <h1 class="detail-name">
          {{@model.name}}
          <span class="detail-id">#{{@model.id}}</span>
          <FavoriteButton @pokemon={{@model}} />
        </h1>
        <div class="pokemon-types">
          {{#each @model.types as |type|}}
            <TypeBadge @type={{type}} />
          {{/each}}
        </div>
        <p class="flavor-text">{{@model.flavorText}}</p>
        <p class="detail-measurements">
          Height:
          {{@model.height}}
          &middot; Weight:
          {{@model.weight}}
        </p>
      </div>
    </div>

    <section class="detail-section">
      <h2>Abilities</h2>
      <ul class="ability-list">
        {{#each @model.abilities as |ability|}}
          <li>{{ability}}</li>
        {{/each}}
      </ul>
    </section>

    <section class="detail-section">
      <h2>Base stats</h2>
      <ul class="stat-list">
        {{#each @model.stats as |stat|}}
          <li>
            <span class="stat-name">{{stat.name}}</span>
            <span class="stat-value">{{stat.value}}</span>
          </li>
        {{/each}}
      </ul>
    </section>

    <section class="detail-section">
      <h2>Evolution chain</h2>
      <EvolutionChain @chain={{@model.evolutionChain}} />
    </section>
  </div>
</template>

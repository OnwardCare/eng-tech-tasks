import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import AsyncData from 'pokedex-challenge/utils/async-data';
import FavoriteButton from 'pokedex-challenge/components/favorite-button';
import TypeBadge from 'pokedex-challenge/components/type-badge';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

export default class PokemonDetail extends Component {
  @service pokeData;

  @cached
  get pokemonData() {
    const pokemonId = this.args.pokemonId;
    return new AsyncData(() => this.pokeData.fetchPokemon(pokemonId));
  }

  @cached
  get speciesData() {
    const pokemonId = this.args.pokemonId;
    return new AsyncData(() => this.pokeData.fetchSpecies(pokemonId));
  }

  get pokemon() {
    const data = this.pokemonData.value;

    if (!data) {
      return null;
    }

    return {
      id: data.id,
      name: data.name,
      height: data.height,
      weight: data.weight,
      artwork: data.sprites.other['official-artwork'].front_default,
      sprite: data.sprites.front_default,
      types: data.types.map((t) => t.type.name),
      abilities: data.abilities.map((a) => a.ability.name),
      stats: data.stats.map((s) => ({
        name: s.stat.name,
        value: s.base_stat,
      })),
    };
  }

  get flavorText() {
    const entry = this.speciesData.value?.flavor_text_entries.find(
      (e) => e.language.name === 'en',
    );

    return entry ? entry.flavor_text.replace(/\s+/g, ' ') : '';
  }

  <template>
    <div class="pokemon-detail">
      {{#if this.pokemon}}
        <div class="detail-header">
          <img
            src={{this.pokemon.artwork}}
            alt={{this.pokemon.name}}
            class="detail-artwork"
          />
          <div class="detail-summary">
            <h1 class="detail-name">
              {{this.pokemon.name}}
              <span class="detail-id">#{{this.pokemon.id}}</span>
              <FavoriteButton @pokemon={{this.pokemon}} />
            </h1>
            <div class="pokemon-types">
              {{#each this.pokemon.types as |type|}}
                <TypeBadge @type={{type}} />
              {{/each}}
            </div>
            <p class="flavor-text">{{this.flavorText}}</p>
            <p class="detail-measurements">
              Height:
              {{this.pokemon.height}}
              &middot; Weight:
              {{this.pokemon.weight}}
            </p>
          </div>
        </div>

        <section class="detail-section">
          <h2>Abilities</h2>
          <ul class="ability-list">
            {{#each this.pokemon.abilities as |ability|}}
              <li>{{ability}}</li>
            {{/each}}
          </ul>
        </section>

        <section class="detail-section">
          <h2>Base stats</h2>
          <ul class="stat-list">
            {{#each this.pokemon.stats as |stat|}}
              <li>
                <span class="stat-name">{{stat.name}}</span>
                <span class="stat-value">{{stat.value}}</span>
              </li>
            {{/each}}
          </ul>
        </section>

        <section class="detail-section">
          <h2>Evolution chain</h2>
          <EvolutionChain @pokemonId={{this.pokemon.id}} />
        </section>
      {{else if this.pokemonData.error}}
        <p class="detail-status">Could not load this Pokémon.</p>
      {{else}}
        <p class="detail-status">Loading…</p>
      {{/if}}
    </div>
  </template>
}

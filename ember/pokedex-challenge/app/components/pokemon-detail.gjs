import Component from '@glimmer/component';
import { service } from '@ember/service';
import { modifier } from 'ember-modifier';
import { tracked } from '@glimmer/tracking';
import FavoriteButton from 'pokedex-challenge/components/favorite-button';
import TypeBadge from 'pokedex-challenge/components/type-badge';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

export default class PokemonDetail extends Component {
  @service pokeData;

  @tracked pokemon = null;
  @tracked flavorText = '';
  @tracked evolutionChainUrl = null;
  @tracked isLoading = false;
  @tracked error = null;

  constructor() {
    super(...arguments);
  }

  loadOnPokemonIdChange = modifier((_element, [pokemonId]) => {
    this.loadPokemon(pokemonId);
  });


  async loadPokemon(pokemonId) {
    this.isLoading = true;
    this.error = null;
    try {
    const [data, species] = await Promise.all([
      this.pokeData.fetchPokemon(pokemonId),
      this.pokeData.fetchSpecies(pokemonId),
    ]);

    this.isLoading = false;
    this.pokemon = {
      id: data.id,
      name: data.name,
      height: data.height,
      weight: data.weight,
      artwork: data.sprites.other['official-artwork'].front_default,
      types: data.types.map((t) => t.type.name),
      abilities: data.abilities.map((a) => a.ability.name),
      stats: data.stats.map((s) => ({
        name: s.stat.name,
        value: s.base_stat,
      })),
    };
    const entry = species.flavor_text_entries.find(
      (e) => e.language.name === 'en',
    );
    this.flavorText = entry ? entry.flavor_text : '';
    this.evolutionChainUrl = species.evolution_chain?.url || null;
  } catch (e) {
    this.isLoading = false;
    this.error = e.message || 'An error occurred';
  }
  }

  <template>
    <div class="pokemon-detail" {{this.loadOnPokemonIdChange @pokemonId}}>
      {{#if this.isLoading}}
        <p class="loading-state">Loading Pokémon…</p>
      {{else if this.error}}
        <p class="error-state">{{this.error}}</p>
      {{else if this.pokemon}}
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
              Height: {{this.pokemon.height}} &middot; Weight:
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
          <EvolutionChain @evolutionChainUrl={{this.evolutionChainUrl}} />
        </section>
      {{/if}}
    </div>
  </template>
}

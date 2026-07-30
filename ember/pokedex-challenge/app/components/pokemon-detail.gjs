import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import { LinkTo } from '@ember/routing';
import FavoriteButton from 'pokedex-challenge/components/favorite-button';
import TypeBadge from 'pokedex-challenge/components/type-badge';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

export default class PokemonDetail extends Component {
  @service pokeData;

  @tracked pokemon = null;
  @tracked flavorText = '';
  @tracked isLoading = false;
  @tracked error = null;

  loadOnIdChange = modifier((_element, [pokemonId]) => {
    this.loadPokemon(pokemonId);
  });

  async loadPokemon(pokemonId) {
    this.isLoading = true;
    this.error = null;
    this.pokemon = null;
    this.flavorText = '';

    try {
      const data = await this.pokeData.fetchPokemon(pokemonId);

      console.log('loaded pokemon', data.name);
      this.pokemon = {
        id: data.id,
        name: data.name,
        height: data.height,
        weight: data.weight,
        sprite: data.sprites.front_default, // Map sprite URL explicitly so PokemonCard can render the image on the /favorites page
        artwork: data.sprites.other['official-artwork'].front_default,
        types: data.types.map((t) => t.type.name),
        abilities: data.abilities.map((a) => a.ability.name),
        stats: data.stats.map((s) => ({
          name: s.stat.name,
          value: s.base_stat,
        })),
      };

      try {
        const species = await this.pokeData.fetchSpecies(data.id);
        const entry = species.flavor_text_entries.find(
          (e) => e.language.name === 'en',
        );
        this.flavorText = entry
          ? entry.flavor_text
          : 'No description available for this Pokémon.';
      } catch {
        this.flavorText = 'No description available for this Pokemon.';
      }
    } catch (err) {
      this.error = err.message || 'Failed to load Pokemon';
    } finally {
      this.isLoading = false;
    }
  }

  <template>
    <div class="pokemon-detail" {{this.loadOnIdChange @pokemonId}}>
      <LinkTo @route="index" class="back-link">← Back to list</LinkTo>

      {{#if this.isLoading}}
        <div class="list-loading">Loading Pokemon...</div>
      {{else if this.error}}
        <div class="error-state" role="alert">
          <p>{{this.error}}</p>
        </div>
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
      {{/if}}
    </div>
  </template>
}

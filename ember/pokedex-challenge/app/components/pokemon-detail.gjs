import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { modifier } from 'ember-modifier';
import FavoriteButton from 'pokedex-challenge/components/favorite-button';
import TypeBadge from 'pokedex-challenge/components/type-badge';
import EvolutionChain from 'pokedex-challenge/components/evolution-chain';

export default class PokemonDetail extends Component {
  @service pokeData;

  @tracked pokemon = null;
  @tracked flavorText = '';
  @tracked isLoading = true;
  @tracked error = null;

  // The detail route reuses this component instance when only the dynamic
  // segment changes (e.g. navigating between evolution stages), so a
  // constructor-only fetch would only ever run once. This modifier re-runs
  // whenever @pokemonId changes, keeping the page in sync with the route.
  loadOnChange = modifier((_element, [pokemonId]) => {
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

      // Guard against a slower, now-stale request resolving after a newer
      // one has already started (e.g. rapidly clicking evolution stages),
      // or after the component itself has been torn down entirely.
      if (
        this.isDestroying ||
        this.isDestroyed ||
        String(pokemonId) !== String(this.args.pokemonId)
      ) {
        return;
      }

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
      // The API's flavor text is riddled with line-break control characters.
      this.flavorText = entry
        ? entry.flavor_text.replace(/[\n\f\r]+/g, ' ')
        : '';
    } catch {
      if (this.isDestroying || this.isDestroyed) {
        return;
      }
      this.error = `Could not load Pokémon #${pokemonId}.`;
    } finally {
      if (!this.isDestroying && !this.isDestroyed) {
        this.isLoading = false;
      }
    }
  }

  <template>
    <div class="pokemon-detail" {{this.loadOnChange @pokemonId}}>
      {{#if this.isLoading}}
        <p class="detail-loading">Loading Pokémon&hellip;</p>
      {{else if this.error}}
        <p class="detail-error">{{this.error}}</p>
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

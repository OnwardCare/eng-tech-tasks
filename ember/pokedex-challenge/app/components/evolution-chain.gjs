import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

export default class EvolutionChainComponent extends Component {
  @service pokeData;

  @tracked isLoading = true;
  @tracked error = null;
  @tracked evolutionChain = [];

  loadOnIdChange = modifier((_element, [pokemonId]) => {
    this.loadData(pokemonId);
  });

  async loadData(pokemonId) {
    try {
      this.isLoading = true;
      this.error = null;

      // Step 1: Fetch species info to get evolution_chain.url for the given pokemon id
      const data = await this.pokeData.fetchEvolutionChain(pokemonId);

      if (data.unavailable) {
        this.error = data.message;
        return;
      }

      // Step 2: Flatten the evolution chain to get each stage's id and name
      const stagesInfo = this.flattenEvolutionChain(data.chain);

      // Step 3: Fetch pokemon data (picture and types) for each stage to satisfy PokemonCard payload
      this.evolutionChain = await Promise.all(
        stagesInfo.map(async (stage) => {
          const pokemonData = await this.pokeData.fetchPokemon(stage.id);
          const isActive = String(stage.id) === String(pokemonId);
          return {
            isActive,
            data: {
              id: stage.id,
              name: stage.name,
              sprite:
                pokemonData.sprites.front_default ||
                pokemonData.sprites.other?.['official-artwork']?.front_default,
              types: pokemonData.types.map((t) => t.type.name),
            },
          };
        }),
      );
      return this.evolutionChain;
    } catch (err) {
      this.error = err.message || 'Error loading evolution chain';
    } finally {
      this.isLoading = false;
    }
  }

  // Helper function to flatten the evolution chain to get each stage's id and name
  flattenEvolutionChain(node, result = []) {
    if (!node) return result;

    const urlSegments = node.species.url.split('/').filter(Boolean);
    const id = urlSegments[urlSegments.length - 1];

    result.push({
      id,
      name: node.species.name,
    });

    if (node.evolves_to && node.evolves_to.length > 0) {
      this.flattenEvolutionChain(node.evolves_to[0], result);
    }

    return result;
  }

  // Helper function to determine if an arrow should be displayed between two stages
  hasArrow(currentIndex, totalLength) {
    return currentIndex < totalLength - 1;
  }

  <template>
    <div class="evolution-placeholder" {{this.loadOnIdChange @pokemonId}}>
      {{#if this.isLoading}}
        <div class="evolution-loading">Loading evolution chain...</div>
      {{else if this.error}}
        <div class="evolution-error">{{this.error}}</div>
      {{else}}
        <div class="pokemon-grid">
          {{#each this.evolutionChain as |stage index|}}
            <div class="evolution-stage {{if stage.isActive 'is-active'}}">
              <PokemonCard
                @pokemon={{stage.data}}
                @simplified={{true}}
                @highlight={{stage.isActive}}
              />
            </div>

            {{#if (this.hasArrow index this.evolutionChain.length)}}
              <span class="evolution-arrow">→</span>
            {{/if}}
          {{/each}}
        </div>
      {{/if}}
    </div>
  </template>
}

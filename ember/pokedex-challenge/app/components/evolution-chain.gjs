import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { LinkTo } from '@ember/routing';

const BASE_URL = 'https://pokeapi.co/api/v2';

function idFromUrl(url) {
  const parts = url.split('/').filter(Boolean);
  return parts[parts.length - 1];
}

export default class EvolutionChain extends Component {
  @tracked stages = [];
  loadedPokemonId = null;

  constructor() {
    super(...arguments);
    this.loadChain();
  }

  // Reading this from the template makes the getter re-run whenever
  // @pokemonId changes, even when the `pokemon` route reuses this same
  // component instance across dynamic-segment-only transitions (e.g.
  // clicking one evolution stage to another) where the constructor won't
  // fire again on its own.
  get pokemonId() {
    const id = this.args.pokemonId;
    if (this.loadedPokemonId !== id) {
      queueMicrotask(() => this.loadChain());
    }
    return id;
  }

  async loadChain() {
    const id = this.args.pokemonId;
    if (this.loadedPokemonId === id) {
      return;
    }
    this.loadedPokemonId = id;

    const speciesResponse = await fetch(`${BASE_URL}/pokemon-species/${id}`);
    const species = await speciesResponse.json();
    const chainResponse = await fetch(species.evolution_chain.url);
    const { chain } = await chainResponse.json();

    const rawStages = [];
    let level = [chain];
    while (level.length > 0) {
      rawStages.push(
        level.map((node) => ({
          id: idFromUrl(node.species.url),
          name: node.species.name,
        })),
      );
      level = level.flatMap((node) => node.evolves_to);
    }

    this.stages = rawStages.map((pokemons, index) => ({
      pokemons,
      isLast: index === rawStages.length - 1,
    }));
  }

  <template>
    <div class="evolution-chain" data-pokemon-id={{this.pokemonId}}>
      {{#if this.stages.length}}
        {{#each this.stages as |stage|}}
          <div class="evolution-stage">
            {{#each stage.pokemons as |pokemon|}}
              <LinkTo
                @route="pokemon"
                @model={{pokemon.id}}
                class="evolution-stage-link"
              >
                {{pokemon.name}}
              </LinkTo>
            {{/each}}
          </div>
          {{#unless stage.isLast}}
            <span class="evolution-arrow">&rarr;</span>
          {{/unless}}
        {{/each}}
      {{else}}
        <div class="evolution-placeholder">Loading evolution chain&hellip;</div>
      {{/if}}
    </div>
  </template>
}

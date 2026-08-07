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

  constructor() {
    super(...arguments);
    this.loadChain();
  }

  async loadChain() {
    const speciesResponse = await fetch(
      `${BASE_URL}/pokemon-species/${this.args.pokemonId}`,
    );
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
    <div class="evolution-chain">
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

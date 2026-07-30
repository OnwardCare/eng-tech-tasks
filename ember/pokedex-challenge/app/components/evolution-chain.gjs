import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';

function idFromSpeciesUrl(url) {
  return url.match(/\/(\d+)\/?$/)[1];
}

export default class EvolutionChain extends Component {
  @service pokeData;

  @tracked stages = null;
  @tracked error = false;

  constructor() {
    super(...arguments);
    this.load();
  }

  async load() {
    this.stages = null;
    this.error = false;
    try {
      const species = await this.pokeData.fetchSpecies(this.args.pokemonId);
      const { chain } = await this.pokeData.fetchEvolutionChain(
        species.evolution_chain.url,
      );
      this.stages = this.flatten(chain);
    } catch (error) {
      this.error = true;
      console.error(error);
    }
  }

  // Recursion for the evolution in order stage.
  flatten(node) {
    const stages = [];
    let current = [node];
    while (current.length) {
      stages.push(
        current.map((entry) => ({
          id: idFromSpeciesUrl(entry.species.url),
          name: entry.species.name,
        })),
      );
      current = current.flatMap((entry) => entry.evolves_to);
    }

    return stages;
  }

  <template>
    <div class="evolution-chain">
      {{#if this.error}}
        <p class="evolution-error">Couldn't load the evolution chanin.</p>
      {{else if this.stages}}
      <ol class="evolution-stages">
        {{#each this.stages as |stage|}}
        <li class="evolution-stage">
          {{#each stage as |pokemon|}}
          <LinkTo @route="pokemon" @model={{pokemon.id}} class="evolution-link">
          {{pokemon.name}}
          </LinkTo>
          {{/each}}
        </li>
        {{/each}}
      </ol>
      {{else}}
        <p class="evolution-loading">Loading evolution chain.</p>
      {{/if}}
    </div>
  </template>
}

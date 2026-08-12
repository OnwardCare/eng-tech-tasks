import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { LinkTo } from '@ember/routing';
import { modifier } from 'ember-modifier';

const ARTWORK_BASE_URL =
  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';

// NOTE: I use a Node, since Eevee is a special case that evolves depending on the stone used
const EvolutionNode = <template>
  <div class="evolution-node">
    {{#if @stage.isCurrent}}
      <div class="evolution-stage evolution-stage-current" aria-current="page">
        <img
          src={{@stage.artwork}}
          alt={{@stage.name}}
          class="evolution-stage-artwork"
        />
        <span class="evolution-stage-name">{{@stage.name}}</span>
        <span class="evolution-stage-badge">Current</span>
      </div>
    {{else}}
      <LinkTo @route="pokemon" @model={{@stage.id}} class="evolution-stage">
        <img
          src={{@stage.artwork}}
          alt={{@stage.name}}
          class="evolution-stage-artwork"
        />
        <span class="evolution-stage-name">{{@stage.name}}</span>
      </LinkTo>
    {{/if}}

    {{#if @stage.children}}
      <div class="evolution-children">
        {{#each @stage.children as |child|}}
          <div class="evolution-branch">
            <span class="evolution-arrow">→</span>
            <EvolutionNode @stage={{child}} />
          </div>
        {{/each}}
      </div>
    {{/if}}
  </div>
</template>;

export default class EvolutionChain extends Component {
  @tracked tree = null;
  @tracked isLoading = true;
  @tracked error = null;

  watchPokemonId = modifier((element, [pokemonId]) => {
    this.loadEvolutionChain(pokemonId);
  });

  extractIdFromUrl(url) {
    const match = url.match(/\/(\d+)\/?$/);
    return match ? Number(match[1]) : null;
  }

  buildTree(node, currentId) {
    const id = this.extractIdFromUrl(node.species.url);
    const isCurrent = id === currentId;

    return {
      id,
      name: node.species.name,
      artwork: `${ARTWORK_BASE_URL}/${id}.png`,
      isCurrent,
      children: node.evolves_to.map((child) =>
        this.buildTree(child, currentId),
      ),
    };
  }

  async loadEvolutionChain(pokemonId) {
    this.isLoading = true;
    this.error = null;
    this.tree = null;

    try {
      const speciesResponse = await fetch(
        `https://pokeapi.co/api/v2/pokemon-species/${pokemonId}`,
      );
      if (!speciesResponse.ok) {
        throw new Error('species request failed');
      }
      const species = await speciesResponse.json();

      const chainResponse = await fetch(species.evolution_chain.url);
      if (!chainResponse.ok) {
        throw new Error('evolution chain request failed');
      }
      const chainData = await chainResponse.json();

      this.tree = this.buildTree(chainData.chain, Number(pokemonId));
    } catch (e) {
      console.error('Failed to load evolution chain', e);
      this.error = 'Could not load evolution chain.';
    } finally {
      this.isLoading = false;
    }
  }

  <template>
    <div class="evolution-chain" {{this.watchPokemonId @pokemonId}}>
      {{#if this.isLoading}}
        <p class="evolution-loading">Loading evolution chain...</p>
      {{else if this.error}}
        <p class="evolution-error">{{this.error}}</p>
      {{else if this.tree}}
        <EvolutionNode @stage={{this.tree}} />
      {{/if}}
    </div>
  </template>
}

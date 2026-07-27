import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import { modifier } from 'ember-modifier';
import { idFromUrl } from 'pokedex-challenge/utils/pokemon';

function buildTree(node) {
  return {
    id: idFromUrl(node.species.url),
    name: node.species.name,
    sprite: null,
    children: node.evolves_to.map(buildTree),
  };
}

function flatten(node, acc = []) {
  acc.push(node);
  for (const child of node.children) {
    flatten(child, acc);
  }
  return acc;
}

const EvolutionStage = <template>
  <li class="evolution-stage">
    <LinkTo @route="pokemon" @model={{@node.id}} class="evolution-link">
      {{#if @node.sprite}}
        <img src={{@node.sprite}} alt={{@node.name}} class="evolution-sprite" />
      {{/if}}
      <span class="evolution-name">{{@node.name}}</span>
    </LinkTo>

    {{#if @node.children.length}}
      <ul class="evolution-branches">
        {{#each @node.children as |child|}}
          <li class="evolution-branch">
            <span class="evolution-arrow" aria-hidden="true">&rarr;</span>
            <EvolutionStage @node={{child}} />
          </li>
        {{/each}}
      </ul>
    {{/if}}
  </li>
</template>;

export default class EvolutionChain extends Component {
  @service pokeData;

  @tracked tree = null;
  @tracked isLoading = true;
  @tracked error = null;

  loadOnChange = modifier((_element, [pokemonId]) => {
    this.load(pokemonId);
  });

  async load(pokemonId) {
    this.isLoading = true;
    this.error = null;

    try {
      const species = await this.pokeData.fetchSpecies(pokemonId);
      const chainData = await this.pokeData.fetchEvolutionChain(
        species.evolution_chain.url,
      );
      const tree = buildTree(chainData.chain);

      const stages = flatten(tree);
      await Promise.all(
        stages.map(async (stage) => {
          const pokemon = await this.pokeData.fetchPokemon(stage.id);
          stage.sprite = pokemon.sprites?.front_default ?? null;
        }),
      );

      // Guard against a slower, now-stale chain resolving after the user has
      // already navigated to a different Pokémon (e.g. clicking evolution
      // links quickly), and against the component being torn down entirely
      // while the fetch was still in flight.
      if (
        this.isDestroying ||
        this.isDestroyed ||
        String(pokemonId) !== String(this.args.pokemonId)
      ) {
        return;
      }

      this.tree = tree;
    } catch {
      if (this.isDestroying || this.isDestroyed) {
        return;
      }
      this.error = 'Could not load the evolution chain.';
    } finally {
      if (!this.isDestroying && !this.isDestroyed) {
        this.isLoading = false;
      }
    }
  }

  <template>
    <div class="evolution-chain" {{this.loadOnChange @pokemonId}}>
      {{#if this.isLoading}}
        <p class="evolution-loading">Loading evolution chain&hellip;</p>
      {{else if this.error}}
        <p class="evolution-error">{{this.error}}</p>
      {{else if this.tree}}
        <ul class="evolution-tree">
          <EvolutionStage @node={{this.tree}} />
        </ul>
      {{/if}}
    </div>
  </template>
}

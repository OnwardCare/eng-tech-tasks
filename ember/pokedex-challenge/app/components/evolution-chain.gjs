
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { modifier } from 'ember-modifier';
import { tracked } from '@glimmer/tracking';
import { LinkTo } from '@ember/routing';

function idFromSpeciesUrl(url) {
  const match = url.match(/\/(\d+)\/?$/);
  return match ? Number(match[1]) : null;
}

const evolutionChainToArray = (chain) => {
  const evolutions = [];
  let currentStage = [chain];

  while (currentStage.length > 0) {
    evolutions.push(
      currentStage.map((node) => ({
        id: idFromSpeciesUrl(node.species.url),
        name: node.species.name,
        spriteUrl: `${SPRITE_BASE_URL}/${idFromSpeciesUrl(node.species.url)}.png`,
      })),
    );
    currentStage = currentStage.flatMap((node) => node.evolves_to);
  }

  return evolutions;
};

const SPRITE_BASE_URL =
  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';

export default class EvolutionChainComponent extends Component {
  @service pokeData;

  @tracked evolutions = [];
  @tracked isLoading = false;
  @tracked error = null;

  loadOnUrlChange = modifier((_element, [url]) => {
    this.load(url);
  });

  async load(url) {
    this.isLoading = true;
    this.error = null;
    this.evolutions = [];

    if(!url) {
      this.isLoading = false;
      return;
    }

    try {
      const chain = await this.pokeData.fetchEvolutionChain(url);
      console.log('Fetched evolution chain:', chain);
      this.evolutions = evolutionChainToArray(chain.chain);
      console.log('Processed evolutions:', this.evolutions);
    } catch (e) {
      this.error = e;
    } finally {
      this.isLoading = false;
    }
  }

  get evolutionPokemons() {
    return this.evolutions.flat();
  }


  <template>
    <div class="evolution-chain" {{this.loadOnUrlChange @evolutionChainUrl}}>
      {{#if this.isLoading}}
        <p>Loading evolution chain...</p>
      {{else if this.error}}
        <p>Error loading evolution chain: {{this.error.message}}</p>
      {{else if this.evolutions.length}}
          {{#each this.evolutionPokemons as |pokemon|}}
            <LinkTo
                @route="pokemon"
                @model={{pokemon.id}}
                class="evolution-pokemon"
              >
                <img
                  src={{pokemon.spriteUrl}}
                  alt={{pokemon.name}}
                  class="evolution-sprite"
                />
                <span class="evolution-name">{{pokemon.name}}</span>
              </LinkTo>
          {{/each}}
      {{else}}
        <p>No evolution chain available.</p>
      {{/if}}

    </div>
  </template>
}
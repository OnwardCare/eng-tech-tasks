import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import AsyncData from 'pokedex-challenge/utils/async-data';

export default class EvolutionChain extends Component {
  @service pokeData;

  @cached
  get data() {
    const pokemonId = this.args.pokemonId;
    return new AsyncData(() => this.pokeData.fetchEvolutionPaths(pokemonId));
  }

  get paths() {
    const currentId = Number(this.args.pokemonId);
    const paths = this.data.value ?? [];
    const ownPaths = paths.filter((path) =>
      path.some((pokemon) => pokemon.id === currentId),
    );

    return (ownPaths.length > 0 ? ownPaths : paths).map((path) =>
      path.map((pokemon) => ({
        ...pokemon,
        isCurrent: pokemon.id === currentId,
      })),
    );
  }

  get doesNotEvolve() {
    return (
      !this.data.isLoading &&
      !this.data.error &&
      this.paths.every((path) => path.length < 2)
    );
  }

  <template>
    <div class="evolution-chain">
      {{#if this.data.isLoading}}
        <p class="evolution-status">Loading evolution chain…</p>
      {{else if this.data.error}}
        <p class="evolution-status evolution-error">
          Could not load the evolution chain.
        </p>
      {{else}}
        <ol class="evolution-paths">
          {{#each this.paths as |path|}}
            <li class="evolution-path">
              {{#each path as |pokemon|}}
                <span class="evolution-step">
                  <LinkTo
                    @route="pokemon"
                    @model={{pokemon.id}}
                    class="evolution-link {{if pokemon.isCurrent 'is-current'}}"
                    aria-current={{if pokemon.isCurrent "page"}}
                  >
                    {{#if pokemon.sprite}}
                      <img
                        src={{pokemon.sprite}}
                        alt={{pokemon.name}}
                        class="evolution-sprite"
                        loading="lazy"
                      />
                    {{/if}}
                    <span class="evolution-name">{{pokemon.name}}</span>
                  </LinkTo>
                </span>
              {{/each}}
            </li>
          {{/each}}
        </ol>

        {{#if this.doesNotEvolve}}
          <p class="evolution-status">This Pokémon does not evolve.</p>
        {{/if}}
      {{/if}}
    </div>
  </template>
}

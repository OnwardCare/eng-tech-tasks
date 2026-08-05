import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { modifier } from 'ember-modifier';
import { LinkTo } from '@ember/routing';
import { flattenEvolutionChain } from 'pokedex-challenge/utils/evolution-chain';
import { GEN_1_COUNT } from 'pokedex-challenge/utils/pokeapi';

export default class EvolutionChain extends Component {
  @service pokeData;

  @tracked levels = null;
  @tracked hasError = false;

  loadChain = modifier((element, [url]) => {
    this.levels = null;
    this.hasError = false;
    this.fetchChain(url);
  });

  async fetchChain(url) {
    try {
      const { chain } = await this.pokeData.fetchEvolutionChain(url);
      if (url !== this.args.evolutionChainUrl) return;
      this.levels = flattenEvolutionChain(chain);
    } catch {
      if (url !== this.args.evolutionChainUrl) return;
      this.hasError = true;
    }
  }

  get decoratedLevels() {
    if (!this.levels) return null;
    return this.levels.map((level) =>
      level.map((stage) => ({
        ...stage,
        isCurrent: stage.id === this.args.currentId,
        isOutOfRange: stage.id > GEN_1_COUNT,
      })),
    );
  }

  <template>
    <div class="evolution-chain" {{this.loadChain @evolutionChainUrl}}>
      {{#if this.hasError}}
        <p class="evolution-error">Couldn't load the evolution chain.</p>
      {{else if this.decoratedLevels}}
        {{#each this.decoratedLevels as |level index|}}
          {{#if index}}
            <span class="evolution-arrow" aria-hidden="true">&rarr;</span>
          {{/if}}
          <div class="evolution-level">
            {{#each level as |stage|}}
              {{#if stage.isCurrent}}
                <span
                  class="evolution-stage is-current"
                  aria-current="page"
                >{{stage.name}}</span>
              {{else if stage.isOutOfRange}}
                <span
                  class="evolution-stage evolution-stage--locked"
                  title="{{stage.name}} is outside Generation 1 and isn't available in this Pokédex."
                  tabindex="0"
                >{{stage.name}}</span>
              {{else}}
                <LinkTo
                  @route="pokemon"
                  @model={{stage.id}}
                  class="evolution-stage"
                >
                  {{stage.name}}
                </LinkTo>
              {{/if}}
            {{/each}}
          </div>
        {{/each}}
      {{else}}
        <p class="evolution-loading">Loading evolution chain&hellip;</p>
      {{/if}}
    </div>
  </template>
}

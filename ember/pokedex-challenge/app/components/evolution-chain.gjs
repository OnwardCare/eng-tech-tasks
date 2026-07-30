import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { LinkTo } from '@ember/routing';

export default class EvolutionChain extends Component {
  @service evolutionChain;

  @tracked chain = null;
  @tracked isLoading = false;
  @tracked hasError = false;

  constructor() {
    super(...arguments);
    this.loadChain();
  }

  @action
  async loadChain() {
    this.isLoading = true;
    this.hasError = false;

    const result = await this.evolutionChain.fetchEvolutionChain(
      this.args.pokemonId,
    );

    if (result === null) {
      this.hasError = true;
      this.chain = null;
    } else {
      this.chain = result;
    }

    this.isLoading = false;
  }

  get stagesWithMeta() {
    if (!this.chain?.stages) {
      return [];
    }
    const lastIndex = this.chain.stages.length - 1;
    return this.chain.stages.map((stage, index) => ({
      ...stage,
      isLast: index === lastIndex,
    }));
  }

  <template>
    <div class="evolution-chain">
      {{#if this.isLoading}}
        <div class="evolution-loading" role="status" aria-live="polite">
          <span class="spinner" aria-hidden="true"></span>
          <span class="evolution-loading-text">Loading evolution chain…</span>
        </div>
      {{else if this.hasError}}
        <div class="evolution-error" role="alert">
          <p>Failed to load evolution chain. Please try again.</p>
          <button
            type="button"
            class="evolution-retry"
            {{on "click" this.loadChain}}
          >
            Retry
          </button>
        </div>
      {{else if this.chain.hasEvolution}}
        <ol class="evolution-line">
          {{#each this.stagesWithMeta as |stage|}}
            <li class="evolution-stage">
              <LinkTo
                @route="pokemon"
                @model={{stage.id}}
                class="evolution-link"
              >
                {{stage.name}}
              </LinkTo>
              {{#unless stage.isLast}}
                <span class="evolution-arrow" aria-hidden="true">→</span>
              {{/unless}}
            </li>
          {{/each}}
        </ol>
      {{else if this.chain}}
        <p class="evolution-none">This Pokémon does not evolve.</p>
      {{/if}}
    </div>
  </template>
}

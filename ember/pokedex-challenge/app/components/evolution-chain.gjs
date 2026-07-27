import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { LinkTo } from '@ember/routing';

export default class EvolutionChain extends Component {
  @tracked stages = null;
  @tracked error = null;

  constructor() {
    super(...arguments);
    this.load();
  }

  async load() {
    try {
      const response = await fetch(this.args.evolutionChainUrl);
      const data = await response.json();
      // Flatten the recursive chain structure into an ordered array of stages
      this.stages = this.flattenChain(data.chain);
    } catch {
      this.error = 'Could not load evolution chain.';
    }
  }

  // Walk the nested chain object recursively.
  // Each node has a species name/url and an array of evolves_to children.
  flattenChain(node) {
    const stages = [];
    let current = node;
    while (current) {
      const urlParts = current.species.url.split('/').filter(Boolean);
      stages.push({
        id: urlParts.at(-1),
        name: current.species.name,
      });
      // Gen-1 chains are linear, so we always take the first child
      current = current.evolves_to[0] ?? null;
    }
    return stages;
  }

  <template>
    {{#if this.error}}
      <p class="evolution-error">{{this.error}}</p>
    {{else if this.stages}}
      <ol class="evolution-chain">
        {{#each this.stages as |stage index|}}
          {{#if index}}
            <li class="evolution-arrow" aria-hidden="true">→</li>
          {{/if}}
          <li class="evolution-stage">
            <LinkTo @route="pokemon" @model={{stage.id}}>
              {{stage.name}}
            </LinkTo>
          </li>
        {{/each}}
      </ol>
    {{else}}
      <p class="evolution-loading">Loading…</p>
    {{/if}}
  </template>
}

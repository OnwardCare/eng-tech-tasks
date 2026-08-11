import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class EvolutionChain extends Component {
  @service pokeData;
  @tracked chainStringPath = '';

  constructor() {
    super(...arguments);

    this.loadChainEvolution();
  }

  async loadChainEvolution() {
    const response = await this.pokeData.fetchEvolutionChain(this.args.pokemonId);
    this.chainStringPath = response;
  }

  <template>
    <div class="evolution-placeholder">{{this.chainStringPath}}</div>
  </template>
}

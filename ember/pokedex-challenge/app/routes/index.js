import Route from '@ember/routing/route';
import { service } from '@ember/service';
import { PAGE_SIZE } from 'pokedex-challenge/components/pokemon-list';

export default class IndexRoute extends Route {
  @service pokeData;

  model() {
    return this.pokeData.fetchPage(0, PAGE_SIZE);
  }
}

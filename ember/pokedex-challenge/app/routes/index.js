import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class IndexRoute extends Route {
  @service pokeData;

  async model() {
    return this.pokeData.fetchPage(0, 20);
  }
}

import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class FavoritesRoute extends Route {
  @service favorites;

  model() {
    return this.favorites.items;
  }
}

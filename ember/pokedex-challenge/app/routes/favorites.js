import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class FavoritesRoute extends Route {
  @service favorites;

  async model() {
    // Ensure all favorited pokemon are loaded from PokéAPI if needed
    await this.favorites.preloadFavoritesIfNeeded();

    // Return the favorite items for the template to render
    return this.favorites.items;
  }
}

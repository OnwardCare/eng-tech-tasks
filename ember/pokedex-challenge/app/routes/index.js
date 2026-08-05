import Route from '@ember/routing/route';
import { service } from '@ember/service';
import { idFromUrl, toPokemonSummary } from 'pokedex-challenge/utils/pokeapi';

export default class IndexRoute extends Route {
  @service pokeData;

  async model() {
    const list = await this.pokeData.fetchList(0, 20);
    const details = await Promise.all(
      list.results.map((entry) =>
        this.pokeData.fetchPokemon(idFromUrl(entry.url)),
      ),
    );
    return details.map(toPokemonSummary);
  }
}

import Route from '@ember/routing/route';
import { service } from '@ember/service';
import { idFromUrl } from 'pokedex-challenge/utils/pokemon';

const GEN_1_COUNT = 151;

export default class IndexRoute extends Route {
  @service pokeData;

  // Gen 1 is a small, fixed set, so fetching the full name/id list once (a
  // single cheap request) lets the list component search, sort, and paginate
  // entirely client-side, only fetching full details (sprite/types) for
  // whichever 20 Pokemon are actually visible on the current page.
  async model() {
    const list = await this.pokeData.fetchList(0, GEN_1_COUNT);
    return list.results.map((entry) => ({
      id: idFromUrl(entry.url),
      name: entry.name,
    }));
  }
}

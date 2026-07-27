import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

const GEN_1_COUNT = 151;
const PAGE_SIZE = 20;

export default class PokemonList extends Component {
  @service pokeData;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';
  @tracked offset = 0;
  @tracked currentPage = null;

  get pokemon() {
    return this.currentPage || this.args.pokemon;
  }

  get filteredPokemon() {
    let results = this.pokemon;
    if (this.searchTerm) {
      results = results.filter((p) =>
        p.name.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    }
    if (this.sortBy === 'name') {
      // Sort on a copy to avoid mutating the cached page array
      return [...results].sort((a, b) => a.name.localeCompare(b.name));
    }
    return [...results].sort((a, b) => a.id - b.id);
  }

  @action
  updateSearch(event) {
    this.searchTerm = event.target.value;
  }

  @action
  updateSort(event) {
    this.sortBy = event.target.value;
  }

  // Shared helper to fetch a page by offset; uses the service for caching
  async _loadPage(offset) {
    const limit = Math.min(PAGE_SIZE, GEN_1_COUNT - offset);
    const list = await this.pokeData.fetchList(offset, limit);

    // Fetch all Pokémon on this page in parallel
    return Promise.all(
      list.results.map(async (entry) => {
        const detail = await this.pokeData.fetchPokemon(
          entry.url.split('/').at(-2),
        );
        return {
          id: detail.id,
          name: detail.name,
          sprite: detail.sprites.front_default,
          types: detail.types.map((t) => t.type.name),
        };
      }),
    );
  }

  @action
  async nextPage() {
    if (this.offset + PAGE_SIZE >= GEN_1_COUNT) {
      return;
    }
    this.offset = this.offset + PAGE_SIZE;
    this.currentPage = await this._loadPage(this.offset);
  }

  @action
  async previousPage() {
    if (this.offset === 0) {
      return;
    }
    this.offset = Math.max(0, this.offset - PAGE_SIZE);
    // First page was loaded by the route; restore it from args to avoid a redundant request
    if (this.offset === 0) {
      this.currentPage = null;
      return;
    }
    this.currentPage = await this._loadPage(this.offset);
  }

  <template>
    <FeaturedRotator />

    <div class="list-controls">
      <input
        type="text"
        placeholder="Search by name"
        value={{this.searchTerm}}
        class="search-input"
        {{on "input" this.updateSearch}}
      />
      <select class="sort-select" {{on "change" this.updateSort}}>
        <option value="id">Sort by ID</option>
        <option value="name">Sort by name</option>
      </select>
    </div>

    <div class="pokemon-grid">
      {{#each this.filteredPokemon as |pokemon|}}
        <PokemonCard @pokemon={{pokemon}} />
      {{/each}}
    </div>

    <div class="pagination">
      <button
        type="button"
        class="page-button"
        {{on "click" this.previousPage}}
      >
        Previous
      </button>
      <button type="button" class="page-button" {{on "click" this.nextPage}}>
        Next
      </button>
    </div>
  </template>
}

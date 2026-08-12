import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

const GEN_1_COUNT = 151;
const PAGE_SIZE = 20;
const SEARCH_DEBOUNCE_MS = 300;

export default class PokemonList extends Component {
  @service pokeData;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';
  @tracked offset = 0;
  @tracked currentPage = null;

  @tracked allNames = null;
  @tracked searchResults = null;
  @tracked isSearching = false;

  searchToken = 0;
  debounceTimer = null;
  pageToken = 0;

  get pokemon() {
    return this.currentPage || this.args.pokemon;
  }

  get filteredPokemon() {
    if (this.searchTerm) {
      const results = this.searchResults || [];
      return this.sortBy === 'name'
        ? [...results].sort((a, b) => a.name.localeCompare(b.name))
        : [...results].sort((a, b) => a.id - b.id);
    }
    return this.pokemon;
  }

  get hasPreviousPage() {
    return this.offset > 0;
  }

  get hasNextPage() {
    return this.offset + PAGE_SIZE < GEN_1_COUNT;
  }

  async ensureAllNamesLoaded() {
    if (this.allNames) {
      return this.allNames;
    }
    const list = await this.pokeData.fetchList(0, GEN_1_COUNT);
    this.allNames = list.results;
    return this.allNames;
  }

  async fetchDetails(entries) {
    return Promise.all(
      entries.map(async (entry) => {
        const response = await fetch(entry.url);
        const detail = await response.json();
        return {
          id: detail.id,
          name: detail.name,
          sprite: detail.sprites.front_default,
          types: detail.types.map((t) => t.type.name),
        };
      }),
    );
  }

  //NOTE: Pagination is always good...
  // but I noticed that sorting by name wasn't working correctly
  // In this case, loading all 151 Pokémon isn't too heavy, and the sort will work from A to Z
  // however, we are using pagination (1–20) to load the full information (evolutions, stats, etc.)
  async loadPage(newOffset, sortBy = this.sortBy) {
    const token = ++this.pageToken;
    const limit = Math.min(PAGE_SIZE, GEN_1_COUNT - newOffset);

    let entries;

    if (sortBy === 'name') {
      const allNames = await this.ensureAllNamesLoaded();
      const sorted = [...allNames].sort((a, b) => a.name.localeCompare(b.name));
      entries = sorted.slice(newOffset, newOffset + limit);
    } else {
      const list = await this.pokeData.fetchList(newOffset, limit);
      entries = list.results;
    }

    const page = await this.fetchDetails(entries);

    if (token !== this.pageToken) {
      return;
    }

    this.offset = newOffset;
    this.currentPage = page;
  }

  async performSearch(term) {
    const token = ++this.searchToken;
    this.isSearching = true;

    try {
      const allNames = await this.ensureAllNamesLoaded();
      const matches = allNames.filter((entry) =>
        entry.name.toLowerCase().includes(term.toLowerCase()),
      );
      const details = await this.fetchDetails(matches);

      if (token !== this.searchToken) {
        return;
      }
      this.searchResults = details;
    } catch (e) {
      console.error('Search failed', e);
      if (token === this.searchToken) {
        this.searchResults = [];
      }
    } finally {
      if (token === this.searchToken) {
        this.isSearching = false;
      }
    }
  }

  @action
  updateSearch(event) {
    const value = event.target.value;
    this.searchTerm = value;

    clearTimeout(this.debounceTimer);

    if (!value) {
      this.searchResults = null;
      this.isSearching = false;
      return;
    }

    this.debounceTimer = setTimeout(() => {
      this.performSearch(value);
    }, SEARCH_DEBOUNCE_MS);
  }

  @action
  updateSort(event) {
    this.sortBy = event.target.value;
    if (!this.searchTerm) {
      this.loadPage(0, this.sortBy);
    }
  }

  @action
  async nextPage() {
    if (!this.hasNextPage) {
      return;
    }
    await this.loadPage(this.offset + PAGE_SIZE);
  }

  @action
  async previousPage() {
    if (!this.hasPreviousPage) {
      return;
    }

    const newOffset = Math.max(0, this.offset - PAGE_SIZE);

    if (newOffset === 0 && this.sortBy === 'id') {
      this.offset = 0;
      this.currentPage = null;
      return;
    }

    await this.loadPage(newOffset);
  }

  <template>
    <FeaturedRotator />

    <div class="list-controls">
      <input
        type="text"
        placeholder="Search by name"
        aria-label="Search by name"
        value={{this.searchTerm}}
        class="search-input"
        {{on "input" this.updateSearch}}
      />
      <select
        aria-label="Sort pokemon"
        class="sort-select"
        value={{this.sortBy}}
        {{on "change" this.updateSort}}
      >
        <option value="id">Sort by ID</option>
        <option value="name">Sort by name</option>
      </select>
    </div>

    {{#if this.isSearching}}
      <p class="search-status">Searching...</p>
    {{/if}}

    <div class="pokemon-grid">
      {{#each this.filteredPokemon as |pokemon|}}
        <PokemonCard @pokemon={{pokemon}} />
      {{/each}}
    </div>

    {{#unless this.searchTerm}}
      <div class="pagination">
        <button
          type="button"
          class="page-button"
          disabled={{if this.hasPreviousPage false true}}
          {{on "click" this.previousPage}}
        >
          Previous
        </button>
        <button
          type="button"
          class="page-button"
          disabled={{if this.hasNextPage false true}}
          {{on "click" this.nextPage}}
        >
          Next
        </button>
      </div>
    {{/unless}}
  </template>
}

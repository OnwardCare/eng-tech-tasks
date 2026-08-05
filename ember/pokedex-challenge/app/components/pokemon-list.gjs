import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';
import { idFromUrl, toPokemonSummary } from 'pokedex-challenge/utils/pokeapi';

const GEN_1_COUNT = 151;
const PAGE_SIZE = 20;
const TOTAL_PAGES = Math.ceil(GEN_1_COUNT / PAGE_SIZE);

export default class PokemonList extends Component {
  @service pokeData;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';
  @tracked offset = 0;
  @tracked currentPage = null;
  @tracked isChangingPage = false;

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
      return results.sort((a, b) => a.name.localeCompare(b.name));
    }
    return results.sort((a, b) => a.id - b.id);
  }

  get pageNumber() {
    return this.offset / PAGE_SIZE + 1;
  }

  get totalPages() {
    return TOTAL_PAGES;
  }

  get isPreviousDisabled() {
    return this.offset === 0 || this.isChangingPage;
  }

  get isNextDisabled() {
    return this.offset + PAGE_SIZE >= GEN_1_COUNT || this.isChangingPage;
  }

  @action
  updateSearch(event) {
    this.searchTerm = event.target.value;
  }

  @action
  updateSort(event) {
    this.sortBy = event.target.value;
  }

  @action
  nextPage() {
    if (this.isNextDisabled) {
      return;
    }
    this.loadPage(this.offset + PAGE_SIZE);
  }

  @action
  previousPage() {
    if (this.isPreviousDisabled) {
      return;
    }
    this.loadPage(this.offset - PAGE_SIZE);
  }

  async loadPage(offset) {
    this.isChangingPage = true;
    try {
      if (offset === 0) {
        this.offset = 0;
        this.currentPage = null;
        return;
      }
      const limit = Math.min(PAGE_SIZE, GEN_1_COUNT - offset);
      const list = await this.pokeData.fetchList(offset, limit);
      const details = await Promise.all(
        list.results.map((entry) =>
          this.pokeData.fetchPokemon(idFromUrl(entry.url)),
        ),
      );
      this.offset = offset;
      this.currentPage = details.map(toPokemonSummary);
    } finally {
      this.isChangingPage = false;
    }
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
        disabled={{this.isPreviousDisabled}}
        {{on "click" this.previousPage}}
      >
        Previous
      </button>
      <span class="page-indicator">Page
        {{this.pageNumber}}
        of
        {{this.totalPages}}</span>
      <button
        type="button"
        class="page-button"
        disabled={{this.isNextDisabled}}
        {{on "click" this.nextPage}}
      >
        Next
      </button>
    </div>
  </template>
}

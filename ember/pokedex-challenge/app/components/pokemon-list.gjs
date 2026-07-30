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
  @tracked isLoading = false;
  @tracked pageError = false;

  pageCache = new Map();

  constructor() {
    super(...arguments);
    this.pageCache.set(0, this.args.pokemon);
  }

  get pokemon() {
    return this.currentPage ?? this.args.pokemon;
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

  get isFirstPage() {
    return this.offset === 0;
  }

  get isLastPage() {
    return this.offset + PAGE_SIZE >= GEN_1_COUNT;
  }

  get isPreviousDisabled() {
    return this.isFirstPage || this.isLoading;
  }

  get isNextDisabled() {
    return this.isLastPage || this.isLoading;
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
    if (this.isLastPage) {
      return;
    }
    this.goToOffset(this.offset + PAGE_SIZE);
  }

  @action
  previousPage() {
    if (this.isFirstPage) {
      return;
    }
    this.goToOffset(this.offset - PAGE_SIZE);
  }

  async goToOffset(offset) {
    const previousOffset = this.offset;
    this.offset = offset;
    this.pageError = false;

    if (this.pageCache.has(offset)) {
      this.currentPage = this.pageCache.get(offset);
      return;
    }

    this.isLoading = true;
    try {
      const limit = Math.min(PAGE_SIZE, GEN_1_COUNT - offset);
      const page = await this.pokeData.fetchPage(offset, limit);
      this.pageCache.set(offset, page);
      if (offset === this.offset) {
        this.currentPage = page;
      }
    } catch (error) {
      console.error(error);
      if (offset === this.offset) {
        this.offset = previousOffset;
        this.pageError = true;
      }
    } finally {
      this.isLoading = false;
    }
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
        class="sort-select"
        aria-label="Sort pokemon"
        {{on "change" this.updateSort}}
      >
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
        class="page-button page-button--previous"
        disabled={{this.isPreviousDisabled}}
        {{on "click" this.previousPage}}
      >
        Previous
      </button>
      <button
        type="button"
        class="page-button page-button--next"
        disabled={{this.isNextDisabled}}
        {{on "click" this.nextPage}}
      >
        Next
      </button>
      {{#if this.isLoading}}
        <span class="pagination-status">Loading…</span>
      {{else if this.pageError}}
        <span class="pagination-status pagination-error">
          Couldn't load that page. Try again.
        </span>
      {{/if}}
    </div>
  </template>
}

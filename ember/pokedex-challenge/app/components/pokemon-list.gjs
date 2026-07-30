import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { registerDestructor } from '@ember/destroyable';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';
import {
  PAGE_SIZE,
  API_POKEMON_LIMIT,
} from 'pokedex-challenge/services/poke-data';

const SEARCH_DEBOUNCE_MS = 300;
const MIN_SEARCH_LENGTH = 3;

export default class PokemonList extends Component {
  @service pokeData;
  @service listState;

  @tracked sortBy = 'id';
  @tracked currentPage = null;
  @tracked searchResults = null;
  @tracked isLoading = false;
  @tracked isSearching = false;
  @tracked error = null;

  #searchTimeout = null;

  constructor() {
    super(...arguments);
    registerDestructor(this, () => {
      clearTimeout(this.#searchTimeout);
    });

    if (this.listState.searchTerm.trim().length >= MIN_SEARCH_LENGTH) {
      this.runSearch(this.listState.searchTerm);
    }
  }

  get offset() {
    return this.listState.offset;
  }

  get searchTerm() {
    return this.listState.searchTerm;
  }

  get isSearchActive() {
    return this.searchTerm.trim().length >= MIN_SEARCH_LENGTH;
  }

  get pokemon() {
    return this.currentPage || this.args.pokemon;
  }

  get displayedPokemon() {
    const source = this.isSearchActive
      ? (this.searchResults ?? [])
      : (this.pokemon ?? []);
    const results = [...source];

    if (this.sortBy === 'name') {
      return results.sort((a, b) => a.name.localeCompare(b.name));
    }
    return results.sort((a, b) => a.id - b.id);
  }

  get showEmptySearch() {
    return (
      this.isSearchActive &&
      !this.isSearching &&
      !this.error &&
      this.searchResults?.length === 0
    );
  }

  @action
  updateSearch(event) {
    const value = event.target.value;
    this.listState.searchTerm = value;
    this.error = null;

    clearTimeout(this.#searchTimeout);
    this.#searchTimeout = setTimeout(() => {
      this.runSearch(value);
    }, SEARCH_DEBOUNCE_MS);
  }

  async runSearch(value) {
    const term = value.trim();

    if (term.length < MIN_SEARCH_LENGTH) {
      this.searchResults = null;
      this.isSearching = false;
      return;
    }

    this.isSearching = true;
    this.error = null;

    try {
      this.searchResults = await this.pokeData.searchPokemons(term);
    } catch (err) {
      this.error = err.message || 'Failed to search Pokemon';
      this.searchResults = [];
    } finally {
      this.isSearching = false;
    }
  }

  @action
  updateSort(event) {
    this.sortBy = event.target.value;
  }

  async loadPage(offset) {
    this.isLoading = true;
    this.error = null;
    try {
      const limit = Math.min(PAGE_SIZE, API_POKEMON_LIMIT - offset);
      const page = await this.pokeData.fetchPokemonPage(offset, limit);
      this.listState.offset = offset;
      this.currentPage = page;
    } catch (err) {
      this.error = err.message || 'Failed to load Pokémon';
    } finally {
      this.isLoading = false;
    }
  }

  @action
  async nextPage() {
    if (this.isLoading || this.offset + PAGE_SIZE >= API_POKEMON_LIMIT) {
      return;
    }
    await this.loadPage(this.offset + PAGE_SIZE);
  }

  @action
  async previousPage() {
    if (this.isLoading || this.offset <= 0) {
      return;
    }
    await this.loadPage(this.offset - PAGE_SIZE);
  }

  @action
  retry() {
    if (this.isSearchActive) {
      this.runSearch(this.searchTerm);
    } else {
      this.loadPage(this.offset);
    }
  }

  get isPreviousDisabled() {
    return this.isLoading || this.offset <= 0;
  }

  get isNextDisabled() {
    return this.isLoading || this.offset + PAGE_SIZE >= API_POKEMON_LIMIT;
  }

  get isBusy() {
    return this.isLoading || this.isSearching;
  }

  get loadingMessage() {
    return this.isSearching ? 'Searching...' : 'Loading Pokemons...';
  }

  <template>
    <FeaturedRotator />

    <div class="list-controls">
      <input
        type="search"
        placeholder="Search by name (min. 3 letters)"
        value={{this.searchTerm}}
        class="search-input"
        {{on "input" this.updateSearch}}
      />
      <select class="sort-select" {{on "change" this.updateSort}}>
        <option value="id">Sort by ID</option>
        <option value="name">Sort by name</option>
      </select>
    </div>

    {{#if this.isBusy}}
      <div class="list-loading">{{this.loadingMessage}}</div>
    {{else if this.error}}
      <div class="error-state" role="alert">
        <p>{{this.error}}</p>
        <button type="button" class="page-button" {{on "click" this.retry}}>
          Try again
        </button>
      </div>
    {{else if this.showEmptySearch}}
      <p class="empty-state">No Pokemon found for "{{this.searchTerm}}".</p>
    {{else}}
      <div class="pokemon-grid">
        {{#each this.displayedPokemon as |pokemon|}}
          <PokemonCard @pokemon={{pokemon}} />
        {{/each}}
      </div>
    {{/if}}

    {{#unless this.isSearchActive}}
      <div class="pagination">
        <button
          type="button"
          class="page-button"
          disabled={{this.isPreviousDisabled}}
          {{on "click" this.previousPage}}
        >
          Previous
        </button>
        <button
          type="button"
          class="page-button"
          disabled={{this.isNextDisabled}}
          {{on "click" this.nextPage}}
        >
          Next
        </button>
      </div>
    {{/unless}}
  </template>
}

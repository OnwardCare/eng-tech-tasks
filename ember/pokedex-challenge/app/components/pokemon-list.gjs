import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { buildWaiter } from '@ember/test-waiters';
import AsyncData from 'pokedex-challenge/utils/async-data';
import { GEN_1_COUNT } from 'pokedex-challenge/services/poke-data';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

export const PAGE_SIZE = 20;
const SEARCH_DEBOUNCE = 200;

// Keeps `settled()` — and therefore the tests — aware of a pending search.
const searchWaiter = buildWaiter('pokemon-list:search');

const BY_ID = (a, b) => a.id - b.id;
const BY_NAME = (a, b) => a.name.localeCompare(b.name);

export default class PokemonList extends Component {
  @service pokeData;

  @tracked searchTerm = '';
  @tracked query = '';
  @tracked sortBy = 'id';
  @tracked offset = 0;

  #views = new Map();
  #debounce;
  #waiterToken;

  willDestroy() {
    this.cancelPendingSearch();
    super.willDestroy(...arguments);
  }

  get isInitialView() {
    return !this.query && this.sortBy === 'id' && this.offset === 0;
  }

  get viewKey() {
    return `${this.sortBy}|${this.query}|${this.offset}`;
  }

  get view() {
    return this.#views.get(this.viewKey) ?? null;
  }

  get isLoading() {
    return Boolean(this.view?.isLoading);
  }

  get error() {
    return this.view?.error ?? null;
  }

  get pokemon() {
    if (this.isInitialView) {
      return [...(this.args.pokemon ?? [])].sort(BY_ID);
    }

    return this.view?.value?.cards ?? [];
  }

  get total() {
    if (this.isInitialView) {
      return GEN_1_COUNT;
    }

    return this.view?.value?.total ?? 0;
  }

  get isEmpty() {
    return !this.isLoading && !this.error && this.pokemon.length === 0;
  }

  get currentPageNumber() {
    return this.offset / PAGE_SIZE + 1;
  }

  get pageCount() {
    return Math.max(1, Math.ceil(this.total / PAGE_SIZE));
  }

  get hasPrevious() {
    return this.offset > 0;
  }

  get hasNext() {
    return this.offset + PAGE_SIZE < this.total;
  }

  get isFirstPage() {
    return !this.hasPrevious;
  }

  get isLastPage() {
    return !this.hasNext;
  }

  get isPaginated() {
    return this.pageCount > 1;
  }

  @action
  updateSearch(event) {
    this.searchTerm = event.target.value;
    this.cancelPendingSearch();
    this.#waiterToken = searchWaiter.beginAsync();
    this.#debounce = setTimeout(() => {
      this.releaseWaiter();
      this.applySearch();
    }, SEARCH_DEBOUNCE);
  }

  cancelPendingSearch() {
    clearTimeout(this.#debounce);
    this.#debounce = undefined;
    this.releaseWaiter();
  }

  releaseWaiter() {
    if (this.#waiterToken) {
      searchWaiter.endAsync(this.#waiterToken);
      this.#waiterToken = undefined;
    }
  }

  applySearch() {
    const query = this.searchTerm.trim().toLowerCase();

    if (query === this.query) {
      return;
    }

    this.query = query;
    this.goToOffset(0);
  }

  @action
  updateSort(event) {
    this.sortBy = event.target.value;
    this.goToOffset(0);
  }

  @action
  previousPage() {
    if (this.hasPrevious) {
      this.goToOffset(this.offset - PAGE_SIZE);
    }
  }

  @action
  nextPage() {
    if (this.hasNext) {
      this.goToOffset(this.offset + PAGE_SIZE);
    }
  }

  goToOffset(offset) {
    this.offset = offset;

    const key = this.viewKey;

    if (!this.isInitialView && !this.#views.has(key)) {
      const { query, sortBy } = this;

      this.#views.set(
        key,
        new AsyncData(() => this.loadView({ query, sortBy, offset })),
      );
    }
  }

  async loadView({ query, sortBy, offset }) {
    const index = await this.pokeData.fetchIndex();
    const matches = query
      ? index.filter((entry) => entry.name.includes(query))
      : index;
    const ordered = [...matches].sort(sortBy === 'name' ? BY_NAME : BY_ID);
    const visible = ordered.slice(offset, offset + PAGE_SIZE);

    return {
      total: ordered.length,
      cards: await this.pokeData.fetchCards(visible.map((entry) => entry.id)),
    };
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
        aria-label="Sort order"
        {{on "change" this.updateSort}}
      >
        <option value="id">Sort by ID</option>
        <option value="name">Sort by name</option>
      </select>
    </div>

    {{#if this.isLoading}}
      <p class="list-status">Loading…</p>
    {{else if this.error}}
      <p class="list-status list-error">Could not load these Pokémon.</p>
    {{else if this.isEmpty}}
      <p class="empty-state">No Pokémon match "{{this.query}}".</p>
    {{else}}
      <div class="pokemon-grid">
        {{#each this.pokemon key="id" as |pokemon|}}
          <PokemonCard @pokemon={{pokemon}} />
        {{/each}}
      </div>
    {{/if}}

    {{#if this.isPaginated}}
      <div class="pagination">
        <button
          type="button"
          class="page-button"
          disabled={{this.isFirstPage}}
          {{on "click" this.previousPage}}
        >
          Previous
        </button>
        <span class="page-indicator">
          Page
          {{this.currentPageNumber}}
          of
          {{this.pageCount}}
        </span>
        <button
          type="button"
          class="page-button"
          disabled={{this.isLastPage}}
          {{on "click" this.nextPage}}
        >
          Next
        </button>
      </div>
    {{/if}}
  </template>
}

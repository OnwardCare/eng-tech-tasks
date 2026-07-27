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

  // Holds all 151 Pokémon once loaded for full-set searching
  @tracked allPokemon = null;
  @tracked isLoadingAll = false;

  get pokemon() {
    return this.currentPage || this.args.pokemon;
  }

  get filteredPokemon() {
    // When searching, operate over the full Gen-1 set (or the loaded pages so far
    // while the full set is still loading)
    const source = this.searchTerm
      ? (this.allPokemon ?? this.pokemon)
      : this.pokemon;

    const filtered = this.searchTerm
      ? source.filter((p) =>
          p.name.toLowerCase().includes(this.searchTerm.toLowerCase()),
        )
      : source;

    if (this.sortBy === 'name') {
      // Sort on a copy to avoid mutating the cached page array
      return [...filtered].sort((a, b) => a.name.localeCompare(b.name));
    }
    return [...filtered].sort((a, b) => a.id - b.id);
  }

  // Fetch all 151 Gen-1 Pokémon in parallel once and cache the result.
  // Subsequent searches reuse this.allPokemon without hitting the network.
  async _loadAll() {
    this.isLoadingAll = true;
    try {
      const list = await this.pokeData.fetchList(0, GEN_1_COUNT);
      this.allPokemon = await Promise.all(
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
    } finally {
      this.isLoadingAll = false;
    }
  }

  @action
  async updateSearch(event) {
    this.searchTerm = event.target.value;
    // Trigger a full load the first time the user types — cache makes this cheap
    // after the first load or if the user has already browsed pages
    if (this.searchTerm && !this.allPokemon && !this.isLoadingAll) {
      await this._loadAll();
    }
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
        placeholder="Search all 151 Pokémon…"
        value={{this.searchTerm}}
        class="search-input"
        {{on "input" this.updateSearch}}
      />
      <select class="sort-select" {{on "change" this.updateSort}}>
        <option value="id">Sort by ID</option>
        <option value="name">Sort by name</option>
      </select>
    </div>

    {{#if this.isLoadingAll}}
      <p class="search-loading">Loading all Pokémon…</p>
    {{/if}}

    <div class="pokemon-grid">
      {{#each this.filteredPokemon as |pokemon|}}
        <PokemonCard @pokemon={{pokemon}} />
      {{/each}}
    </div>

    {{! Hide pagination while searching — results span the full set }}
    {{#unless this.searchTerm}}
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
    {{/unless}}
  </template>
}

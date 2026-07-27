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

  // Offset for the normal paginated browse
  @tracked offset = 0;
  @tracked currentPage = null;

  // Separate offset for search results so the two modes don't share state
  @tracked searchOffset = 0;

  // Holds all 151 Pokémon once loaded for full-set searching
  @tracked allPokemon = null;
  @tracked isLoadingAll = false;

  get pokemon() {
    return this.currentPage || this.args.pokemon;
  }

  // Returns the single page from the API or the full 151 list if it's been loaded
  get _activeSource() {
    return this.allPokemon ?? this.pokemon;
  }

  get _isLocalMode() {
    return this.allPokemon !== null;
  }

  // Full sorted+filtered list, without pagination slice applied yet
  get _sortedFiltered() {
    const source = this._activeSource;

    const filtered = this.searchTerm
      ? source.filter((p) =>
          p.name.toLowerCase().includes(this.searchTerm.toLowerCase()),
        )
      : source;

    if (this.sortBy === 'name') {
      // Sort on a copy to avoid mutating the cached array
      return [...filtered].sort((a, b) => a.name.localeCompare(b.name));
    }
    return [...filtered].sort((a, b) => a.id - b.id);
  }

  // Slice _sortedFiltered to PAGE_SIZE only if we are operating on the full local set
  get filteredPokemon() {
    const all = this._sortedFiltered;
    
    if (this._isLocalMode) {
      const start = this.searchTerm ? this.searchOffset : this.offset;
      return all.slice(start, start + PAGE_SIZE);
    }
    
    // In API mode, 'all' is already just the 20 items for the current page
    return all;
  }

  get _activeOffset() {
    return this.searchTerm ? this.searchOffset : this.offset;
  }

  get isNextDisabled() {
    if (this._isLocalMode) {
      return this._activeOffset + PAGE_SIZE >= this._sortedFiltered.length;
    }
    return this.offset + PAGE_SIZE >= GEN_1_COUNT;
  }

  get isPreviousDisabled() {
    return this._activeOffset === 0;
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
    // Reset search pagination on every keystroke so results always start at page 1
    this.searchOffset = 0;
    // Trigger a full load the first time the user types — cache makes this cheap
    // after the first load or if the user has already browsed pages
    if (this.searchTerm && !this.allPokemon && !this.isLoadingAll) {
      await this._loadAll();
    }
  }

  @action
  async updateSort(event) {
    this.sortBy = event.target.value;
    // We need the full list to perform a true global sort.
    if (!this._isLocalMode && !this.isLoadingAll) {
      await this._loadAll();
    }
    // Reset both offsets so sorted results always start at page 1
    this.searchOffset = 0;
    this.offset = 0;
    this.currentPage = null;
  }

  // Shared helper to fetch a remote page by offset; uses the service for caching
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
    if (this.isNextDisabled) return;

    if (this.searchTerm) {
      // For search results, just advance the slice
      this.searchOffset = this.searchOffset + PAGE_SIZE;
    } else {
      this.offset = this.offset + PAGE_SIZE;
      // Only hit the API if we aren't holding the full list in memory
      if (!this._isLocalMode) {
        this.currentPage = await this._loadPage(this.offset);
      }
    }
  }

  @action
  async previousPage() {
    if (this.isPreviousDisabled) return;

    if (this.searchTerm) {
      this.searchOffset = Math.max(0, this.searchOffset - PAGE_SIZE);
    } else {
      this.offset = Math.max(0, this.offset - PAGE_SIZE);
      if (!this._isLocalMode) {
        // First page was loaded by the route; restore it from args to avoid a redundant request
        if (this.offset === 0) {
          this.currentPage = null;
        } else {
          this.currentPage = await this._loadPage(this.offset);
        }
      }
    }
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

    {{! Pagination works in both browse and search modes, auto-disables at boundaries }}
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
  </template>
}

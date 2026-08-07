import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import FeaturedRotator from 'pokedex-challenge/components/featured-rotator';
import PokemonCard from 'pokedex-challenge/components/pokemon-card';

export default class PokemonList extends Component {
  @service router;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';

  get filteredPokemon() {
    let results = this.args.pokemon;
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
    if (!this.args.hasNext) {
      return;
    }
    this.router.transitionTo({ queryParams: { page: this.args.page + 1 } });
  }

  @action
  previousPage() {
    if (!this.args.hasPrevious) {
      return;
    }
    this.router.transitionTo({ queryParams: { page: this.args.page - 1 } });
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
        disabled={{unless @hasPrevious "disabled"}}
        {{on "click" this.previousPage}}
      >
        Previous
      </button>
      <button
        type="button"
        class="page-button"
        disabled={{unless @hasNext "disabled"}}
        {{on "click" this.nextPage}}
      >
        Next
      </button>
    </div>
  </template>
}

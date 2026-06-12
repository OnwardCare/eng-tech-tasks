/* eslint-disable no-console */
import Controller from '@ember/controller';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';

const GEN_1_COUNT = 151;

export default class IndexController extends Controller {
  @service pokeData;

  @tracked searchTerm = '';
  @tracked sortBy = 'id';
  @tracked offset = 0;
  @tracked currentPage = null;

  get pokemon() {
    return this.currentPage || this.model;
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

  @action
  updateSearch(event) {
    this.searchTerm = event.target.value;
  }

  @action
  updateSort(event) {
    this.sortBy = event.target.value;
  }

  @action
  async nextPage() {
    if (this.offset + 20 >= GEN_1_COUNT) {
      return;
    }
    this.offset = this.offset + 20;
    const limit = Math.min(20, GEN_1_COUNT - this.offset);
    const list = await this.pokeData.fetchList(this.offset, limit);
    const page = [];
    for (const entry of list.results) {
      const response = await fetch(entry.url);
      const detail = await response.json();
      page.push({
        id: detail.id,
        name: detail.name,
        sprite: detail.sprites.front_default,
        types: detail.types.map((t) => t.type.name),
      });
    }
    this.currentPage = page;
  }

  @action
  previousPage() {
    console.log('previousPage');
  }
}

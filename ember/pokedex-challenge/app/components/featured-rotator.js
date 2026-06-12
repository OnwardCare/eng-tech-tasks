import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { later } from '@ember/runloop';

export default class FeaturedRotatorComponent extends Component {
  @tracked featured = null;

  constructor() {
    super(...arguments);
    this.loadFeatured();
    setInterval(() => {
      this.loadFeatured();
    }, 8000);
  }

  async loadFeatured() {
    const id = Math.floor(Math.random() * 151) + 1;
    const response = await fetch(`https://pokeapi.co/api/v2/pokemon/${id}`);
    const data = await response.json();
    this.featured = {
      id: data.id,
      name: data.name,
      sprite: data.sprites.other['official-artwork'].front_default,
    };
  }
}

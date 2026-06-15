import Component from '@glimmer/component';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';

export default class NavBar extends Component {
  @service favorites;

  <template>
    <nav class="main-nav">
      <LinkTo @route="index" class="nav-brand">Pokédex</LinkTo>
      <LinkTo @route="favorites" class="nav-favorites">
        Favorites ({{this.favorites.count}})
      </LinkTo>
    </nav>
  </template>
}

import EmberRouter from '@embroider/router';
import config from 'pokedex-challenge/config/environment';

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  this.route('pokemon', { path: '/pokemon/:pokemon_id' });
  this.route('favorites');
});

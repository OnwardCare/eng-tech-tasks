import Controller from '@ember/controller';
import { service } from '@ember/service';

// Expose the favorites service to the template so the list stays reactive
// when favorites are toggled anywhere in the app
export default class FavoritesController extends Controller {
  @service favorites;
}

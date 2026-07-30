import Controller from '@ember/controller';
import { service } from '@ember/service';

export default class FavoritesController extends Controller {
  @service favorites;
}

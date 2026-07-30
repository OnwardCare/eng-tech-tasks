import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class ListStateService extends Service {
  @tracked offset = 0;
}

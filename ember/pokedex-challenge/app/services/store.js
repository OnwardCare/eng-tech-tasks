import { useLegacyStore } from '@warp-drive/legacy';
import { JSONAPICache } from '@warp-drive/json-api';
import PokemonSchema from '../data/pokemon';
// import LocalStorageHandler from './local-storage-handler';

const Store = useLegacyStore({
  linksMode: false,
  cache: JSONAPICache,
  handlers: [
    // TODO: Investigate why this handlers is not working as expected.
    // LocalStorageHandler
  ],
  schemas: [
    PokemonSchema
  ],
  legacyRequests: true,
});

export default Store;

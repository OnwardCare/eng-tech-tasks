import JSONAPIAdapter from '@ember-data/adapter/json-api';

// Data currently comes straight from PokéAPI via fetch (see services/poke-data).
export default class ApplicationAdapter extends JSONAPIAdapter {}

import Service from "@ember/service";
import { pathsFromChain } from "pokedex-challenge/utils/evolution-chain";

const BASE_URL = "https://pokeapi.co/api/v2";

export default class PokeDataService extends Service {
	#requests = new Map();

	request(url) {
		let request = this.#requests.get(url);

		if (!request) {
			request = this.#getJson(url).catch((error) => {
				this.#requests.delete(url);
				throw error;
			});
			this.#requests.set(url, request);
		}

		return request;
	}

	async #getJson(url) {
		const response = await fetch(url);
		if (!response.ok) {
			throw new Error(`Request to ${url} failed with ${response.status}`);
		}

		return response.json();
	}

	fetchList(offset = 0, limit = 20) {
		return this.request(`${BASE_URL}/pokemon?limit=${limit}&offset=${offset}`);
	}

	fetchPokemon(idOrName) {
		return this.request(`${BASE_URL}/pokemon/${idOrName}`);
	}

	async fetchPage(offset = 0, limit = 20) {
		const list = await this.fetchList(offset, limit);

		return Promise.all(
			list.results.map(async (entry) => {
				const detail = await this.request(entry.url);

				return {
					id: detail.id,
					name: detail.name,
					sprite: detail.sprites.front_default,
					types: detail.types.map((t) => t.type.name),
				};
			}),
		);
	}

	fetchSpecies(idOrName) {
		return this.request(`${BASE_URL}/pokemon-species/${idOrName}`);
	}

	async fetchEvolutionPaths(idOrName) {
		const species = await this.fetchSpecies(idOrName);
		const chainUrl = species.evolution_chain?.url;

		if (!chainUrl) {
			return [];
		}

		const { chain } = await this.request(chainUrl);

		return Promise.all(
			pathsFromChain(chain).map((path) =>
				Promise.all(path.map((entry) => this.#withSprite(entry))),
			),
		);
	}

	async #withSprite(entry) {
		try {
			const pokemon = await this.fetchPokemon(entry.id);
			return {
				id: pokemon.id,
				name: pokemon.name,
				sprite: pokemon.sprites.front_default,
			};
		} catch {
			return { ...entry, sprite: null };
		}
	}
}

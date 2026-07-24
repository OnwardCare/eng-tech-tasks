import { idFromUrl } from "pokedex-challenge/utils/poke-api";

export function pathsFromChain(chain) {
	if (!chain) {
		return [];
	}

	const stage = {
		name: chain.species?.name,
		id: idFromUrl(chain.species?.url),
	};
	const branches = chain.evolves_to ?? [];

	if (branches.length === 0) {
		return [[stage]];
	}

	return branches.flatMap((branch) =>
		pathsFromChain(branch).map((path) => [stage, ...path]),
	);
}

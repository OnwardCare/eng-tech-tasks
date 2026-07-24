const ID_PATTERN = /\/(\d+)\/?$/;

export function idFromUrl(url) {
	const match = ID_PATTERN.exec(url ?? "");
	return match ? Number(match[1]) : null;
}

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

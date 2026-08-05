export function idFromSpeciesUrl(url) {
  return Number(url.split('/').filter(Boolean).pop());
}

export function flattenEvolutionChain(chain) {
  const levels = [];
  let currentLevel = [chain];

  while (currentLevel.length > 0) {
    levels.push(
      currentLevel.map((node) => ({
        id: idFromSpeciesUrl(node.species.url),
        name: node.species.name,
      })),
    );
    currentLevel = currentLevel.flatMap((node) => node.evolves_to);
  }

  return levels;
}

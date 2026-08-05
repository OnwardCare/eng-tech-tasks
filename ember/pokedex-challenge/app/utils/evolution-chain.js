import { idFromUrl } from 'pokedex-challenge/utils/pokeapi';

export function flattenEvolutionChain(chain) {
  const levels = [];
  let currentLevel = [chain];

  while (currentLevel.length > 0) {
    levels.push(
      currentLevel.map((node) => ({
        id: idFromUrl(node.species.url),
        name: node.species.name,
      })),
    );
    currentLevel = currentLevel.flatMap((node) => node.evolves_to);
  }

  return levels;
}

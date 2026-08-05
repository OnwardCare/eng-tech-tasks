export const GEN_1_COUNT = 151;

export function idFromUrl(url) {
  return Number(url.split('/').filter(Boolean).pop());
}

export function toPokemonSummary(detail) {
  return {
    id: detail.id,
    name: detail.name,
    sprite: detail.sprites.front_default,
    types: detail.types.map((t) => t.type.name),
  };
}

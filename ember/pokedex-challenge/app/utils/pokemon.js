// Shared shape used by list/grid cards (index route, pagination, favorites).
export function toCardShape(detail) {
  return {
    id: detail.id,
    name: detail.name,
    sprite: detail.sprites.front_default,
    types: detail.types.map((t) => t.type.name),
  };
}

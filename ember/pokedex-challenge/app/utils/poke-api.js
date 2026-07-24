const ID_PATTERN = /\/(\d+)\/?$/;

export function idFromUrl(url) {
  const match = ID_PATTERN.exec(url ?? '');
  return match ? Number(match[1]) : null;
}

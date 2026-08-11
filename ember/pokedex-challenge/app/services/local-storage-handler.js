import { STORAGE_KEY } from "./local-storage";

// Attempt for a handler for the store to take care of the first load
// items initialization, those can come from localStorage
export default {
  async request(context, next) {
    // TODO: Investigate how to inject the LocalStorageService here (if possible)
    const itemsFromLocalStorage = localStorage.getItem(STORAGE_KEY);

    if (!itemsFromLocalStorage) {
      return next(context.request);
    }

    const items = JSON.parse(itemsFromLocalStorage);

    return {
        content: {
            data: items.map((item) => ({
            type: 'pokemon',
            id: String(item.id),
            attributes: {
                name: item.name,
                sprite: item.sprite,
                types: item.types,
            },
            })),
        },

        request: context.request,
    };
  },
};
import { waitForPromise } from "@ember/test-waiters";
import { tracked } from "@glimmer/tracking";

export default class AsyncData {
	@tracked value = null;
	@tracked error = null;
	@tracked isLoading = true;

	constructor(load) {
		waitForPromise(this.#load(load));
	}

	async #load(load) {
		try {
			this.value = await load();
		} catch (error) {
			this.error = error;
		} finally {
			this.isLoading = false;
		}
	}
}

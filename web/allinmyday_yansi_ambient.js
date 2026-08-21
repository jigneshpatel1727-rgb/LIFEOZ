import { AllinmydayYansiBridge } from './allinmyday_yansi_bridge.js';

/**
 * UI-light ambient presentation adapter for Yansi.
 * The adapter exposes state changes without creating a chatbot UI.
 */
export class AllinmydayYansiAmbient {
  constructor({ bridge = null, onAmbientChange = null } = {}) {
    this.onAmbientChange = onAmbientChange;
    this.bridge = bridge ?? new AllinmydayYansiBridge({
      onStatus: (event) => this.#publish(event.status, event.message),
    });
    this.current = Object.freeze({ status: 'idle', message: '' });
  }

  request(capability, input = '', metadata = {}) {
    return this.bridge.request(capability, input, metadata);
  }

  confirmation(requestId) {
    return this.bridge.confirm(requestId);
  }

  complete(message = 'Done.') {
    this.bridge.complete(message);
  }

  fail(message = 'I could not complete that.') {
    this.bridge.fail(message);
  }

  reset() {
    this.bridge.reset();
  }

  #publish(status, message = '') {
    this.current = Object.freeze({ status, message });
    this.onAmbientChange?.(this.current);
  }
}

import { AllinmydayYansiBridge } from './allinmyday_yansi_bridge.js';

const CORE_IDS = Object.freeze([
  'finance',
  'goals',
  'productivity',
  'household',
  'calendar',
]);

/** Central state contract for the production ALLINMYDAY web experience. */
export class AllinmydaySiteState {
  constructor({ yansi = null } = {}) {
    this.selectedCore = null;
    this.yansiStatus = 'idle';
    this.yansiMessage = '';
    this.listeners = new Set();
    this.yansi = yansi ?? new AllinmydayYansiBridge({
      onStatus: ({ status, message }) => {
        this.yansiStatus = status;
        this.yansiMessage = message;
        this.emit();
      },
    });
  }

  selectCore(coreId) {
    const id = String(coreId).trim().toLowerCase();
    if (!CORE_IDS.includes(id)) return false;
    this.selectedCore = id;
    this.emit();
    return true;
  }

  clearCore() {
    this.selectedCore = null;
    this.emit();
  }

  requestYansi(capability, input = '', metadata = {}) {
    return this.yansi.request(capability, input, metadata);
  }

  subscribe(listener) {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  snapshot() {
    return Object.freeze({
      selectedCore: this.selectedCore,
      yansiStatus: this.yansiStatus,
      yansiMessage: this.yansiMessage,
    });
  }

  emit() {
    const snapshot = this.snapshot();
    this.listeners.forEach((listener) => listener(snapshot));
  }
}

export { CORE_IDS };

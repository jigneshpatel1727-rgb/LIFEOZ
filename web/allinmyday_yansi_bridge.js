import { ALLINMYDAY_RUNTIME_POLICY, assertAllinmydayRuntimePolicy } from './allinmyday_runtime_policy.js';

/**
 * Small browser-side contract between the ALLINMYDAY website and Iamyansi.
 * It deliberately contains no model/provider code and performs no action by
 * itself. The host application decides how approved requests are handled.
 */
export class AllinmydayYansiBridge {
  constructor({ onRequest = null, onStatus = null } = {}) {
    assertAllinmydayRuntimePolicy();
    this.onRequest = onRequest;
    this.onStatus = onStatus;
    this.status = 'idle';
  }

  setStatus(status, message = '') {
    this.status = status;
    this.onStatus?.({ status, message });
  }

  request(capability, input = '', metadata = {}) {
    const request = Object.freeze({
      requestId: `web-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
      capability: String(capability).trim().toLowerCase(),
      input: String(input),
      metadata: { ...metadata },
      brand: ALLINMYDAY_RUNTIME_POLICY.brand,
    });
    this.setStatus('understanding');
    return this.onRequest?.(request) ?? request;
  }

  confirm(requestId) {
    this.setStatus('executing');
    return Object.freeze({ requestId, confirmed: true });
  }

  complete(message = 'Done.') {
    this.setStatus('completed', message);
  }

  fail(message = 'I could not complete that.') {
    this.setStatus('failed', message);
  }

  reset() {
    this.setStatus('idle');
  }
}

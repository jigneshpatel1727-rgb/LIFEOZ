/*
 * ALLINMYDAY web runtime policy.
 *
 * The production website must not silently depend on remote visual assets,
 * copied templates, remote fonts, remote icons, or external design systems.
 * Runtime code can use browser platform APIs; any future third-party service
 * integration must be explicitly reviewed and isolated from the visual layer.
 */
export const ALLINMYDAY_RUNTIME_POLICY = Object.freeze({
  brand: 'ALLINMYDAY',
  originalDesignOnly: true,
  remoteVisualAssetsAllowed: false,
  remoteFontsAllowed: false,
  remoteIconAssetsAllowed: false,
  copiedTemplatesAllowed: false,
  motto: 'One screen. One tap. One report.',
  principle: 'Less information on screen + more intelligence behind the screen.',
});

export function assertAllinmydayRuntimePolicy(policy = ALLINMYDAY_RUNTIME_POLICY) {
  const forbidden = [
    'remoteVisualAssetsAllowed',
    'remoteFontsAllowed',
    'remoteIconAssetsAllowed',
    'copiedTemplatesAllowed',
  ];
  const invalid = forbidden.filter((key) => policy[key] === true);
  if (invalid.length) {
    throw new Error(`ALLINMYDAY runtime policy violation: ${invalid.join(', ')}`);
  }
  if (policy.originalDesignOnly !== true) {
    throw new Error('ALLINMYDAY requires original design only.');
  }
  return true;
}

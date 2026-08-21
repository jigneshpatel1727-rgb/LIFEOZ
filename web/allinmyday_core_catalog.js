/**
 * Product-facing metadata for the five LifeOS cores.
 * No external icons, copied labels, or visual assets are referenced here.
 */
export const ALLINMYDAY_CORE_CATALOG = Object.freeze([
  Object.freeze({ id: 'finance', role: 'Money awareness', accent: 'gold' }),
  Object.freeze({ id: 'goals', role: 'Long-term direction', accent: 'violet' }),
  Object.freeze({ id: 'productivity', role: 'Daily execution', accent: 'cyan' }),
  Object.freeze({ id: 'household', role: 'Home essentials', accent: 'green' }),
  Object.freeze({ id: 'calendar', role: 'Time and commitments', accent: 'blue' }),
]);

export function getAllinmydayCore(coreId) {
  const id = String(coreId).trim().toLowerCase();
  return ALLINMYDAY_CORE_CATALOG.find((core) => core.id === id) ?? null;
}

/* Allinmyday Studio: explicit workspace state + undo/redo foundation. */
(() => {
  const engine = window.AllInMyDayStudioEngine;
  if (!engine) return;
  const history = [];
  const future = [];
  let applying = false;

  const snapshot = () => engine.export();
  const restore = (json) => {
    try {
      const data = JSON.parse(json);
      if (!Array.isArray(data.objects) || !data.objects.length) return false;
      engine.state.objects = data.objects;
      engine.state.selected = data.selected || data.objects[0].id;
      engine.state.material = data.material || engine.state.material;
      engine.state.lighting = data.lighting || engine.state.lighting;
      engine.state.objects.forEach((o) => { o.selected = o.id === engine.state.selected; });
      window.dispatchEvent(new CustomEvent('studio-scene-change', { detail: engine.state }));
      return true;
    } catch (_) { return false; }
  };

  const record = () => {
    if (applying) return;
    const current = snapshot();
    if (history.at(-1) !== current) {
      history.push(current);
      if (history.length > 40) history.shift();
      future.length = 0;
    }
  };

  window.AllInMyDayStudioHistory = {
    record,
    undo() {
      if (history.length < 2) return false;
      const current = history.pop();
      future.push(current);
      applying = true;
      const ok = restore(history.at(-1));
      applying = false;
      return ok;
    },
    redo() {
      const next = future.pop();
      if (!next) return false;
      history.push(next);
      applying = true;
      const ok = restore(next);
      applying = false;
      return ok;
    },
    canUndo: () => history.length > 1,
    canRedo: () => future.length > 0,
  };

  record();
  window.addEventListener('studio-scene-change', () => record());
  document.addEventListener('keydown', (event) => {
    if (event.target.matches('input,select,textarea')) return;
    if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'z') {
      event.preventDefault();
      setTimeout(() => window.AllInMyDayStudioHistory.undo(), 0);
    }
    if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'y') {
      event.preventDefault();
      setTimeout(() => window.AllInMyDayStudioHistory.redo(), 0);
    }
  });
})();

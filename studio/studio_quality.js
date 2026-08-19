/* Allinmyday Studio quality + workflow layer. */
(() => {
  const engine = window.AllInMyDayStudioEngine;
  if (!engine) return;

  const status = document.querySelector('#status');
  const setStatus = (value) => { if (status) status.textContent = value; };

  // Camera quality controls.
  const quality = document.createElement('div');
  quality.className = 'studio-quality';
  quality.innerHTML = '<button data-quality="draft">DRAFT</button><button data-quality="balanced" class="active">BALANCED</button><button data-quality="detail">DETAIL</button>';
  document.querySelector('.viewport-controls')?.appendChild(quality);

  quality.addEventListener('click', (event) => {
    const button = event.target.closest('[data-quality]');
    if (!button) return;
    const value = button.dataset.quality;
    document.querySelectorAll('[data-quality]').forEach((b) => b.classList.toggle('active', b === button));
    const distance = value === 'draft' ? 7 : value === 'detail' ? 5 : 6;
    engine.state.camera.distance = distance;
    setStatus('VIEW QUALITY · ' + value.toUpperCase());
  });

  // Keyboard shortcuts for a faster professional workflow.
  document.addEventListener('keydown', (event) => {
    if (event.target.matches('input,select,textarea')) return;
    const key = event.key.toLowerCase();
    if (key === 'o') {
      engine.state.camera.yaw += Math.PI / 8;
      setStatus('CAMERA · ORBIT STEP');
    }
    if (key === 'r') {
      engine.state.camera.yaw = .45;
      engine.state.camera.pitch = .15;
      engine.state.camera.distance = 6;
      setStatus('CAMERA · RESET');
    }
    if (key === 'f') {
      const selected = engine.state.objects.find((o) => o.id === engine.state.selected);
      if (selected) {
        engine.state.camera.distance = Math.max(3, Math.min(8, 4.8 + Math.abs(selected.sx || 1)));
        setStatus('CAMERA · FOCUS SELECTED');
      }
    }
  });
})();

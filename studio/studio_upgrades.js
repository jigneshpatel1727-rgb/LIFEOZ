/* AllInMyDay Studio — realtime workflow upgrades. */
(() => {
  const engine = window.AllInMyDayStudioEngine;
  if (!engine) return;

  const orbitButton = document.querySelector('#orbit');
  const fps = document.querySelector('#fps');
  let autoOrbit = false;
  let last = performance.now();
  let frames = 0;
  let lastFps = last;

  orbitButton?.addEventListener('click', () => {
    autoOrbit = !autoOrbit;
    orbitButton.textContent = autoOrbit ? 'STOP ORBIT' : '360° ORBIT';
    document.querySelector('#status').textContent = autoOrbit
      ? '360° ORBIT · AUTO PREVIEW ACTIVE'
      : '360° ORBIT · MANUAL VIEW';
  });

  const tick = (now) => {
    const dt = Math.min(.05, (now - last) / 1000);
    last = now;
    frames++;
    if (now - lastFps >= 500) {
      const value = Math.round(frames * 1000 / (now - lastFps));
      if (fps) fps.textContent = `REALTIME · ${value} FPS`;
      frames = 0;
      lastFps = now;
    }
    if (autoOrbit) engine.rotate(dt * .55, 0);
    requestAnimationFrame(tick);
  };
  requestAnimationFrame(tick);

  document.addEventListener('keydown', (event) => {
    if (event.target.matches('input,select,textarea')) return;
    if (event.key.toLowerCase() === 'o') {
      autoOrbit = !autoOrbit;
      if (orbitButton) orbitButton.textContent = autoOrbit ? 'STOP ORBIT' : '360° ORBIT';
    }
    if (event.key.toLowerCase() === 'r') {
      engine.state.camera.yaw = .45;
      engine.state.camera.pitch = .15;
      engine.state.camera.distance = 6;
    }
  });

  window.AllInMyDayStudioWorkflow = {
    get autoOrbit() { return autoOrbit; },
    setAutoOrbit(value) { autoOrbit = Boolean(value); },
    resetCamera() {
      engine.state.camera.yaw = .45;
      engine.state.camera.pitch = .15;
      engine.state.camera.distance = 6;
    },
  };
})();

/* AllInMyDay Studio — interaction completion layer. */
(()=>{
  const engine=window.AllInMyDayStudioEngine;
  if(!engine)return;
  const orbit=document.querySelector('#orbit');
  const reset=document.querySelector('#reset');
  const stage=document.querySelector('.stage');
  const status=document.querySelector('#status');
  let autoOrbit=false;
  const say=t=>{if(status)status.textContent=t};

  orbit?.addEventListener('click',()=>{
    autoOrbit=!autoOrbit;
    orbit.classList.toggle('active',autoOrbit);
    say(autoOrbit?'360° ORBIT · AUTO ROTATION':'360° ORBIT · DRAG VIEWPORT');
  });

  reset?.addEventListener('click',()=>{
    engine.state.camera.yaw=.45;
    engine.state.camera.pitch=.15;
    engine.state.camera.distance=6;
    say('VIEW RESET · 3D CAMERA HOME');
  });

  stage?.addEventListener('dblclick',()=>{
    engine.state.camera.yaw=.45;
    engine.state.camera.pitch=.15;
    engine.state.camera.distance=6;
    say('VIEW RESET · DOUBLE CLICK');
  });

  let last=performance.now();
  const frame=t=>{
    const dt=Math.min(.05,(t-last)/1000);last=t;
    if(autoOrbit)engine.state.camera.yaw+=dt*.55;
    requestAnimationFrame(frame);
  };
  requestAnimationFrame(frame);

  document.addEventListener('keydown',e=>{
    if(e.target.matches('input,select,textarea'))return;
    if(e.key.toLowerCase()==='r'){
      engine.state.camera.yaw=.45;engine.state.camera.pitch=.15;engine.state.camera.distance=6;
      say('VIEW RESET · CAMERA HOME');
    }
    if(e.key.toLowerCase()==='o')orbit?.click();
  });
})();

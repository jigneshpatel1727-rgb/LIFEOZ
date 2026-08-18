/* AllInMyDay Studio — lightweight realtime measurement overlay. */
(()=>{
 const engine=window.AllInMyDayStudioEngine;if(!engine)return;
 const stage=document.querySelector('.stage'),line=document.querySelector('#measure-line'),status=document.querySelector('#status'),btn=document.querySelector('#measureBtn');
 if(!stage||!line)return;
 let active=false;
 const render=()=>{const o=engine.state.objects.find(x=>x.id===engine.state.selected);if(!active||!o){line.style.display='none';return;}const w=Math.max(.01,Math.abs(o.sx)*2),h=Math.max(.01,Math.abs(o.sy)*2),d=Math.max(.01,Math.abs(o.sz)*2);line.style.display='block';line.innerHTML=`<span>W ${w.toFixed(2)} · H ${h.toFixed(2)} · D ${d.toFixed(2)} units</span>`;};
 btn?.addEventListener('click',()=>{active=!active;stage.classList.toggle('measure-active',active);if(status)status.textContent=active?'MEASURE · SELECTED OBJECT DIMENSIONS':'MEASURE · OFF';render();});
 window.addEventListener('studio-scene-change',render);render();
})();

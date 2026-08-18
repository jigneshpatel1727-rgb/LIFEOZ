/* AllInMyDay Studio — focused preview mode. */
(()=>{
  const stage=document.querySelector('.stage');
  const tools=[...document.querySelectorAll('.tool')];
  if(!stage||!tools.length)return;
  const style=document.createElement('style');
  style.textContent=`body.aimd-preview .left-panel,body.aimd-preview .right-panel,body.aimd-preview .topbar nav,body.aimd-preview .top-actions,body.aimd-preview .viewport-head,body.aimd-preview .viewport-controls{opacity:0;pointer-events:none;transition:opacity .2s}body.aimd-preview .workspace{grid-template-columns:1fr}body.aimd-preview .stage{height:calc(100vh - 26px)}body.aimd-preview .hint{display:none}body.aimd-preview:after{content:'PREVIEW  ·  ESC TO EXIT';position:fixed;top:76px;left:50%;transform:translateX(-50%);z-index:30;padding:7px 12px;border:1px solid #24536a;border-radius:20px;background:#06121de8;color:#8ed8e8;font-size:9px;letter-spacing:.16em;pointer-events:none}`;
  document.head.appendChild(style);
  const enter=()=>{document.body.classList.add('aimd-preview');const s=document.querySelector('#status');if(s)s.textContent='PREVIEW · REALTIME SCENE';};
  const exit=()=>{document.body.classList.remove('aimd-preview');const s=document.querySelector('#status');if(s)s.textContent='READY · ORIGINAL ALLINMYDAY STUDIO';};
  tools.find(b=>b.dataset.tool==='preview')?.addEventListener('click',enter);
  addEventListener('keydown',e=>{if(e.key==='Escape'&&document.body.classList.contains('aimd-preview'))exit();});
  stage.addEventListener('dblclick',()=>{if(document.body.classList.contains('aimd-preview'))exit();});
})();

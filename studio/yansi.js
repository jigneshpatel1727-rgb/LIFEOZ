/* AllInMyDay Studio — iAmYansi local creative orchestration layer. No external service required. */
(()=>{
const engine=window.AllInMyDayStudioEngine;if(!engine)return;
const panel=document.querySelector('.yansi-panel');const action=document.querySelector('.yansi-action');if(!panel||!action)return;
const input=document.createElement('input');input.type='text';input.placeholder='Describe what you want to create…';input.setAttribute('aria-label','Tell iAmYansi what to create');input.className='yansi-input';
const reply=document.createElement('div');reply.className='yansi-reply';reply.setAttribute('aria-live','polite');action.before(input,reply);
const say=t=>{reply.textContent=t;const s=document.querySelector('#status');if(s)s.textContent='iAmYansi · '+t};
function interpret(text){const q=text.toLowerCase();let type='primitive';if(/sphere|ball|orb|cocoon|round/.test(q))type='cocoon';else if(/strap|band|belt|ring/.test(q))type='strap';else if(/core|body|shell|case|housing/.test(q))type='core';else if(/text|label|word/.test(q))type='text';
const id=engine.add(type);const o=engine.state.objects.find(x=>x.id===id);if(/small|compact|mini/.test(q))Object.assign(o,{sx:.65,sy:.65,sz:.65});if(/large|big|wide/.test(q))Object.assign(o,{sx:1.6,sy:1.6,sz:1.6});if(/tall|vertical/.test(q))Object.assign(o,{sy:1.8});if(/flat|thin/.test(q))Object.assign(o,{sy:.45});if(/rotate/.test(q))o.ry=.7;if(/soft|protective|elastomer|tpu/.test(q))engine.setMaterial('Adaptive TPU Cocoon');else if(/thermal|heat/.test(q))engine.setMaterial('Thermal Composite');else if(/polymer|engineering/.test(q))engine.setMaterial('Engineering Polymer');else if(/sensor/.test(q))engine.setMaterial('Sensor Elastomer');
if(/light|glow|luminous|bright/.test(q))engine.setLighting({soft:true});engine.update(o.id,{x:o.x,y:o.y,z:o.z,rx:o.rx,ry:o.ry,rz:o.rz,sx:o.sx,sy:o.sy,sz:o.sz});say(`Created a ${type} and prepared its scene properties.`);}
action.addEventListener('click',()=>{input.focus();say('Tell me what you want to create.');});input.addEventListener('keydown',e=>{if(e.key==='Enter'&&input.value.trim()){interpret(input.value.trim());input.value=''}});window.iAmYansi={interpret,say};
})();

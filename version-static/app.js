const $ = (id) => document.getElementById(id);
const KEYS = { users: 'closetAuraUsers', session: 'closetAuraSession', clothes: 'closetAuraClothes', outfits: 'closetAuraOutfits', weather: 'closetAuraWeather' };
let authMode = 'login';
let currentUser = null;
let currentRecommendation = null;
let toastTimer;

const seedClothes = [
 ['Blusa de seda blanca','superior','blanco',2,'elegante','👚'],
 ['Camisa Oxford azul','superior','azul',2,'formal','👔'],
 ['Top negro básico','superior','negro',1,'casual','👕'],
 ['Suéter oversized beige','superior','beige',4,'casual','🧶'],
 ['Cardigan gris','superior','gris',3,'casual','🧥'],
 ['Hoodie rosa','superior','rosa',3,'deportivo','🧥'],
 ['Jeans skinny azul','inferior','azul',2,'casual','👖'],
 ['Jeans mom negros','inferior','negro',2,'casual','👖'],
 ['Pantalón de vestir beige','inferior','beige',3,'formal','👖'],
 ['Pantalón sastre negro','inferior','negro',3,'formal','👖'],
 ['Falda midi plisada','inferior','verde',2,'elegante','👗'],
 ['Vestido midi negro','vestido','negro',2,'elegante','👗'],
 ['Vestido floral de verano','vestido','multicolor',1,'casual','👗'],
 ['Vestido cóctel rojo','vestido','rojo',3,'elegante','👗'],
 ['Tenis blancos','calzado','blanco',1,'casual','👟'],
 ['Tenis deportivos','calzado','negro',2,'deportivo','👟'],
 ['Zapatos de tacón negros','calzado','negro',2,'elegante','👠'],
 ['Mocasines beige','calzado','beige',2,'formal','👞'],
 ['Botas de lluvia amarillas','calzado','amarillo',3,'casual','🥾'],
 ['Botas de lluvia negras','calzado','negro',3,'casual','🥾'],
 ['Gabardina beige','abrigo','beige',4,'formal','🧥'],
 ['Chamarra de piel negra','abrigo','negro',3,'casual','🧥'],
 ['Abrigo de lana gris','abrigo','gris',5,'elegante','🧥'],
 ['Impermeable transparente','abrigo','transparente',3,'casual','🌂'],
 ['Chamarra impermeable azul','abrigo','azul',4,'casual','🧥'],
 ['Bolso de mano negro','accesorio','negro',1,'elegante','👜'],
 ['Mochila casual','accesorio','gris',1,'casual','🎒'],
 ['Bufanda de lana roja','accesorio','rojo',4,'casual','🧣'],
 ['Collar dorado elegante','accesorio','dorado',1,'elegante','📿'],
 ['Paraguas negro','accesorio','negro',1,'casual','☂️'],
 ['Paraguas transparente','accesorio','transparente',1,'elegante','☂️']
].map((x,i)=>({id:'seed-'+i,name:x[0],category:x[1],color:x[2],warmth:x[3],style:x[4],emoji:x[5]}));

const stockPhotos = {
 superior:'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?auto=format&fit=crop&w=600&q=80',
 inferior:'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=600&q=80',
 vestido:'https://images.unsplash.com/photo-1495385794356-15371f348c31?auto=format&fit=crop&w=600&q=80',
 calzado:'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=600&q=80',
 abrigo:'https://images.unsplash.com/photo-1548624149-f9b5b7b9b4d7?auto=format&fit=crop&w=600&q=80',
 accesorio:'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=600&q=80'
};
const categoryNames = {superior:'Parte superior',inferior:'Parte inferior',vestido:'Vestido',calzado:'Calzado',abrigo:'Abrigo',accesorio:'Accesorio'};
const occasionStyles = {casual:['casual'],trabajo:['formal','elegante'],fiesta:['elegante','formal'],deporte:['deportivo'],universidad:['casual']};
const neutral = ['negro','blanco','gris','beige','marron','cafe','crema','transparente'];
const colorPairs = [['azul','rosa'],['azul','beige'],['azul','dorado'],['verde','dorado'],['verde','beige'],['rojo','cafe'],['rosa','gris'],['cafe','beige'],['cafe','dorado'],['amarillo','negro']];
const rainShoes = ['Botas de lluvia amarillas','Botas de lluvia negras'];
const rainCoats = ['Impermeable transparente','Chamarra impermeable azul'];
const rainUmbrellas = ['Paraguas negro','Paraguas transparente'];
function getUsers(){return JSON.parse(localStorage.getItem(KEYS.users)||'[]')}
function getClothes(){return JSON.parse(localStorage.getItem(KEYS.clothes)||'{}')[currentUser.email] || seedClothes.map(x=>({...x,image:''}))}
function setClothes(items){const all=JSON.parse(localStorage.getItem(KEYS.clothes)||'{}');all[currentUser.email]=items;localStorage.setItem(KEYS.clothes,JSON.stringify(all))}
function getOutfits(){return JSON.parse(localStorage.getItem(KEYS.outfits)||'{}')[currentUser.email]||[]}
function setOutfits(items){const all=JSON.parse(localStorage.getItem(KEYS.outfits)||'{}');all[currentUser.email]=items;localStorage.setItem(KEYS.outfits,JSON.stringify(all))}
function getWeather(){return JSON.parse(localStorage.getItem(KEYS.weather)||'{}')[currentUser.email]||null}
function setWeather(value){const all=JSON.parse(localStorage.getItem(KEYS.weather)||'{}');all[currentUser.email]=value;localStorage.setItem(KEYS.weather,JSON.stringify(all))}
function safe(text){return String(text).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))}
function showToast(message){const el=$('toast');el.textContent=message;el.classList.add('show');clearTimeout(toastTimer);toastTimer=setTimeout(()=>el.classList.remove('show'),2600)}
function showAuth(){ $('authView').classList.remove('hidden');$('appView').classList.add('hidden');$('authError').textContent='';}
function showApp(){ $('authView').classList.add('hidden');$('appView').classList.remove('hidden');const name=currentUser.name||currentUser.email.split('@')[0];$('sideUserName').textContent=name;$('avatarInitial').textContent=name.charAt(0).toUpperCase();$('topAvatar').textContent=name.charAt(0).toUpperCase();renderWardrobe();renderSavedOutfits();updateDashboard();goTo('dashboard');const w=getWeather();if(w){$('temperature').value=w.temperature;$('weather').value=w.rain;$('occasion').value=w.occasion;}}
function switchAuth(){authMode=authMode==='login'?'register':'login';$('authTitle').textContent=authMode==='login'?'Inicia sesión':'Crea tu cuenta';$('authSubtitle').textContent=authMode==='login'?'Entra para consultar tu guardarropa personal.':'Regístrate para empezar a organizar tus prendas.';$('nameField').classList.toggle('hidden',authMode==='login');$('fullName').required=authMode==='register';$('authSubmit').innerHTML=authMode==='login'?'Iniciar sesión <span>→</span>':'Crear cuenta <span>→</span>';$('switchText').textContent=authMode==='login'?'¿Aún no tienes cuenta?':'¿Ya tienes una cuenta?';$('switchAuth').textContent=authMode==='login'?'Crear cuenta':'Iniciar sesión';$('authError').textContent='';$('password').autocomplete=authMode==='login'?'current-password':'new-password';}
$('switchAuth').addEventListener('click',switchAuth);
$('authForm').addEventListener('submit',e=>{e.preventDefault();const email=$('email').value.trim().toLowerCase(),password=$('password').value,name=$('fullName').value.trim();let users=getUsers();if(authMode==='register'){if(users.some(u=>u.email===email)){$('authError').textContent='Ya existe una cuenta con ese correo.';return}const user={email,password,name:name||email.split('@')[0]};users.push(user);localStorage.setItem(KEYS.users,JSON.stringify(users));currentUser=user;localStorage.setItem(KEYS.session,email);showApp();showToast('¡Cuenta creada! Bienvenida/o a Closet Aura.');}else{const user=users.find(u=>u.email===email&&u.password===password);if(!user){$('authError').textContent='Correo o contraseña incorrectos. Si es tu primera vez, crea una cuenta.';return}currentUser=user;localStorage.setItem(KEYS.session,email);showApp();showToast('¡Qué gusto verte de nuevo!');}});
$('logoutBtn').addEventListener('click',()=>{localStorage.removeItem(KEYS.session);currentUser=null;showAuth();$('authForm').reset();authMode='login';switchAuth();showToast('Sesión cerrada.');});
function goTo(page){document.querySelectorAll('.page').forEach(p=>p.classList.add('hidden'));$(page+'Page').classList.remove('hidden');document.querySelectorAll('.nav-item[data-page]').forEach(b=>b.classList.toggle('active',b.dataset.page===page));const headings={dashboard:'Hola, qué gusto verte ✨',wardrobe:'Tus prendas, siempre a la mano',outfits:'Encuentra tu próximo conjunto'};$('pageHeading').textContent=headings[page];if(page==='wardrobe')renderWardrobe();if(page==='outfits')renderSavedOutfits();}
document.querySelectorAll('[data-page]').forEach(b=>b.addEventListener('click',()=>goTo(b.dataset.page)));
document.querySelectorAll('[data-goto]').forEach(b=>b.addEventListener('click',()=>goTo(b.dataset.goto)));
function renderWardrobe(){if(!currentUser)return;const items=getClothes(),search=($('searchClothes').value||'').toLowerCase(),category=$('categoryFilter').value;const shown=items.filter(c=>c.name.toLowerCase().includes(search)&&(category==='todas'||c.category===category));$('totalClothes').textContent=items.length;$('clothingGrid').innerHTML=shown.map(c=>`<article class="clothing-card"><button class="delete-item" data-delete="${safe(c.id)}" title="Eliminar prenda">×</button><div class="clothing-art"><span class="emoji-fallback">${safe(c.emoji||'👚')}</span><img loading="lazy" src="${safe(c.image||stockPhotos[c.category]||stockPhotos.superior)}" alt="${safe(c.name)}" onerror="this.style.display='none'"></div><div class="clothing-info"><h4>${safe(c.name)}</h4><p>${safe(categoryNames[c.category]||c.category)} · ${safe(c.color)}</p><div class="tag-row"><span class="tag">${safe(c.style)}</span><span class="tag">Abrigo ${c.warmth}/5</span></div></div></article>`).join('');$('emptyWardrobe').classList.toggle('hidden',shown.length>0);$('clothingGrid').classList.toggle('hidden',shown.length===0);document.querySelectorAll('[data-delete]').forEach(b=>b.addEventListener('click',()=>{setClothes(getClothes().filter(c=>c.id!==b.dataset.delete));renderWardrobe();updateDashboard();showToast('Prenda eliminada.')}));}
$('searchClothes').addEventListener('input',renderWardrobe);$('categoryFilter').addEventListener('change',renderWardrobe);
function openModal(){$('clothingModal').classList.remove('hidden');$('clothingError').textContent='';$('clothingName').focus()}
function closeModal(){$('clothingModal').classList.add('hidden');$('clothingForm').reset()}
$('addClothingBtn').addEventListener('click',openModal);document.querySelector('[data-add-clothing]').addEventListener('click',openModal);$('closeModal').addEventListener('click',closeModal);$('clothingModal').addEventListener('click',e=>{if(e.target===$('clothingModal'))closeModal()});
$('clothingForm').addEventListener('submit',e=>{e.preventDefault();const item={id:'custom-'+Date.now(),name:$('clothingName').value.trim(),category:$('clothingCategory').value,color:$('clothingColor').value,warmth:Number($('clothingWarmth').value),style:$('clothingFormality').value,emoji:$('clothingEmoji').value,image:$('clothingImage').value.trim()};if(!item.name){$('clothingError').textContent='Escribe el nombre de la prenda.';return}setClothes([...getClothes(),item]);closeModal();renderWardrobe();updateDashboard();showToast('Prenda agregada a tu guardarropa.');});
function updateDashboard(){if(!currentUser)return;$('totalClothes').textContent=getClothes().length;const w=getWeather();$('dashTemp').textContent=w?`${w.temperature}°C`:'--°C';$('dashWeather').textContent=w?(w.rain==='si'?'Está lloviendo':'Sin lluvia'):'Actualiza el clima';$('dashOccasion').textContent=w?({universidad:'Universidad',casual:'Casual',trabajo:'Trabajo',fiesta:'Fiesta',deporte:'Deporte'}[w.occasion]||'—'):'—';}
function warmthRequirement(t){if(t<10)return 5;if(t<13)return 4;if(t<16)return 3;if(t<19)return 2;return 1}
function needsOuter(t){return t<16}
function colorCombines(a,b){return a===b||neutral.includes(a)||neutral.includes(b)||colorPairs.some(p=>(p[0]===a&&p[1]===b)||(p[0]===b&&p[1]===a))||(a==='multicolor'&&neutral.includes(b))||(b==='multicolor'&&neutral.includes(a))}
function suitable(item,occasion){return (occasionStyles[occasion]||[]).includes(item.style)}
function findOutfit(temp,rain,occasion){const clothes=getClothes(),required=warmthRequirement(temp),tops=clothes.filter(x=>x.category==='superior'&&suitable(x,occasion)),bottoms=clothes.filter(x=>x.category==='inferior'&&suitable(x,occasion)),dresses=clothes.filter(x=>x.category==='vestido'&&suitable(x,occasion)),shoes=clothes.filter(x=>x.category==='calzado'&&suitable(x,occasion)&&(rain==='si'?rainShoes.includes(x.name):!rainShoes.includes(x.name))),coats=clothes.filter(x=>x.category==='abrigo'&&x.warmth>=required&&suitable(x,occasion)&&(rain==='si'?rainCoats.includes(x.name):!rainCoats.includes(x.name))),accessories=clothes.filter(x=>x.category==='accesorio'&&(rain==='si'?rainUmbrellas.includes(x.name):!rainUmbrellas.includes(x.name)));
const combos=[];
function pushCombo(base,shoe,coat,acc){if(!shoe||!acc)return;if(rain==='si'&&(!coat||!rainCoats.includes(coat.name)||!rainUmbrellas.includes(acc.name)))return;if(rain==='no'&&(rainShoes.includes(shoe.name)||rainUmbrellas.includes(acc.name)||rainCoats.includes(coat?.name)))return;const warmth=base.reduce((s,x)=>s+(x.warmth||0),0);if(warmth<required)return;if(needsOuter(temp)&&!coat)return;if(coat&&!colorCombines(base[0].color,coat.color))return;const mainColor=base[0].color;if(!colorCombines(mainColor,shoe.color)||!colorCombines(base[0].color,acc.color))return;if(base.length>1&&!colorCombines(base[0].color,base[1].color))return;if(base.length>1&&!colorCombines(base[1].color,shoe.color))return;combos.push({items:[...base,shoe,...(coat?[coat]:[]),acc],occasion,temp,rain});}
for(const top of tops){for(const bottom of bottoms){for(const shoe of shoes){for(const acc of accessories){if(rain==='si'){for(const coat of coats)pushCombo([top,bottom],shoe,coat,acc)}else if(needsOuter(temp)){for(const coat of coats)pushCombo([top,bottom],shoe,coat,acc)}else pushCombo([top,bottom],shoe,null,acc)}}}}
for(const dress of dresses){for(const shoe of shoes){for(const acc of accessories){if(rain==='si'){for(const coat of coats){if(dress.warmth>=required)pushCombo([dress],shoe,coat,acc)}}else if(dress.warmth>=required){if(needsOuter(temp)){for(const coat of coats)pushCombo([dress],shoe,coat,acc)}else pushCombo([dress],shoe,null,acc)}}}}
return combos[0]||null;}
function renderRecommendation(rec){currentRecommendation=rec;if(!rec){$('outfitResult').innerHTML='<div class="result-placeholder"><span>☁</span><h3>No encontramos una combinación</h3><p>Prueba con otra ocasión o revisa las prendas disponibles en tu guardarropa.</p></div>';$('resultMessage').textContent='Las reglas requieren compatibilidad de estilo y color, abrigo suficiente y calzado adecuado para la lluvia.';$('saveOutfitBtn').classList.add('hidden');return}
$('outfitResult').innerHTML=`<div class="outfit-items">${rec.items.map(item=>`<div class="outfit-item"><span class="item-emoji">${safe(item.emoji)}</span><div><strong>${safe(item.name)}</strong><small>${safe(categoryNames[item.category])} · ${safe(item.color)}</small></div></div>`).join('')}</div>`;
$('resultMessage').textContent=`Recomendación para ${rec.temp}°C, ${rec.rain==='si'?'con lluvia':'sin lluvia'} y ocasión ${({universidad:'universidad',casual:'casual',trabajo:'trabajo',fiesta:'fiesta',deporte:'deporte'})[rec.occasion]}. ${needsOuter(rec.temp)?'Se incluye abrigo externo por la temperatura.':''}`;$('saveOutfitBtn').classList.remove('hidden');}
$('outfitForm').addEventListener('submit',e=>{e.preventDefault();const temp=Number($('temperature').value),rain=$('weather').value,occasion=$('occasion').value;if(!Number.isFinite(temp)||temp < -20||temp>55){showToast('Ingresa una temperatura válida.');return}const weather={temperature:temp,rain,occasion};setWeather(weather);$('weatherBadge').textContent=`${rain==='si'?'☂':'☀'} ${temp}°C · ${rain==='si'?'Lluvia':'Seco'}`;$('resultTitle').textContent='Tu conjunto recomendado';renderRecommendation(findOutfit(temp,rain,occasion));updateDashboard();showToast('Condiciones actualizadas.');});
$('saveOutfitBtn').addEventListener('click',()=>{if(!currentRecommendation)return;const outfits=getOutfits();outfits.unshift({...currentRecommendation,id:'outfit-'+Date.now()});setOutfits(outfits);renderSavedOutfits();showToast('Conjunto guardado en favoritos.');});
function renderSavedOutfits(){if(!currentUser)return;const outfits=getOutfits();$('savedOutfits').innerHTML=outfits.length?outfits.map(o=>`<article class="saved-card"><strong>✧ ${safe(o.items.map(i=>i.name).slice(0,2).join(' + '))}${o.items.length>2?'…':''}</strong><p>${safe(o.temp)}°C · ${o.rain==='si'?'Con lluvia':'Sin lluvia'}<br>${safe(o.items.map(i=>i.name).join(', '))}</p><button data-remove-outfit="${safe(o.id)}">Eliminar favorito</button></article>`).join(''):'<p class="muted">Todavía no has guardado conjuntos favoritos.</p>';document.querySelectorAll('[data-remove-outfit]').forEach(b=>b.addEventListener('click',()=>{setOutfits(getOutfits().filter(o=>o.id!==b.dataset.removeOutfit));renderSavedOutfits();showToast('Favorito eliminado.')}));}
function init(){const email=localStorage.getItem(KEYS.session);if(email){const user=getUsers().find(u=>u.email===email);if(user){currentUser=user;showApp();return}}showAuth();switchAuth();}
init();

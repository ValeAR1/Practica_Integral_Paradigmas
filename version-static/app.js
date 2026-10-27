<<<<<<< HEAD
// Closet Aura - Sistema Experto & Guardarropa Inteligente
// Paradigmas de Programación - ESCOM IPN
// Integración: API de Clima (Open-Meteo), Gestión de Ropa (Agregar/Eliminar),
//              Motor de Outfits con Diversidad (SWI-Prolog + Respaldo Local)

const $ = (id) => document.getElementById(id);
const KEYS = {
  users: 'closetAuraUsers',
  session: 'closetAuraSession',
  clothes: 'closetAuraClothes',
  outfits: 'closetAuraOutfits',
  weather: 'closetAuraWeather'
};

let authMode = 'login';
let currentUser = null;
let currentRecommendations = [];
let activeTabFilter = 'all'; // 'all' o índice 0, 1, 2...
let toastTimer;
let uploadedPhotoData = '';

// ==========================================================================
// 1. CATÁLOGO BASE DE PRENDAS
// ==========================================================================
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
  ['Leggings deportivos negros','inferior','negro',2,'deportivo','👖'],
  ['Short de mezclilla denim','inferior','azul',1,'casual','👖'],
  ['Minifalda a cuadros','inferior','rojo',2,'casual','👗'],
  ['Vestido midi negro','vestido','negro',2,'elegante','👗'],
  ['Vestido floral de verano','vestido','multicolor',1,'casual','👗'],
  ['Vestido cóctel rojo','vestido','rojo',3,'elegante','👗'],
  ['Tenis blancos','calzado','blanco',1,'casual','👟'],
  ['Tenis deportivos','calzado','negro',2,'deportivo','👟'],
  ['Zapatos de tacón negros','calzado','negro',2,'elegante','👠'],
  ['Mocasines beige','calzado','beige',2,'formal','👞'],
  ['Sandalias doradas','calzado','dorado',1,'casual','👡'],
  ['Botines cafés','calzado','cafe',3,'casual','👢'],
  ['Botas altas negras','calzado','negro',4,'elegante','👢'],
  ['Botas de lluvia amarillas','calzado','amarillo',3,'casual','🥾'],
  ['Botas de lluvia negras','calzado','negro',3,'casual','🥾'],
  ['Gabardina beige','abrigo','beige',4,'formal','🧥'],
  ['Chamarra de piel negra','abrigo','negro',3,'casual','🧥'],
  ['Abrigo de lana gris','abrigo','gris',5,'elegante','🧥'],
  ['Chamarra de mezclilla azul','abrigo','azul',2,'casual','🧥'],
  ['Impermeable transparente','abrigo','transparente',3,'casual','🌂'],
  ['Chamarra impermeable azul','abrigo','azul',4,'casual','🧥'],
  ['Bolso de mano negro','accesorio','negro',1,'elegante','👜'],
  ['Mochila casual','accesorio','gris',1,'casual','🎒'],
  ['Bufanda de lana roja','accesorio','rojo',4,'casual','🧣'],
  ['Collar dorado elegante','accesorio','dorado',1,'elegante','📿'],
  ['Gorra deportiva','accesorio','negro',1,'deportivo','🧢'],
  ['Cinturón de piel negro','accesorio','negro',1,'formal','👔'],
  ['Paraguas negro','accesorio','negro',1,'casual','☂️'],
  ['Paraguas transparente','accesorio','transparente',1,'elegante','☂️']
].map((x, i) => ({
  id: 'seed-' + i,
  name: x[0],
  category: x[1],
  color: x[2],
  warmth: x[3],
  style: x[4],
  emoji: x[5],
  image: ''
}));

const stockPhotos = {
  superior: 'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?auto=format&fit=crop&w=600&q=80',
  inferior: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=600&q=80',
  vestido: 'https://images.unsplash.com/photo-1495385794356-15371f348c31?auto=format&fit=crop&w=600&q=80',
  calzado: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=600&q=80',
  abrigo: 'https://images.unsplash.com/photo-1548624149-f9b5b7b9b4d7?auto=format&fit=crop&w=600&q=80',
  accesorio: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=600&q=80'
};

const categoryNames = {
  superior: 'Parte superior',
  inferior: 'Parte inferior',
  vestido: 'Vestido',
  calzado: 'Calzado',
  abrigo: 'Abrigo',
  accesorio: 'Accesorio'
};

const occasionStyles = {
  casual: ['casual', 'deportivo'],
  universidad: ['casual', 'deportivo'],
  trabajo: ['formal', 'elegante'],
  fiesta: ['elegante', 'formal'],
  deporte: ['deportivo', 'casual']
};

const neutralColors = ['negro', 'blanco', 'gris', 'beige', 'marron', 'cafe', 'crema', 'transparente', 'camel', 'dorado', 'plateado'];
const colorPairs = [
  ['azul', 'rosa'], ['azul', 'beige'], ['azul', 'dorado'], ['azul', 'amarillo'],
  ['azul', 'rojo'], ['azul', 'verde'],
  ['verde', 'dorado'], ['verde', 'beige'], ['verde', 'amarillo'], ['verde', 'cafe'],
  ['rojo', 'cafe'], ['rojo', 'rosa'],
  ['rosa', 'gris'], ['cafe', 'beige'], ['cafe', 'dorado'],
  ['amarillo', 'negro'], ['naranja', 'azul'], ['morado', 'amarillo'], ['morado', 'rosa']
];

// ==========================================================================
// 2. SERVICIO DE API DE CLIMA (Open-Meteo: 100% Gratuito y sin API Key)
// ==========================================================================
const WeatherService = {
  async getByCoords(lat, lon) {
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,precipitation,weather_code&timezone=auto`;
    const res = await fetch(url);
    if (!res.ok) throw new Error('No se pudo obtener la información meteorológica.');
    const data = await res.json();
    return this.parseCurrent(data);
  },

  async searchCity(query) {
    const url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(query)}&count=1&language=es&format=json`;
    const res = await fetch(url);
    if (!res.ok) throw new Error('No se pudo buscar la ciudad.');
    const data = await res.json();
    if (!data.results || data.results.length === 0) {
      throw new Error(`No encontramos resultados para "${query}". Intenta con otra ciudad.`);
    }
    return data.results[0];
  },

  async getByCity(cityName) {
    const city = await this.searchCity(cityName);
    const weather = await this.getByCoords(city.latitude, city.longitude);
    const locationName = `${city.name}${city.admin1 ? ', ' + city.admin1 : ''} (${city.country || ''})`;
    return { ...weather, location: locationName, cityName: city.name };
  },

  parseCurrent(data) {
    const current = data.current;
    const temp = Math.round(current.temperature_2m);
    const code = current.weather_code;
    const precip = current.precipitation || 0;

    // Códigos WMO donde llueve o precipita
    const rainCodes = [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 71, 73, 75, 77, 80, 81, 82, 85, 86, 95, 96, 99];
    const isRaining = precip > 0.1 || rainCodes.includes(code);

    let description = 'Cielo despejado';
    let icon = '☀️';

    if (code === 0) { description = 'Cielo despejado'; icon = '☀️'; }
    else if ([1, 2].includes(code)) { description = 'Parcialmente nublado'; icon = '🌤️'; }
    else if (code === 3) { description = 'Nublado'; icon = '☁️'; }
    else if ([45, 48].includes(code)) { description = 'Niebla'; icon = '🌫️'; }
    else if ([51, 53, 55, 56, 57].includes(code)) { description = 'Llovizna'; icon = '🌦️'; }
    else if ([61, 63, 65, 66, 67].includes(code)) { description = 'Lluvia'; icon = '🌧️'; }
    else if ([71, 73, 75, 77].includes(code)) { description = 'Nieve'; icon = '❄️'; }
    else if ([80, 81, 82].includes(code)) { description = 'Chubascos'; icon = '🌧️'; }
    else if ([95, 96, 99].includes(code)) { description = 'Tormenta'; icon = '⛈️'; }

    return {
      temperature: temp,
      isRaining: isRaining ? 'si' : 'no',
      description,
      icon,
      precipitation: precip
    };
  }
};

function applyWeatherToUI(w, locationName) {
  $('temperature').value = w.temperature;
  $('weather').value = w.isRaining;
  $('weatherBadge').textContent = `${w.isRaining === 'si' ? '☂ Lluvia' : '☀ Seco'} · ${w.temperature}°C`;

  // Banner en página de outfits
  $('weatherLiveBadge').classList.remove('hidden');
  $('weatherLiveIcon').textContent = w.icon;
  $('weatherLiveLocation').textContent = locationName || 'Ubicación consultada';
  $('weatherLiveText').textContent = `${w.temperature}°C · ${w.description} · ${w.isRaining === 'si' ? 'Con lluvia activa' : 'Sin lluvia'}`;

  // Actualizar dashboard
  $('dashTemp').textContent = `${w.temperature}°C`;
  $('dashWeather').textContent = `${w.icon} ${w.description}`;

  // Guardar en sesión
  const currentOccasion = $('occasion').value || 'casual';
  setWeather({
    temperature: w.temperature,
    rain: w.isRaining,
    occasion: currentOccasion,
    description: w.description,
    location: locationName
  });

  showToast(`🌤️ Clima actualizado: ${w.temperature}°C (${w.description})`);
}

// Botón de geolocalización por GPS
$('geoWeatherBtn').addEventListener('click', () => {
  if (!navigator.geolocation) {
    showToast('Tu navegador no soporta geolocalización.');
    return;
  }
  showToast('Consultando GPS...');
  navigator.geolocation.getCurrentPosition(
    async (pos) => {
      try {
        const weather = await WeatherService.getByCoords(pos.coords.latitude, pos.coords.longitude);
        applyWeatherToUI(weather, 'Tu ubicación actual');
      } catch (err) {
        showToast('Error al consultar clima por GPS: ' + err.message);
      }
    },
    (err) => {
      showToast('No se obtuvo permiso de ubicación: ' + err.message);
    },
    { timeout: 10000 }
  );
});

// Búsqueda de ciudad por texto
async function handleSearchCity() {
  const query = $('citySearchInput').value.trim();
  if (!query) {
    showToast('Ingresa el nombre de una ciudad.');
    return;
  }
  showToast(`Buscando clima en ${query}...`);
  try {
    const weather = await WeatherService.getByCity(query);
    applyWeatherToUI(weather, weather.location);
  } catch (err) {
    showToast(err.message);
  }
}

$('searchCityBtn').addEventListener('click', handleSearchCity);
$('citySearchInput').addEventListener('keydown', (e) => {
  if (e.key === 'Enter') {
    e.preventDefault();
    handleSearchCity();
  }
});

// Chips de ciudades sugeridas
document.querySelectorAll('.city-chip').forEach(btn => {
  btn.addEventListener('click', () => {
    $('citySearchInput').value = btn.dataset.city;
    handleSearchCity();
  });
});

$('dashWeatherCard').addEventListener('click', () => {
  goTo('outfits');
  $('citySearchInput').focus();
});

// ==========================================================================
// 3. PERSISTENCIA Y USUARIOS (LocalStorage)
// ==========================================================================
function getUsers() {
  return JSON.parse(localStorage.getItem(KEYS.users) || '[]');
}

function getClothes() {
  if (!currentUser) return [];
  let store;
  try {
    store = JSON.parse(localStorage.getItem(KEYS.clothes) || '{}');
  } catch (e) {
    store = {};
  }
  const userItems = store[currentUser.email];
  // Solo inicializa si el usuario nunca ha tenido prendas (primera vez)
  // o si el array está vacío/corrupto (no es array)
  if (!userItems || !Array.isArray(userItems) || userItems.length === 0) {
    const initial = seedClothes.map(x => ({ ...x }));
    store[currentUser.email] = initial;
    try { localStorage.setItem(KEYS.clothes, JSON.stringify(store)); } catch (e) {}
    return initial;
  }
  return userItems;
}

function setClothes(items) {
  if (!currentUser) return;
  const store = JSON.parse(localStorage.getItem(KEYS.clothes) || '{}');
  store[currentUser.email] = items;
  localStorage.setItem(KEYS.clothes, JSON.stringify(store));
}

function getOutfits() {
  if (!currentUser) return [];
  const store = JSON.parse(localStorage.getItem(KEYS.outfits) || '{}');
  return store[currentUser.email] || [];
}

function setOutfits(items) {
  if (!currentUser) return;
  const store = JSON.parse(localStorage.getItem(KEYS.outfits) || '{}');
  store[currentUser.email] = items;
  localStorage.setItem(KEYS.outfits, JSON.stringify(store));
}

function getWeather() {
  if (!currentUser) return null;
  const store = JSON.parse(localStorage.getItem(KEYS.weather) || '{}');
  return store[currentUser.email] || null;
}

function setWeather(value) {
  if (!currentUser) return;
  const store = JSON.parse(localStorage.getItem(KEYS.weather) || '{}');
  store[currentUser.email] = value;
  localStorage.setItem(KEYS.weather, JSON.stringify(store));
}

function safe(text) {
  return String(text || '').replace(/[&<>"']/g, c => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  }[c]));
}

function showToast(message) {
  const el = $('toast');
  el.textContent = message;
  el.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => el.classList.remove('show'), 3000);
}

// ==========================================================================
// 4. AUTENTICACIÓN Y NAVEGACIÓN
// ==========================================================================
function showAuth() {
  $('authView').classList.remove('hidden');
  $('appView').classList.add('hidden');
  $('authError').textContent = '';
}

function showApp() {
  $('authView').classList.add('hidden');
  $('appView').classList.remove('hidden');
  const name = currentUser.name || currentUser.email.split('@')[0];
  $('sideUserName').textContent = name;
  $('avatarInitial').textContent = name.charAt(0).toUpperCase();
  $('topAvatar').textContent = name.charAt(0).toUpperCase();
  renderWardrobe();
  renderSavedOutfits();
  updateDashboard();
  checkPrologServerHealth();
  goTo('dashboard');

  const w = getWeather();
  if (w) {
    $('temperature').value = w.temperature;
    $('weather').value = w.rain;
    $('occasion').value = w.occasion;
  }
}

function switchAuth() {
  authMode = authMode === 'login' ? 'register' : 'login';
  $('authTitle').textContent = authMode === 'login' ? 'Inicia sesión' : 'Crea tu cuenta';
  $('authSubtitle').textContent = authMode === 'login'
    ? 'Entra para consultar tu guardarropa personal.'
    : 'Regístrate para empezar a organizar tus prendas.';
  $('nameField').classList.toggle('hidden', authMode === 'login');
  $('fullName').required = authMode === 'register';
  $('authSubmit').innerHTML = authMode === 'login' ? 'Iniciar sesión <span>→</span>' : 'Crear cuenta <span>→</span>';
  $('switchText').textContent = authMode === 'login' ? '¿Aún no tienes cuenta?' : '¿Ya tienes una cuenta?';
  $('switchAuth').textContent = authMode === 'login' ? 'Crear cuenta' : 'Iniciar sesión';
  $('authError').textContent = '';
  $('password').autocomplete = authMode === 'login' ? 'current-password' : 'new-password';
}

$('switchAuth').addEventListener('click', switchAuth);

$('authForm').addEventListener('submit', (e) => {
  e.preventDefault();
  const email = $('email').value.trim().toLowerCase();
  const password = $('password').value;
  const name = $('fullName').value.trim();
  const users = getUsers();

  if (authMode === 'register') {
    if (users.some(u => u.email === email)) {
      $('authError').textContent = 'Ya existe una cuenta con ese correo.';
      return;
    }
    const user = { email, password, name: name || email.split('@')[0] };
    users.push(user);
    localStorage.setItem(KEYS.users, JSON.stringify(users));
    currentUser = user;
    localStorage.setItem(KEYS.session, email);
    showApp();
    showToast('¡Cuenta creada! Bienvenida/o a Closet Aura.');
  } else {
    const user = users.find(u => u.email === email && u.password === password);
    if (!user) {
      $('authError').textContent = 'Correo o contraseña incorrectos. Si es tu primera vez, crea una cuenta.';
      return;
    }
    currentUser = user;
    localStorage.setItem(KEYS.session, email);
    showApp();
    showToast('¡Qué gusto verte de nuevo!');
  }
});

$('logoutBtn').addEventListener('click', () => {
  localStorage.removeItem(KEYS.session);
  currentUser = null;
  showAuth();
  $('authForm').reset();
  authMode = 'login';
  switchAuth();
  showToast('Sesión cerrada.');
});

function goTo(page) {
  document.querySelectorAll('.page').forEach(p => p.classList.add('hidden'));
  $(page + 'Page').classList.remove('hidden');
  document.querySelectorAll('.nav-item[data-page]').forEach(b => b.classList.toggle('active', b.dataset.page === page));

  const headings = {
    dashboard: 'Hola, qué gusto verte ✨',
    wardrobe: 'Tus prendas, siempre a la mano',
    outfits: 'Encuentra todas tus combinaciones'
  };
  $('pageHeading').textContent = headings[page] || '';
  if (page === 'wardrobe') renderWardrobe();
  if (page === 'outfits') renderSavedOutfits();
}

document.querySelectorAll('[data-page]').forEach(b => b.addEventListener('click', () => goTo(b.dataset.page)));
document.querySelectorAll('[data-goto]').forEach(b => b.addEventListener('click', () => goTo(b.dataset.goto)));

// ==========================================================================
// 5. GESTIÓN DE PRENDAS (SUBIR, AGREGAR, ELIMINAR, RESTAURAR)
// ==========================================================================
function renderWardrobe() {
  if (!currentUser) return;
  const items = getClothes();
  const search = ($('searchClothes').value || '').toLowerCase().trim();
  const category = $('categoryFilter').value;

  const shown = items.filter(c =>
    c.name.toLowerCase().includes(search) &&
    (category === 'todas' || c.category === category)
  );

  $('totalClothes').textContent = items.length;

  $('clothingGrid').innerHTML = shown.map(c => `
    <article class="clothing-card">
      <button class="delete-item" data-delete="${safe(c.id)}" title="Eliminar prenda">×</button>
      <div class="clothing-art">
        <span class="emoji-fallback">${safe(c.emoji || '👚')}</span>
        <img loading="lazy" src="${safe(c.image || stockPhotos[c.category] || stockPhotos.superior)}"
             alt="${safe(c.name)}"
             onerror="this.style.display='none'">
      </div>
      <div class="clothing-info">
        <h4>${safe(c.name)}</h4>
        <p>${safe(categoryNames[c.category] || c.category)} · ${safe(c.color)}</p>
        <div class="tag-row">
          <span class="tag">${safe(c.style)}</span>
          <span class="tag">Abrigo ${c.warmth}/5</span>
        </div>
      </div>
      <div class="clothing-card-actions">
        <button class="card-delete-button" data-delete="${safe(c.id)}">
          <span>🗑️</span> Eliminar
        </button>
      </div>
    </article>
  `).join('');

  $('emptyWardrobe').classList.toggle('hidden', shown.length > 0);
  $('clothingGrid').classList.toggle('hidden', shown.length === 0);

  // Asignar listeners a los botones de eliminación
  document.querySelectorAll('[data-delete]').forEach(btn => {
    btn.onclick = (e) => {
      e.stopPropagation();
      const id = btn.dataset.delete;
      deleteClothing(id);
    };
  });
}

function deleteClothing(id) {
  const items = getClothes();
  const item = items.find(c => c.id === id);
  const name = item ? item.name : 'la prenda';

  if (!confirm(`¿Deseas eliminar "${name}" de tu guardarropa?`)) return;

  const updated = items.filter(c => c.id !== id);
  setClothes(updated);
  renderWardrobe();
  updateDashboard();
  showToast(`Prenda eliminada: "${name}"`);
}

// Restaurar catálogo demo inicial
$('resetWardrobeBtn').addEventListener('click', () => {
  if (confirm('¿Restablecer el guardarropa con las prendas de ejemplo? Esto recuperará todas las prendas base.')) {
    setClothes(seedClothes.map(x => ({ ...x })));
    renderWardrobe();
    updateDashboard();
    showToast('Guardarropa inicial restaurado.');
  }
});

$('searchClothes').addEventListener('input', renderWardrobe);
$('categoryFilter').addEventListener('change', renderWardrobe);

// Modal para agregar prenda
function openModal() {
  $('clothingModal').classList.remove('hidden');
  $('clothingError').textContent = '';
  $('clothingForm').reset();
  uploadedPhotoData = '';
  $('previewContainer').classList.add('hidden');
  $('dropZone').classList.remove('hidden');
  $('clothingName').focus();
}

function closeModal() {
  $('clothingModal').classList.add('hidden');
  $('clothingForm').reset();
  uploadedPhotoData = '';
  $('previewContainer').classList.add('hidden');
  $('dropZone').classList.remove('hidden');
}

$('addClothingBtn').addEventListener('click', openModal);
const addFirstBtn = document.querySelector('[data-add-clothing]');
if (addFirstBtn) addFirstBtn.addEventListener('click', openModal);
$('closeModal').addEventListener('click', closeModal);
$('clothingModal').addEventListener('click', (e) => {
  if (e.target === $('clothingModal')) closeModal();
});

// Manejo de subida de archivo de imagen
$('clothingFile').addEventListener('change', (e) => {
  const file = e.target.files && e.target.files[0];
  if (!file) return;

  if (!file.type.startsWith('image/')) {
    showToast('Por favor selecciona un archivo de imagen válido.');
    return;
  }

  const reader = new FileReader();
  reader.onload = (event) => {
    uploadedPhotoData = event.target.result;
    $('imagePreview').src = uploadedPhotoData;
    $('previewFileName').textContent = file.name;
    $('previewContainer').classList.remove('hidden');
    $('dropZone').classList.add('hidden');
  };
  reader.readAsDataURL(file);
});

$('removePhotoBtn').addEventListener('click', () => {
  uploadedPhotoData = '';
  $('clothingFile').value = '';
  $('previewContainer').classList.add('hidden');
  $('dropZone').classList.remove('hidden');
});

$('clothingForm').addEventListener('submit', (e) => {
  e.preventDefault();
  const name = $('clothingName').value.trim();
  const category = $('clothingCategory').value;
  const color = $('clothingColor').value;
  const warmth = Number($('clothingWarmth').value);
  const style = $('clothingFormality').value;
  const emoji = $('clothingEmoji').value;
  const urlImage = $('clothingImage').value.trim();

  if (!name) {
    $('clothingError').textContent = 'Escribe el nombre de la prenda.';
    return;
  }

  const finalImage = uploadedPhotoData || urlImage || '';

  const newItem = {
    id: 'custom-' + Date.now(),
    name,
    category,
    color,
    warmth,
    style,
    emoji,
    image: finalImage
  };

  const current = getClothes();
  setClothes([...current, newItem]);
  closeModal();
  renderWardrobe();
  updateDashboard();
  showToast(`¡Prenda "${name}" agregada exitosamente!`);
});

function updateDashboard() {
  if (!currentUser) return;
  $('totalClothes').textContent = getClothes().length;
  const w = getWeather();
  $('dashTemp').textContent = w ? `${w.temperature}°C` : '--°C';
  $('dashWeather').textContent = w
    ? `${w.rain === 'si' ? '☂ Con lluvia' : '☀ Sin lluvia'} · ${w.description || ''}`
    : 'Consultar API del clima';
  $('dashOccasion').textContent = w
    ? ({ universidad: 'Universidad', casual: 'Casual', trabajo: 'Trabajo', fiesta: 'Fiesta', deporte: 'Deporte' }[w.occasion] || '—')
    : '—';
}

// ==========================================================================
// 6. REGLAS LOCALES DE ARMONÍA Y DIVERSIDAD (RESPALDO CUANDO PROLOG ESTÁ OFFLINE)
// ==========================================================================
function warmthRequirement(t) {
  if (t < 10) return 5;
  if (t < 13) return 4;
  if (t < 16) return 3;
  if (t < 19) return 2;
  return 1;
}

function needsOuter(t) {
  return t < 16;
}

function colorCombines(a, b) {
  if (!a || !b) return true;
  if (a === b) return true;
  if (neutralColors.includes(a) || neutralColors.includes(b)) return true;
  if (a === 'multicolor' || b === 'multicolor') return true;
  return colorPairs.some(p => (p[0] === a && p[1] === b) || (p[0] === b && p[1] === a));
}

function suitable(item, occasion) {
  return (occasionStyles[occasion] || []).includes(item.style);
}

function isRainShoe(name) {
  const n = (name || '').toLowerCase();
  return n.includes('lluvia');
}

function isRainCoat(name) {
  const n = (name || '').toLowerCase();
  return n.includes('impermeable');
}

function isUmbrella(name) {
  const n = (name || '').toLowerCase();
  return n.includes('paraguas') || n.includes('sombrilla');
}

// Generador local con máxima diversidad cambiando prendas completas
function findDiverseOutfits(temp, rain, occasion, maxOutfits = 6) {
  const clothes = getClothes();
  if (!clothes || clothes.length === 0) return [];

  const required = warmthRequirement(temp);

  // Helpers para filtrar por categoría
  const byCategory = (cat) => clothes.filter(x => x.category === cat);

  // --- Separar por categoría ---
  const allTops     = byCategory('superior');
  const allBottoms  = byCategory('inferior');
  const allDresses  = byCategory('vestido');
  const allShoes    = byCategory('calzado');
  const allCoats    = byCategory('abrigo');
  const allAcc      = byCategory('accesorio');

  // --- Filtros de ocasión (con fallback a "todos") ---
  const okTop     = allTops.filter(x => suitable(x, occasion));
  const okBottom  = allBottoms.filter(x => suitable(x, occasion));
  const okDress   = allDresses.filter(x => suitable(x, occasion));
  const tops      = okTop.length    > 0 ? okTop    : allTops;
  const bottoms   = okBottom.length > 0 ? okBottom : allBottoms;
  const dresses   = okDress.length  > 0 ? okDress  : allDresses;

  // --- Calzado: lluvia → botas de lluvia si existen, sino cualquiera ---
  const rainShoes   = allShoes.filter(x => isRainShoe(x.name));
  const dryShoes    = allShoes.filter(x => !isRainShoe(x.name) && suitable(x, occasion));
  const dryShoesFb  = allShoes.filter(x => !isRainShoe(x.name));
  const shoes = rain === 'si'
    ? (rainShoes.length > 0 ? rainShoes : allShoes)
    : (dryShoes.length  > 0 ? dryShoes  : (dryShoesFb.length > 0 ? dryShoesFb : allShoes));

  // --- Abrigos: lluvia → impermeables; frío → cualquier abrigo; calor sin lluvia → ninguno ---
  const rainCoats = allCoats.filter(x => isRainCoat(x.name));
  const dryCoats  = allCoats.filter(x => !isRainCoat(x.name) && suitable(x, occasion));
  const dryCoatsFb = allCoats.filter(x => !isRainCoat(x.name));
  let preferredCoats;
  if (rain === 'si') {
    preferredCoats = rainCoats.length > 0 ? rainCoats : allCoats;
  } else {
    preferredCoats = dryCoats.length > 0 ? dryCoats : (dryCoatsFb.length > 0 ? dryCoatsFb : allCoats);
  }

  const requireCoat = needsOuter(temp); // temp < 16

  // --- Accesorios: lluvia → paraguas; sino cualquiera ---
  const umbrellas  = allAcc.filter(x => isUmbrella(x.name));
  const dryAcc     = allAcc.filter(x => !isUmbrella(x.name));
  const accessories = rain === 'si'
    ? (umbrellas.length > 0 ? umbrellas : allAcc)
    : (dryAcc.length > 0   ? dryAcc    : allAcc);

  const allCombos = [];

  // -------------------------------------------------------------------------
  // FUNCIÓN CENTRAL: evalúa y agrega una combinación si cumple las reglas
  // -------------------------------------------------------------------------
  function tryAdd(baseItems, shoe, coat, acc) {
    if (!shoe) return;
    if (requireCoat && !coat) return; // Con frío el abrigo es obligatorio

    const coatWarmth = coat ? (coat.warmth || 0) : 0;
    const totalWarmth = baseItems.reduce((s, x) => s + (x.warmth || 0), 0) + coatWarmth;
    if (totalWarmth < required) return; // No cumple requisito térmico

    // Armonía cromática (solo entre piezas principales visibles)
    const topColor    = baseItems[0].color;
    const bottomColor = baseItems.length > 1 ? baseItems[1].color : null;

    if (bottomColor && !colorCombines(topColor, bottomColor)) return;
    if (!colorCombines(topColor, shoe.color) &&
        !(bottomColor && colorCombines(bottomColor, shoe.color)) &&
        !neutralColors.includes(shoe.color)) return;
    if (coat && !colorCombines(topColor, coat.color) &&
        !(bottomColor && colorCombines(bottomColor, coat.color)) &&
        !neutralColors.includes(coat.color)) return;

    const fullItems = [
      ...baseItems,
      shoe,
      ...(coat ? [coat] : []),
      ...(acc  ? [acc]  : [])
    ];

    allCombos.push({
      items: fullItems,
      occasion, temp, rain,
      topId:    baseItems[0].id,
      bottomId: baseItems.length > 1 ? baseItems[1].id : 'dress',
      shoeId:   shoe.id,
      accId:    acc ? acc.id : 'none'
    });
  }

  // -------------------------------------------------------------------------
  // FASE 1 – ESTRICTA: con filtros de ocasión, color y temperatura
  // -------------------------------------------------------------------------
  const accList = accessories.length > 0 ? accessories : [null];

  // Dos piezas (top + bottom)
  for (const top of tops) {
    for (const bottom of bottoms) {
      for (const shoe of shoes) {
        for (const acc of accList) {
          if (requireCoat) {
            for (const coat of preferredCoats) tryAdd([top, bottom], shoe, coat, acc);
          } else if (rain === 'si' && preferredCoats.length > 0) {
            // Lluvia sin frío: con impermeable Y también sin él
            for (const coat of preferredCoats) tryAdd([top, bottom], shoe, coat, acc);
            tryAdd([top, bottom], shoe, null, acc);
          } else {
            tryAdd([top, bottom], shoe, null, acc);
          }
        }
      }
    }
  }

  // Vestidos
  for (const dress of dresses) {
    for (const shoe of shoes) {
      for (const acc of accList) {
        if (requireCoat) {
          for (const coat of preferredCoats) tryAdd([dress], shoe, coat, acc);
        } else if (rain === 'si' && preferredCoats.length > 0) {
          for (const coat of preferredCoats) tryAdd([dress], shoe, coat, acc);
          tryAdd([dress], shoe, null, acc);
        } else {
          tryAdd([dress], shoe, null, acc);
        }
      }
    }
  }

  // -------------------------------------------------------------------------
  // FASE 2 – FLEXIBLE: sin filtro de ocasión, sin filtro de color estricto
  // -------------------------------------------------------------------------
  if (allCombos.length === 0) {
    const fb_tops    = allTops.length    > 0 ? allTops    : [];
    const fb_bottoms = allBottoms.length > 0 ? allBottoms : [];
    const fb_shoes   = allShoes.length   > 0 ? allShoes   : [];
    const fb_acc     = allAcc.length     > 0 ? [allAcc[0]] : [null];
    const fb_coat    = allCoats.length   > 0 ? allCoats[0] : null;

    for (const top of fb_tops) {
      for (const bottom of fb_bottoms) {
        if (!colorCombines(top.color, bottom.color)) continue;
        for (const shoe of fb_shoes) {
          const coat = requireCoat ? fb_coat : (rain === 'si' ? fb_coat : null);
          const coatWarmth = coat ? (coat.warmth || 0) : 0;
          const totalWarmth = (top.warmth || 0) + (bottom.warmth || 0) + coatWarmth;
          if (totalWarmth < required) continue;
          for (const acc of fb_acc) {
            allCombos.push({
              items: [top, bottom, shoe, ...(coat ? [coat] : []), ...(acc ? [acc] : [])],
              occasion, temp, rain,
              topId: top.id, bottomId: bottom.id, shoeId: shoe.id, accId: acc ? acc.id : 'none'
            });
          }
        }
      }
    }

    // También vestidos en fase 2
    for (const dress of allDresses) {
      if (fb_shoes.length === 0) break;
      const shoe = fb_shoes[0];
      const coat = requireCoat ? fb_coat : (rain === 'si' ? fb_coat : null);
      const coatWarmth = coat ? (coat.warmth || 0) : 0;
      const totalWarmth = (dress.warmth || 0) + coatWarmth;
      if (totalWarmth >= required) {
        allCombos.push({
          items: [dress, shoe, ...(coat ? [coat] : []), ...(fb_acc[0] ? [fb_acc[0]] : [])],
          occasion, temp, rain,
          topId: dress.id, bottomId: 'dress', shoeId: shoe.id, accId: fb_acc[0] ? fb_acc[0].id : 'none'
        });
      }
    }
  }

  // -------------------------------------------------------------------------
  // FASE 3 – ÚLTIMO RECURSO: sin ninguna restricción
  // -------------------------------------------------------------------------
  if (allCombos.length === 0) {
    const fb_shoes = allShoes.length > 0 ? allShoes : [];
    const fb_coat  = allCoats.length > 0 ? allCoats[0] : null;
    const fb_acc   = allAcc.length > 0   ? allAcc[0]   : null;

    for (const top of allTops) {
      for (const bottom of allBottoms) {
        for (const shoe of fb_shoes) {
          allCombos.push({
            items: [top, bottom, shoe, ...(fb_coat ? [fb_coat] : []), ...(fb_acc ? [fb_acc] : [])],
            occasion, temp, rain,
            topId: top.id, bottomId: bottom.id, shoeId: shoe.id, accId: fb_acc ? fb_acc.id : 'none'
          });
        }
      }
    }
    for (const dress of allDresses) {
      if (fb_shoes.length === 0) break;
      allCombos.push({
        items: [dress, fb_shoes[0], ...(fb_coat ? [fb_coat] : []), ...(fb_acc ? [fb_acc] : [])],
        occasion, temp, rain,
        topId: dress.id, bottomId: 'dress', shoeId: fb_shoes[0].id, accId: fb_acc ? fb_acc.id : 'none'
      });
    }
  }

  if (allCombos.length === 0) return [];

  // -------------------------------------------------------------------------
  // ALGORITMO DE DIVERSIDAD: penalizar repetición de prendas
  // -------------------------------------------------------------------------
  const selected = [];
  const pool = [...allCombos];

  while (selected.length < maxOutfits && pool.length > 0) {
    let bestIndex = 0;
    let minPenalty = Infinity;

    for (let i = 0; i < pool.length; i++) {
      const candidate = pool[i];
      let penalty = 0;
      for (const sel of selected) {
        if (candidate.topId    === sel.topId)    penalty += 7;
        if (candidate.bottomId === sel.bottomId) penalty += 7;
        if (candidate.topId === sel.topId && candidate.bottomId === sel.bottomId) penalty += 20;
        if (candidate.shoeId  === sel.shoeId)  penalty += 4;
        if (candidate.accId   === sel.accId)   penalty += 2;
      }
      if (penalty < minPenalty) { minPenalty = penalty; bestIndex = i; }
    }

    const chosen = pool.splice(bestIndex, 1)[0];
    selected.push({
      id:          selected.length + 1,
      titulo:      `Propuesta ${selected.length + 1}: ${chosen.items.slice(0, 2).map(x => x.name).join(' con ')}`,
      items:       chosen.items,
      temperatura: temp,
      lluvia:      rain,
      ocasion
    });
  }

  return selected;
}

// ==========================================================================
// 7. RENDERIZADO DE MÚLTIPLES COMBINACIONES (CAMBIANDO TODO)
// ==========================================================================
function renderMultipleOutfits(outfits, temp, rain, occasion) {
  currentRecommendations = outfits;
  activeTabFilter = 'all';

  if (!outfits || outfits.length === 0) {
    $('outfitsTabsBar').classList.add('hidden');
    $('outfitResult').innerHTML = `
      <div class="result-placeholder">
        <span>☁</span>
        <h3>No encontramos una combinación compatible</h3>
        <p>Las reglas actuales de clima (${temp}°C, ${rain === 'si' ? 'con lluvia' : 'seco'}) y ocasión (${occasion}) no coinciden con las prendas de tu guardarropa. Prueba agregando más prendas o cambiando de ocasión.</p>
      </div>`;
    $('resultMessage').textContent = 'Consejo: Sube más prendas con distintos estilos y niveles térmicos.';
    return;
  }

  // Barra de pestañas
  $('outfitsTabsBar').classList.remove('hidden');
  $('outfitsTabsList').innerHTML = `
    <button class="outfit-tab-btn active" data-tab="all">✦ Ver todas (${outfits.length})</button>
    ${outfits.map((o, idx) => `
      <button class="outfit-tab-btn" data-tab="${idx}">Look ${idx + 1}</button>
    `).join('')}
  `;

  // Asignar listeners de pestañas
  document.querySelectorAll('.outfit-tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.outfit-tab-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      activeTabFilter = btn.dataset.tab;
      renderProposalCards();
    });
  });

  renderProposalCards();

  $('resultMessage').innerHTML = `
    ✨ <strong>${outfits.length} combinaciones completas generadas</strong> para <strong>${temp}°C</strong>,
    <strong>${rain === 'si' ? 'con lluvia' : 'sin lluvia'}</strong> y ocasión <strong>${occasion}</strong>.
    Cada look cambia prendas superiores, inferiores, calzado y accesorios.
  `;
}

const categoryEmojiMap = {
  superior: '👚',
  inferior: '👖',
  vestido: '👗',
  calzado: '👟',
  abrigo: '🧥',
  accesorio: '👜'
};

function getItemEmoji(item) {
  if (item.emoji && item.emoji.length <= 4 && !['top', 'bottom', 'dress', 'shoes', 'coat', 'acc'].includes(item.emoji)) {
    return item.emoji;
  }
  return categoryEmojiMap[item.category] || '✨';
}

function renderProposalCards() {
  const list = activeTabFilter === 'all'
    ? currentRecommendations
    : [currentRecommendations[Number(activeTabFilter)]];

  $('outfitResult').innerHTML = `
    <div class="outfit-proposals-grid">
      ${list.map((outfit, idx) => {
        const realIdx = activeTabFilter === 'all' ? idx + 1 : Number(activeTabFilter) + 1;
        return `
          <article class="proposal-card">
            <div class="proposal-header">
              <div class="proposal-tag-wrap">
                <span class="proposal-badge">Look #${realIdx}</span>
                <h4>${safe(outfit.titulo || `Combinación ${realIdx}`)}</h4>
              </div>
              <span class="weather-badge">${outfit.lluvia === 'si' ? '☂ Lluvia' : '☀ Seco'} · ${outfit.temperatura}°C</span>
            </div>
            <div class="proposal-items">
              ${outfit.items.map(item => {
                const emoji = getItemEmoji(item);
                const imgSrc = item.image || stockPhotos[item.category] || '';
                return `
                <div class="proposal-item">
                  ${imgSrc
                    ? `<img class="proposal-thumb" src="${safe(imgSrc)}" alt="${safe(item.name)}" onerror="this.outerHTML='<span class=\\'proposal-emoji\\'>${safe(emoji)}</span>'">`
                    : `<span class="proposal-emoji">${safe(emoji)}</span>`
                  }
                  <div class="proposal-info">
                    <strong>${safe(item.name)}</strong>
                    <small>${safe(categoryNames[item.category] || item.category)} · ${safe(item.color)}</small>
                  </div>
                </div>
              `;}).join('')}
            </div>
            <div class="proposal-actions">
              <button class="btn-save-proposal" data-save-idx="${realIdx - 1}">
                ♡ Guardar esta combinación en favoritos
              </button>
            </div>
          </article>
        `;
      }).join('')}
    </div>
  `;

  // Asignar listeners para guardar conjuntos individuales
  document.querySelectorAll('[data-save-idx]').forEach(btn => {
    btn.addEventListener('click', () => {
      const index = Number(btn.dataset.saveIdx);
      saveSingleOutfit(currentRecommendations[index]);
    });
  });
}

function saveSingleOutfit(outfit) {
  if (!outfit) return;
  const saved = getOutfits();
  const newFav = {
    ...outfit,
    id: 'outfit-' + Date.now(),
    savedAt: new Date().toLocaleDateString()
  };
  saved.unshift(newFav);
  setOutfits(saved);
  renderSavedOutfits();
  showToast(`¡Look guardado en favoritos! (${outfit.items.length} prendas)`);
}

function renderSavedOutfits() {
  if (!currentUser) return;
  const outfits = getOutfits();
  $('savedOutfits').innerHTML = outfits.length
    ? outfits.map(o => `
      <article class="saved-card">
        <strong>✧ ${safe(o.titulo || o.items.map(i => i.name).slice(0, 2).join(' + '))}</strong>
        <p>${safe(o.temperatura)}°C · ${o.lluvia === 'si' ? 'Con lluvia' : 'Sin lluvia'}<br>
           ${safe(o.items.map(i => i.name).join(' · '))}</p>
        <button data-remove-outfit="${safe(o.id)}">Eliminar de favoritos</button>
      </article>
    `).join('')
    : '<p class="muted">Todavía no has guardado conjuntos favoritos.</p>';

  document.querySelectorAll('[data-remove-outfit]').forEach(b => {
    b.addEventListener('click', () => {
      setOutfits(getOutfits().filter(o => o.id !== b.dataset.removeOutfit));
      renderSavedOutfits();
      showToast('Favorito eliminado.');
    });
  });
}

// ==========================================================================
// 8. ENVÍO DEL FORMULARIO DE OUTFITS (SWI-PROLOG + RESPALDO LOCAL)
// ==========================================================================
$('outfitForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const temp = Number($('temperature').value);
  const rain = $('weather').value;
  const occasion = $('occasion').value;

  if (!Number.isFinite(temp) || temp < -20 || temp > 55) {
    showToast('Ingresa una temperatura válida entre -20 y 55 °C.');
    return;
  }

  $('weatherBadge').textContent = `${rain === 'si' ? '☂ Lluvia' : '☀ Seco'} · ${temp}°C`;
  $('resultTitle').textContent = `Combinaciones recomendadas para ocasión ${occasion}`;

  const userClothes = getClothes();
  console.log('[Closet Aura] Prendas disponibles:', userClothes.length, '| Temp:', temp, '| Lluvia:', rain, '| Ocasión:', occasion);

  // 1. Intentar consultar al motor de inferencia SWI-Prolog
  let prologOk = false;
  try {
    const res = await fetch('/api/recomendar', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        temperatura: temp,
        lluvia: rain,
        ocasion: occasion,
        prendas: userClothes
      })
    });

    if (res.ok) {
      const data = await res.json();
      console.log('[Closet Aura] Respuesta Prolog:', data);
      if (data.ok && Array.isArray(data.outfits) && data.outfits.length > 0) {
        renderMultipleOutfits(data.outfits, temp, rain, occasion);
        updateDashboard();
        showToast(`✨ ${data.total} combinaciones generadas con SWI-Prolog`);
        setPrologStatus(true);
        prologOk = true;
      }
    }
  } catch (err) {
    console.info('[Closet Aura] Servidor Prolog no disponible:', err.message);
  }

  // 2. Respaldo local si Prolog no funcionó o no devolvió resultados
  if (!prologOk) {
    setPrologStatus(false);
    const clothes = getClothes();
    console.log('[Closet Aura] Ejecutando motor local...');
    console.log('  Tops:', clothes.filter(x => x.category === 'superior').length);
    console.log('  Bottoms:', clothes.filter(x => x.category === 'inferior').length);
    console.log('  Vestidos:', clothes.filter(x => x.category === 'vestido').length);
    console.log('  Calzado:', clothes.filter(x => x.category === 'calzado').length);
    console.log('  Abrigos:', clothes.filter(x => x.category === 'abrigo').length);
    console.log('  Accesorios:', clothes.filter(x => x.category === 'accesorio').length);
    const localOutfits = findDiverseOutfits(temp, rain, occasion, 6);
    console.log('[Closet Aura] Combinaciones locales generadas:', localOutfits.length);
    renderMultipleOutfits(localOutfits, temp, rain, occasion);
    updateDashboard();
    showToast(`✨ ${localOutfits.length} combinaciones generadas (Modo local)`);
  }
});

// Comprobar salud del servidor Prolog
async function checkPrologServerHealth() {
  try {
    const res = await fetch('/api/salud');
    if (res.ok) {
      const data = await res.json();
      if (data.estado === 'ok') {
        setPrologStatus(true);
        return;
      }
    }
  } catch (_) {}
  setPrologStatus(false);
}

function setPrologStatus(isOnline) {
  const chip = $('prologStatusChip');
  if (!chip) return;
  chip.classList.toggle('connected', isOnline);
  chip.classList.toggle('offline', !isOnline);
  chip.textContent = isOnline ? '● Prolog Conectado' : '○ Modo Local (Prolog offline)';
}

// ==========================================================================
// 9. INICIALIZACIÓN
// ==========================================================================
function init() {
  const email = localStorage.getItem(KEYS.session);
  if (email) {
    const user = getUsers().find(u => u.email === email);
    if (user) {
      currentUser = user;
      showApp();
      return;
    }
  }
  showAuth();
  switchAuth();
}

=======
const $ = (id) => document.getElementById(id);
const KEYS = { users: 'closetAuraUsers', session: 'closetAuraSession', clothes: 'closetAuraClothes', outfits: 'closetAuraOutfits', weather: 'closetAuraWeather' };
let authMode = 'login';
let currentUser = null;
let currentRecommendation = null;
let toastTimer;
let token = null;      // sesion del servidor
let wardrobe = [];     // guardarropa del usuario (viene del servidor)
let lastPersonalized = false;
let editingClothingId = null;

// ---- Comunicacion con el servidor ----
async function api(path, options = {}) {
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
  if (token) headers['Authorization'] = 'Bearer ' + token;
  const res = await fetch(path, { ...options, headers });
  let data = {};
  try { data = await res.json(); } catch (e) { /* respuesta sin JSON */ }
  return { ok: res.ok, status: res.status, data };
}
function firstError(r, fallback) { return (r.data && r.data.errores && r.data.errores[0]) || fallback; }

// Nombre, icono e imagen de cada prenda se guardan solo en este navegador
// (el servidor guarda tipo, color, abrigo y estilo).
function getExtras() { try { return JSON.parse(localStorage.getItem('closetAuraExtras') || '{}'); } catch (e) { return {}; } }
function setExtra(id, extra) { const all = getExtras(); const k = currentUser.email; all[k] = all[k] || {}; all[k][id] = extra; localStorage.setItem('closetAuraExtras', JSON.stringify(all)); }
function removeExtra(id) { const all = getExtras(), k = currentUser.email; if (all[k]) { delete all[k][id]; localStorage.setItem('closetAuraExtras', JSON.stringify(all)); } }
const defaultEmoji = { superior: '👚', inferior: '👖', vestido: '👗', calzado: '👟', abrigo: '🧥', accesorio: '👜' };
function prettyName(id) { const t = String(id).replace(/_/g, ' '); return t.charAt(0).toUpperCase() + t.slice(1); }
function mapPrenda(p) {
  const ex = (getExtras()[currentUser.email] || {})[p.id] || {};
  return { id: p.id, name: ex.name || prettyName(p.id), category: p.tipo, color: p.color, warmth: p.abrigo, style: p.formalidad, emoji: ex.emoji || defaultEmoji[p.tipo] || '👚', image: ex.image || '' };
}
async function loadWardrobe() {
  const r = await api('/api/prendas');
  if (!r.ok) throw new Error(firstError(r, 'No se pudo cargar tu guardarropa.'));
  wardrobe = (r.data.prendas || []).map(mapPrenda);
}
function saveSession() { localStorage.setItem(KEYS.session, JSON.stringify({ email: currentUser.email, name: currentUser.name, token })); }

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
function getClothes(){return wardrobe}
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
$('authForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = $('email').value.trim().toLowerCase(), password = $('password').value, name = $('fullName').value.trim();
  $('authError').textContent = '';
  const btn = $('authSubmit'); btn.disabled = true;
  try {
    const r = await api(authMode === 'register' ? '/api/registro' : '/api/login', { method: 'POST', body: JSON.stringify({ email, password }) });
    if (!r.ok) { $('authError').textContent = firstError(r, 'No se pudo iniciar sesión.'); return; }
    token = r.data.token;
    currentUser = { email, name: name || email.split('@')[0] };
    if (authMode === 'login') { const saved = JSON.parse(localStorage.getItem('closetAuraNames') || '{}'); currentUser.name = saved[email] || currentUser.name; }
    else { const saved = JSON.parse(localStorage.getItem('closetAuraNames') || '{}'); saved[email] = currentUser.name; localStorage.setItem('closetAuraNames', JSON.stringify(saved)); }
    await loadWardrobe();
    saveSession();
    showApp();
    showToast(authMode === 'register' ? '¡Cuenta creada! Bienvenida/o a Closet Aura.' : '¡Qué gusto verte de nuevo!');
  } catch (err) {
    $('authError').textContent = 'No pude comunicarme con el servidor. Revisa que esté encendido.';
  } finally { btn.disabled = false; }
});
$('logoutBtn').addEventListener('click',()=>{api('/api/logout',{method:'POST',body:'{}'}).catch(()=>{});token=null;wardrobe=[];localStorage.removeItem(KEYS.session);currentUser=null;showAuth();$('authForm').reset();authMode='login';switchAuth();showToast('Sesión cerrada.');});
function goTo(page){document.querySelectorAll('.page').forEach(p=>p.classList.add('hidden'));$(page+'Page').classList.remove('hidden');document.querySelectorAll('.nav-item[data-page]').forEach(b=>b.classList.toggle('active',b.dataset.page===page));const headings={dashboard:'Hola, qué gusto verte ✨',wardrobe:'Tus prendas, siempre a la mano',outfits:'Encuentra tu próximo conjunto'};$('pageHeading').textContent=headings[page];if(page==='wardrobe')renderWardrobe();if(page==='outfits')renderSavedOutfits();}
document.querySelectorAll('[data-page]').forEach(b=>b.addEventListener('click',()=>goTo(b.dataset.page)));
document.querySelectorAll('[data-goto]').forEach(b=>b.addEventListener('click',()=>goTo(b.dataset.goto)));
function renderWardrobe(){if(!currentUser)return;const items=getClothes(),search=($('searchClothes').value||'').toLowerCase(),category=$('categoryFilter').value;const shown=items.filter(c=>c.name.toLowerCase().includes(search)&&(category==='todas'||c.category===category));$('totalClothes').textContent=items.length;$('clothingGrid').innerHTML=shown.map(c=>`<article class="clothing-card"><button class="delete-item" data-edit="${safe(c.id)}" style="left:9px;right:auto" title="Editar prenda" aria-label="Editar ${safe(c.name)}">✎</button><button class="delete-item" data-delete="${safe(c.id)}" title="Eliminar prenda" aria-label="Eliminar ${safe(c.name)}">×</button><div class="clothing-art"><span class="emoji-fallback">${safe(c.emoji||'👚')}</span><img loading="lazy" src="${safe(c.image||stockPhotos[c.category]||stockPhotos.superior)}" alt="${safe(c.name)}" onerror="this.style.display='none'"></div><div class="clothing-info"><h4>${safe(c.name)}</h4><p>${safe(categoryNames[c.category]||c.category)} · ${safe(c.color)}</p><div class="tag-row"><span class="tag">${safe(c.style)}</span><span class="tag">Abrigo ${c.warmth}/5</span></div></div></article>`).join('');$('emptyWardrobe').classList.toggle('hidden',shown.length>0);$('clothingGrid').classList.toggle('hidden',shown.length===0);document.querySelectorAll('[data-delete]').forEach(b=>b.addEventListener('click',async()=>{const r=await api('/api/prendas?id='+encodeURIComponent(b.dataset.delete),{method:'DELETE'});if(!r.ok){showToast(firstError(r,'No se pudo eliminar la prenda.'));return}try{await loadWardrobe()}catch(err){}renderWardrobe();updateDashboard();showToast('Prenda eliminada.')}));document.querySelectorAll('[data-edit]').forEach(b=>b.addEventListener('click',()=>openEditModal(b.dataset.edit)));}
$('searchClothes').addEventListener('input',renderWardrobe);$('categoryFilter').addEventListener('change',renderWardrobe);
function openModal(){editingClothingId=null;$('modalEyebrow').textContent='NUEVA PIEZA';$('modalTitle').textContent='Agregar prenda';$('saveClothingBtn').textContent='Guardar prenda';$('clothingModal').classList.remove('hidden');$('clothingError').textContent='';$('clothingForm').reset();$('clothingName').focus()}
function openEditModal(id){const c=getClothes().find(x=>String(x.id)===String(id));if(!c)return;editingClothingId=c.id;$('modalEyebrow').textContent='EDITAR PIEZA';$('modalTitle').textContent='Editar prenda';$('saveClothingBtn').textContent='Guardar cambios';$('clothingError').textContent='';$('clothingName').value=c.name;$('clothingCategory').value=c.category;$('clothingColor').value=c.color;$('clothingWarmth').value=String(c.warmth);$('clothingFormality').value=c.style;$('clothingEmoji').value=c.emoji||'👚';$('clothingImage').value=c.image||'';$('clothingModal').classList.remove('hidden');$('clothingName').focus()}
function closeModal(){$('clothingModal').classList.add('hidden');$('clothingForm').reset();editingClothingId=null}
$('addClothingBtn').addEventListener('click',openModal);document.querySelector('[data-add-clothing]').addEventListener('click',openModal);$('closeModal').addEventListener('click',closeModal);$('clothingModal').addEventListener('click',e=>{if(e.target===$('clothingModal'))closeModal()});
$('clothingForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const name = $('clothingName').value.trim();
  if (!name) { $('clothingError').textContent = 'Escribe el nombre de la prenda.'; return; }
  const body = { nombre: name, tipo: $('clothingCategory').value, color: $('clothingColor').value, abrigo: Number($('clothingWarmth').value), formalidad: $('clothingFormality').value };
  const oldId = editingClothingId;
  const path = oldId === null ? '/api/prendas' : '/api/prendas?id=' + encodeURIComponent(oldId);
  const r = await api(path, { method: oldId === null ? 'POST' : 'PUT', body: JSON.stringify(body) });
  if (!r.ok) { $('clothingError').textContent = firstError(r, 'No se pudo guardar la prenda.'); return; }
  if (oldId !== null && String(oldId) !== String(r.data.id)) removeExtra(oldId);
  setExtra(r.data.id, { name, emoji: $('clothingEmoji').value, image: $('clothingImage').value.trim() });
  try { await loadWardrobe(); } catch (err) {}
  closeModal(); renderWardrobe(); updateDashboard(); showToast(oldId === null ? 'Prenda agregada a tu guardarropa.' : 'Prenda actualizada.');
});
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
$('outfitForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const temp = Number($('temperature').value), rain = $('weather').value, occasion = $('occasion').value;
  if (!Number.isFinite(temp) || temp < -20 || temp > 55) {
    showToast('Ingresa una temperatura válida.');
    return;
  }
  const weather = { temperature: temp, rain, occasion };
  setWeather(weather);
  $('weatherBadge').textContent = `${rain === 'si' ? '☂' : '☀'} ${temp}°C · ${rain === 'si' ? 'Lluvia' : 'Seco'}`;
  $('resultTitle').textContent = 'Tu conjunto recomendado';

  // Intentar consultar al motor de inferencia SWI-Prolog
  try {
    const r = await api('/api/recomendar', {
      method: 'POST',
      body: JSON.stringify({ temperatura: temp, lluvia: rain, ocasion: occasion })
    });
    const data = r.data;
    if (r.ok && data.ok) {
      if (data.total > 0 && data.outfit) {
        const items = data.outfit.items.map((it) => { const mine = wardrobe.find((c) => c.id === it.id); return { ...it, emoji: (mine && mine.emoji) || defaultEmoji[it.category] || '👚', name: (mine && mine.name) || it.name }; });
        renderRecommendation({ ...data.outfit, items });
        $('resultMessage').textContent += ' ' + (data.total > 1 ? `Prolog encontró ${data.total} combinaciones y aquí se muestra la primera.` : 'Prolog encontró 1 combinación.');
        updateDashboard();
        showToast('✨ Recomendación inferida con SWI-Prolog');
      } else {
        renderRecommendation(null);
        if (data.mensaje) $('resultMessage').textContent = data.mensaje;
        updateDashboard();
        showToast('Prolog no encontró una combinación.');
      }
      return;
    }
  } catch (err) {
    console.warn('Servidor Prolog no disponible, usando motor local como respaldo:', err);
    showToast('Servidor Prolog no disponible: se usó el motor local de respaldo.');
  }

  // Respaldo local si no responde el backend Prolog
  renderRecommendation(findOutfit(temp, rain, occasion));
  updateDashboard();
  showToast('Condiciones actualizadas.');
});
$('saveOutfitBtn').addEventListener('click',()=>{if(!currentRecommendation)return;const outfits=getOutfits();outfits.unshift({...currentRecommendation,id:'outfit-'+Date.now()});setOutfits(outfits);renderSavedOutfits();showToast('Conjunto guardado en favoritos.');});
function renderSavedOutfits(){if(!currentUser)return;const outfits=getOutfits();$('savedOutfits').innerHTML=outfits.length?outfits.map(o=>`<article class="saved-card"><strong>✧ ${safe(o.items.map(i=>i.name).slice(0,2).join(' + '))}${o.items.length>2?'…':''}</strong><p>${safe(o.temp)}°C · ${o.rain==='si'?'Con lluvia':'Sin lluvia'}<br>${safe(o.items.map(i=>i.name).join(', '))}</p><button data-remove-outfit="${safe(o.id)}">Eliminar favorito</button></article>`).join(''):'<p class="muted">Todavía no has guardado conjuntos favoritos.</p>';document.querySelectorAll('[data-remove-outfit]').forEach(b=>b.addEventListener('click',()=>{setOutfits(getOutfits().filter(o=>o.id!==b.dataset.removeOutfit));renderSavedOutfits();showToast('Favorito eliminado.')}));}
async function init() {
  try {
    const saved = JSON.parse(localStorage.getItem(KEYS.session) || 'null');
    if (saved && saved.token) {
      token = saved.token; currentUser = { email: saved.email, name: saved.name };
      await loadWardrobe();
      showApp();
      return;
    }
  } catch (err) { /* sesion vencida o servidor apagado */ }
  token = null; currentUser = null; localStorage.removeItem(KEYS.session);
  showAuth(); switchAuth();
}
>>>>>>> 22ab16d6f04a8c03ab2a540954fd331b43b2e613
init();

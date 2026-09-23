const el = (id) => document.getElementById(id);

const statusDot = el('status-dot');
const statusText = el('status-text');
const viewportImg = el('viewport-img');
const fpsBadge = el('fps-badge');
const contextBox = el('context-box');

const sliderWidth = el('slider-width');
const sliderLength = el('slider-length');
const sliderHeight = el('slider-height');
const valWidth = el('val-width');
const valLength = el('val-length');
const valHeight = el('val-height');
const numX = el('num-x');
const numY = el('num-y');
const numZ = el('num-z');
const selectView = el('select-view');
const selectMode = el('select-mode');

let params = { width: 10, length: 10, height: 10, x: 0, y: 0, z: 0 };
let pushTimer = null;
let viewportTimer = null;
let viewportInFlight = false;

function setStatus(ok, text) {
  statusDot.className = 'status-dot ' + (ok ? 'live' : 'down');
  statusText.textContent = text;
}

function syncLabels() {
  valWidth.textContent = params.width;
  valLength.textContent = params.length;
  valHeight.textContent = params.height;
}

function schedulePush() {
  clearTimeout(pushTimer);
  pushTimer = setTimeout(pushParams, 180);
}

async function pushParams() {
  try {
    const res = await fetch('/api/box', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params)
    });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const data = await res.json();
    if (!data.ok) throw new Error(data.error || 'unknown error');
    setStatus(true, 'live');
    refreshViewport();
  } catch (err) {
    setStatus(false, 'push failed: ' + err.message);
  }
}

async function refreshViewport() {
  if (viewportInFlight) return;
  viewportInFlight = true;
  const t0 = performance.now();
  try {
    const view = selectView.value;
    const mode = selectMode.value;
    const res = await fetch(`/api/viewport?w=720&h=480&view=${encodeURIComponent(view)}&mode=${encodeURIComponent(mode)}`);
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const data = await res.json();
    if (!data.ok) throw new Error(data.error || 'unknown error');
    viewportImg.src = `data:${data.mime};base64,${data.image}`;
    fpsBadge.textContent = Math.round(performance.now() - t0) + ' ms';
    setStatus(true, 'live');
  } catch (err) {
    setStatus(false, 'viewport error: ' + err.message);
  } finally {
    viewportInFlight = false;
  }
}

async function refreshContext() {
  try {
    const res = await fetch('/api/context');
    const data = await res.json();
    if (!data.ok) throw new Error(data.error || 'unknown error');
    const c = data.context;
    const gh = (c.grasshopper || []).map(g =>
      `${g.version}: ${g.canvasOpen ? 'open' : 'closed'}${g.canvasOpen ? ` — ${g.componentCount ?? '?'} components, ${g.wireCount ?? '?'} wires` : ''}`
    ).join('\n');
    contextBox.innerHTML =
      `<b>Viewport:</b> ${c.activeViewport?.name ?? '—'} (${c.activeViewport?.displayMode ?? '—'})\n` +
      `<b>Objects:</b> ${c.document?.objectCount ?? '—'}   <b>Layers:</b> ${c.document?.layerCount ?? '—'}\n` +
      `<b>Selection:</b> ${c.selection?.length ?? 0} object(s)\n\n` +
      `<b>Grasshopper</b>\n${gh || '(no canvas open)'}`;
  } catch (err) {
    contextBox.textContent = 'context error: ' + err.message;
  }
}

function bindSlider(slider, key, label) {
  slider.addEventListener('input', () => {
    params[key] = parseFloat(slider.value);
    label.textContent = params[key];
    schedulePush();
  });
}
bindSlider(sliderWidth, 'width', valWidth);
bindSlider(sliderLength, 'length', valLength);
bindSlider(sliderHeight, 'height', valHeight);

[[numX, 'x'], [numY, 'y'], [numZ, 'z']].forEach(([input, key]) => {
  input.addEventListener('input', () => {
    const v = parseFloat(input.value);
    if (!Number.isNaN(v)) {
      params[key] = v;
      schedulePush();
    }
  });
});

selectView.addEventListener('change', refreshViewport);
selectMode.addEventListener('change', refreshViewport);
el('btn-refresh-context').addEventListener('click', refreshContext);

function startViewportLoop() {
  clearInterval(viewportTimer);
  viewportTimer = setInterval(refreshViewport, 1200);
}

syncLabels();
pushParams();
refreshContext();
startViewportLoop();
setInterval(refreshContext, 4000);

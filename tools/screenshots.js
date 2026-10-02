// Curbside: the landing page's "How it works" images (Brief 22 item 10).
//
//   node tools/screenshots.js            replay: the six stage images and the report cover thumbnail, from the fixtures
//   node tools/screenshots.js --record   the same, recording the network data into the fixtures first
//
// One site (Commercial Drive & E 1st Avenue), a fixed 1200 x 750 viewport at 2x, a fixed clock and a seeded
// Math.random, and every request for site data (the local /overpass relay, City of Vancouver Open Data, the map
// tiles) answered from tools/fixtures/commercial/ -- so two runs write identical files. Libraries and fonts from
// the CDNs load as usual (they are pinned versions). Anything else is refused in replay and listed.
// Needs the local server (tools/start.cmd, http://localhost:8766) and Playwright's Chromium (see the README).
// Writes docs/landing/how-1-site.png, how-2-seed.png, how-3-design.png, how-5-access.png, how-6-visualize.png,
// how-4-report.png and report-cover.png (the landing page and the first-sign-in walkthrough), and prints each
// file's SHA-256.
'use strict';
const fs = require('fs'), path = require('path'), crypto = require('crypto');
const { chromium } = require('playwright');

const ROOT = path.resolve(__dirname, '..');
const BASE = process.env.CURBSIDE_URL || 'http://localhost:8766';
const RECORD = process.argv.includes('--record');
const FIX = path.join(__dirname, 'fixtures', 'commercial');
const OUT = path.join(ROOT, 'docs', 'landing');
const SITE = { lat: 49.27010, lon: -123.06942, context: 150 };   // the Commercial & 1st test site; a 150 m context keeps the fixtures small
const CLOCK = '2026-10-01T17:00:00Z';                              // the date every image shows
const LIVE = /^https:\/\/(cdn\.jsdelivr\.net|cdnjs\.cloudflare\.com|unpkg\.com|fonts\.googleapis\.com|fonts\.gstatic\.com)\//;
const DATA = /^https:\/\/(opendata\.vancouver\.ca|tile\.openstreetmap\.org|[a-z0-9.-]*overpass[a-z0-9.-]*|nominatim\.openstreetmap\.org)\//;

const sha = (b) => crypto.createHash('sha256').update(b).digest('hex');
const keyOf = (req) => sha(req.method() + ' ' + req.url() + ' ' + (req.postData() || '')).slice(0, 24);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function main() {
  fs.mkdirSync(FIX, { recursive: true }); fs.mkdirSync(OUT, { recursive: true });
  const idxPath = path.join(FIX, 'index.json');
  const index = fs.existsSync(idxPath) ? JSON.parse(fs.readFileSync(idxPath, 'utf8')) : {};
  if (!RECORD && !Object.keys(index).length) throw new Error('no fixtures in ' + FIX + ': run once with --record');
  const refused = [];

  const browser = await chromium.launch({ args: ['--enable-unsafe-swiftshader', '--use-angle=swiftshader', '--ignore-gpu-blocklist', '--font-render-hinting=none', '--disable-lcd-text'] });
  const context = await browser.newContext({ viewport: { width: 1200, height: 750 }, deviceScaleFactor: 2, locale: 'en-CA', timezoneId: 'America/Vancouver', colorScheme: 'dark', serviceWorkers: 'block' });

  // a clock that starts at CLOCK and runs (timers keep working), and a seeded Math.random
  await context.addInitScript(({ t0 }) => {
    const RD = Date, T0 = RD.parse(t0), P0 = performance.now(), now = () => Math.round(T0 + (performance.now() - P0));
    class FD extends RD { constructor(...a) { if (a.length) super(...a); else super(now()); } static now() { return now(); } }
    FD.parse = RD.parse; FD.UTC = RD.UTC; window.Date = FD;
    let s = 0x2f6e2b1; Math.random = function () { s |= 0; s = (s + 0x6d2b79f5) | 0; let t = Math.imul(s ^ (s >>> 15), 1 | s); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
  }, { t0: CLOCK });

  // site data: recorded, or replayed; the page's own files straight from the local server
  await context.route('**/*', async (route) => {
    const req = route.request(), url = req.url();
    const isData = DATA.test(url) || (url.startsWith(BASE) && /\/overpass\b/.test(url));
    if (!isData) {
      if (url.startsWith(BASE) || LIVE.test(url) || url.startsWith('data:') || url.startsWith('blob:')) return route.continue();
      if (RECORD) return route.continue();
      refused.push(url); return route.abort();
    }
    const k = keyOf(req), f = path.join(FIX, k + '.bin');
    if (!RECORD) {
      const e = index[k];
      if (e && e.failed) return route.abort();   // it failed when recorded: it fails again (the app retries the next server)
      if (!e || !fs.existsSync(f)) { refused.push(url); return route.abort(); }
      return route.fulfill({ status: e.status, headers: { 'content-type': e.type, 'access-control-allow-origin': '*' }, body: fs.readFileSync(f) });
    }
    let res;
    try { res = await route.fetch({ timeout: 90000 }); }
    catch (err) { index[k] = { url: url.slice(0, 300), method: req.method(), failed: String(err.message || err).split('\n')[0] }; return route.abort(); }
    const body = await res.body();
    fs.writeFileSync(f, body);
    index[k] = { url: url.length > 300 ? url.slice(0, 300) + '...' : url, method: req.method(), status: res.status(), type: res.headers()['content-type'] || 'application/octet-stream', bytes: body.length };
    return route.fulfill({ response: res, body });
  });

  const page = await context.newPage();
  page.on('pageerror', (e) => console.warn('[page error]', e.message));
  await page.goto(BASE + '/parklet-checker.html?noauth&gis=fixtures', { waitUntil: 'load' });   // the site data: the vendored cells (tools/test/gis-fixtures)
  await page.waitForFunction(() => typeof pkStage === 'function' && typeof SMP !== 'undefined');
  await sleep(2500);   // the first-visit blank design (stage 0) and the stage UI
  await page.addStyleTag({ content: '#pkToast, .ui-tip, #uiTip { display: none !important; } * { caret-color: transparent !important; }' });
  const shots = [];
  const shot = async (name) => { await sleep(600); const f = path.join(OUT, name); await page.screenshot({ path: f, animations: 'disabled', caret: 'hide', timeout: 120000 }); shots.push(f); console.log('  ' + name); };

  // 1. Choose a site: the map, the street and the parklet's side picked
  await page.evaluate(async (S) => {
    const W = (ms) => new Promise((r) => setTimeout(r, ms));
    appSetMode('site'); await SMP.setContext(S.context);
    await SM.open(); await W(800);
    SM.map.jumpTo({ center: [S.lon, S.lat], zoom: 17.5 });
    await new Promise((r) => { if (SM.map.loaded() && SM.map.areTilesLoaded()) r(); else SM.map.once('idle', r); });
    SM.pick = null; for (let i = 0; i < 3 && !(SM.pick && SM.pick.snap); i++) await SM.onClick(S.lat, S.lon);
    if (!(SM.pick && SM.pick.snap)) throw new Error('the street was not found at the site');
    SM.onClick(S.lat, S.lon); await W(400);
    await new Promise((r) => { SM.map.once('idle', r); SM.map.triggerRepaint(); });
  }, SITE);
  await shot('how-1-site.png');

  // 2. The seeded parklet: the import writes the existing street, the deck is placed at the host frontage
  await page.evaluate(async () => {
    const W = (ms) => new Promise((r) => setTimeout(r, ms));
    SM.use(); await W(800); SM.close();
    // an Overpass server that times out: Retry goes to the next one, as a user would (recorded, so a replay repeats it)
    const msg = () => document.getElementById('smpMsg').innerText.replace(/\s+/g, ' ');
    let rep = await SMP.importContext();
    for (let i = 0; !rep && i < 6 && document.getElementById('smpRetry'); i++) { await W(1500); document.getElementById('smpRetry').click(); await W(200); while (SMP._busy) await W(250); rep = /done \(/.test(msg()) ? SMP.lastReport : null; }
    if (!rep) throw new Error('the import failed: ' + msg());
    await W(1500);
    appSetMode('design'); setCanvasView('all'); await W(600); _pvFit('design'); fitAllViewports(); await W(1500);
  });
  if (await page.evaluate(() => pkStage()) !== 1) throw new Error('not at stage 1 after the import');
  // the Plan's key folded (it is open by default and covers the Plan at this panel size)
  const foldKey = () => page.evaluate(() => { const k = document.getElementById('pvKey'); if (k) k.open = false; });
  await foldKey();
  await shot('how-2-seed.png');

  // 3. Design and check: the test design's furniture on the deck, the checks beside it
  await page.evaluate(async () => {
    const W = (ms) => new Promise((r) => setTimeout(r, ms));
    const ds = getDesignState(), L = ds.site.parkletLength;
    ds.furniture.placed = [
      { objId: 'GEN-bench', archetype: 'bench', x: 0.55, z: L / 2, userRotation: 0, params: { l: 2.4, ends: 'plinth', back: true }, materials: { frame: 'black_steel', seat: 'black_stain', back: 'black_stain' } },
      { objId: 'GEN-cafe_table', archetype: 'cafe_table', x: 1.75, z: L / 2 - 4, userRotation: 0, params: {}, materials: {} },
      { objId: 'GEN-chair', archetype: 'chair', x: 1.75, z: L / 2 - 4.7, userRotation: Math.PI, params: {}, materials: {} },
      { objId: 'GEN-chair', archetype: 'chair', x: 1.75, z: L / 2 - 3.3, userRotation: 0, params: {}, materials: {} },
      { objId: 'GEN-umbrella', archetype: 'umbrella', x: 1.75, z: L / 2 - 4, userRotation: 0, params: {}, materials: {} },
      { objId: 'GEN-planter', archetype: 'planter', x: 2.1, z: L / 2 + 3.5, userRotation: 0, params: {}, materials: {} },
      { objId: 'GEN-bike_rack', archetype: 'bike_rack', x: 1.9, z: L / 2 + 6, userRotation: 0, params: {}, materials: {} }];
    applyDesignState(ds); await W(1500);
    appSetMode('check'); await W(1200);
  });
  await shot('how-3-design.png');

  // 5. Accessibility (Brief 28 item 4: the landing step and the walkthrough's card): the route over the deck plan
  await page.evaluate(async () => { appSetMode('accessibility'); await new Promise((r) => setTimeout(r, 2500)); });
  await foldKey();
  await page.mouse.move(5, 740);
  await shot('how-5-access.png');

  // 6. Visualize (the walkthrough's card): the 3D view at its Cover camera
  await page.evaluate(async () => {
    const W = (ms) => new Promise((r) => setTimeout(r, ms));
    appSetMode('visualize'); await W(6000);
    const b = [...document.querySelectorAll('button')].find((x) => /^Cover$/.test(x.textContent.trim()) && x.getClientRects().length);
    if (b) b.click(); await W(8000);
  });
  await page.mouse.move(5, 740);
  await shot('how-6-visualize.png');

  // 4. The report: the Export tab, then the cover itself as the thumbnail
  const cover = await page.evaluate(async () => {
    const W = (ms) => new Promise((r) => setTimeout(r, ms));
    appSetMode('export'); await W(1200);
    await RPT.loadEngine();
    const d = RPT.data('schematic'); d.renders = [];
    const drw = await RPT.drawings(d);
    return RPT.coverPNG(d, drw, RPT.COVER_OP, 1200);
  });
  await shot('how-4-report.png');
  const cf = path.join(OUT, 'report-cover.png'); fs.writeFileSync(cf, Buffer.from(cover.split(',')[1], 'base64')); shots.push(cf);

  await browser.close();
  if (RECORD) fs.writeFileSync(idxPath, JSON.stringify(Object.keys(index).sort().reduce((o, k) => { o[k] = index[k]; return o; }, {}), null, 1) + '\n');
  for (const f of shots) console.log(sha(fs.readFileSync(f)).slice(0, 16) + '  ' + path.relative(ROOT, f).replace(/\\/g, '/') + '  ' + fs.statSync(f).size + ' B');
  if (refused.length) console.log('refused (not in the fixtures): ' + refused.length + '\n  ' + Array.from(new Set(refused)).slice(0, 12).join('\n  '));
}
main().catch((e) => { console.error(e.message || e); process.exit(1); });

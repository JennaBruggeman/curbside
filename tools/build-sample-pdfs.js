// Builds the two sample reports as static files (Brief 28 item 12), so "Sample report" opens at once:
// demo/sample-schematic.pdf / .json and demo/sample-technical.pdf / .json (the .json: the counts and pages the viewer's
// bar shows, the version and date it was built). sample.html reads them; without them it builds the sample live.
// Run after a change to the report or to demo/sample-design.json, with the local server up (tools/serve.ps1):
//   node tools/build-sample-pdfs.js [http://localhost:8766]
// The build page runs on in-memory storage and never signs in (parklet-checker.html?sample=<mode>&build=1).
const { chromium } = require('playwright');
const fs = require('fs'), path = require('path');
const BASE = (process.argv[2] || 'http://localhost:8766').replace(/\/$/, '');
const OUT = path.join(__dirname, '..', 'demo');
(async () => {
  const b = await chromium.launch({ args: ['--enable-unsafe-swiftshader', '--ignore-gpu-blocklist', '--use-gl=swiftshader'] });
  try {
    for (const mode of ['schematic', 'technical']) {
      const p = await (await b.newContext({ viewport: { width: 1400, height: 900 } })).newPage();
      const t0 = Date.now();
      await p.goto(BASE + '/parklet-checker.html?sample=' + mode + '&build=1', { waitUntil: 'load', timeout: 180000 });
      await p.waitForFunction(() => window.__sampleReady, null, { timeout: 300000 });
      if ((await p.evaluate(() => window.__sampleReady)) !== true) throw new Error(mode + ': the sample did not build');
      const r = await p.evaluate(async () => {
        const s = window.__samplePDF, buf = new Uint8Array(await (await fetch(s.url)).arrayBuffer());
        let bin = ''; for (let i = 0; i < buf.length; i += 0x8000) bin += String.fromCharCode.apply(null, buf.subarray(i, i + 0x8000));
        return { b64: btoa(bin), info: s.info };
      });
      fs.writeFileSync(path.join(OUT, 'sample-' + mode + '.pdf'), Buffer.from(r.b64, 'base64'));
      fs.writeFileSync(path.join(OUT, 'sample-' + mode + '.json'), JSON.stringify(r.info, null, 2) + '\n');
      console.log(mode + ': ' + r.info.pages + ' pages, ' + Math.round(r.b64.length * 0.75 / 1024) + ' KB, ' + ((Date.now() - t0) / 1000).toFixed(1) + ' s');
      await p.context().close();
    }
  } finally { await b.close(); }
})().catch((e) => { console.error('build-sample-pdfs: ' + e.message); process.exit(1); });

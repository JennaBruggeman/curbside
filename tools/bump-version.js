// Bumps Curbside's version in one step (Brief 29c item 6): the sheets' stamp (RPT.VERSION in parklet-checker.html), the
// landing page's version (index.html, between <!-- VERSION --> and <!-- /VERSION -->), and the two sample reports, rebuilt
// so they carry the new version (demo/sample-*.pdf / .json, tools/build-sample-pdfs.js). The pre-push hook refuses a push
// whose sample reports say another version than the app, so this is the way to bump.
// Run with the local server up (tools/start.cmd or tools/serve.ps1), then review and commit the changed files:
//   node tools/bump-version.js v0.17 [http://localhost:8766]
const fs = require('fs'), path = require('path'), { execFileSync } = require('child_process');
const V = process.argv[2], BASE = (process.argv[3] || 'http://localhost:8766').replace(/\/$/, '');
const ROOT = path.join(__dirname, '..');
if (!/^v\d+\.\d+(\.\d+)?$/.test(V || '')) { console.error('usage: node tools/bump-version.js vX.Y[.Z] [server]'); process.exit(1); }
const edit = (file, re, to) => {
  const f = path.join(ROOT, file), s = fs.readFileSync(f, 'utf8');
  if (!re.test(s)) { console.error(file + ': the version mark was not found'); process.exit(1); }
  fs.writeFileSync(f, s.replace(re, to));
};
edit('parklet-checker.html', /^RPT\.VERSION = 'v[0-9.]+';$/m, "RPT.VERSION = '" + V + "';");
edit('index.html', /<!-- VERSION -->v[0-9.]+<!-- \/VERSION -->/, '<!-- VERSION -->' + V + '<!-- /VERSION -->');
console.log('version set to ' + V + ' in parklet-checker.html and index.html');
// the sample reports, from the server that now serves the bumped app
(async () => {
  try { const r = await fetch(BASE + '/parklet-checker.html', { cache: 'no-store' }); if (!(await r.text()).includes("RPT.VERSION = '" + V + "'")) throw new Error('the server at ' + BASE + ' does not serve this folder'); }
  catch (e) { console.error('cannot rebuild the sample reports: ' + e.message + '. Start tools/serve.ps1, then run node tools/build-sample-pdfs.js'); process.exit(1); }
  execFileSync(process.execPath, [path.join(__dirname, 'build-sample-pdfs.js'), BASE], { stdio: 'inherit', env: process.env });
  for (const m of ['schematic', 'technical']) {
    const j = JSON.parse(fs.readFileSync(path.join(ROOT, 'demo', 'sample-' + m + '.json'), 'utf8'));
    if (j.version !== V) { console.error('demo/sample-' + m + '.json says ' + j.version + ', not ' + V); process.exit(1); }
  }
  console.log('sample reports rebuilt at ' + V + '. Commit parklet-checker.html, index.html and demo/sample-*.pdf/.json.');
})();

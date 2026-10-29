// "Hot reload" prototype. The page is real content; the editor shows the
// code that "builds" it. Every orange or green value can be clicked to change
// it, and the page hot-reloads.

// ── Content ───────────────────────────────────────────────────────────────

const STATS = [
  ['+15%', 'onboarding retention'],
  ['−25%', 'crashes, live loan app'],
  ['98%', 'of Ajarra’s commits'],
  ['−40%', 'crashes after an audit'],
  ['4', 'payment SDKs shipped'],
  ['27', 'posts on Flutter'],
];

const PROJECTS = [
  {
    id: 'field', cls: 'FieldAgentApp', name: 'Field agent app', client: 'NeoCash · Shepherd Trust MFB', years: '2026 — now',
    blurb: 'The app field agents use to sign up borrowers in markets with patchy or no signal. Everything saves on the phone first and syncs when a connection comes back.',
    real: 'Main contributor (360 of 448 commits) to the offline-first engine we built as a team: an encrypted local database, a request queue that retries without creating duplicates, and conflict handling.',
    stack: ['Flutter', 'Riverpod', 'Drift', 'SQLCipher', 'Go'],
    demos: [['offlineSync', 'Offline sync', 'Turn on airplane mode and add customers. They queue, then sync one by one when you’re back online.']],
  },
  {
    id: 'loan', cls: 'LoanApp', name: 'Customer loan app', client: 'NeoCash', years: '2026 — now',
    blurb: 'The lending app on Google Play and the App Store.',
    real: 'Ten loan-rejection recovery flows, on-device guided face capture, location-aware address checks and a server-side PIN migration. Onboarding retention up about 15%, crashes down about 25%.',
    stack: ['Flutter', 'Riverpod', 'ML Kit', 'Go'],
    demos: [
      ['loanFix', 'Loan fix', 'A declined application with three things to fix. Fix them, then resubmit.'],
      ['faceCheck', 'Face check', 'Guided face capture: steer the face to each target angle.'],
    ],
  },
  {
    id: 'ajarra', cls: 'Ajarra', name: 'Ajarra', client: 'AJ’s Rentals · event marketplace', years: '2025 — 2026',
    blurb: 'A two-sided marketplace connecting event planners with vendors. I was the only mobile engineer, end to end.',
    real: 'Wrote 694 of its 707 commits: Socket.IO chat with an offline queue and voice notes, a calendar built from scratch, co-planning roles, escrow bookings, Paystack and Flutterwave payments.',
    stack: ['Flutter', 'BLoC', 'Socket.IO', 'Firebase'],
    demos: [
      ['calendar', 'Calendar', 'Overlapping tasks split into columns, with creator, co-planner and viewer roles.'],
      ['chat', 'Chat', 'Messages queue offline and send in order on reconnect, with ticks and voice notes.'],
      ['routeMap', 'Map', 'Tap a vendor to draw the route and watch the ETA count down.'],
    ],
  },
];

const CAREER = [
  ['a41f2c9', 'Software Engineer', 'NeoCash', 'Jan 2026 – now · Lagos', 'Flutter apps and the Go backend behind them: loan-rejection recovery, guided face capture, address checks, a server-side PIN migration, and the offline-first field-agent app.', 'HEAD -> main'],
  ['9b13e07', 'Mobile Developer', 'AJ’s Rentals (Ajarra)', 'Jun 2025 – May 2026 · Lagos', 'Built and shipped Ajarra on Android and iOS: real-time chat, a calendar from scratch, escrow bookings and payments.'],
  ['51c0d2a', 'Flutter Developer', 'Deolang', 'Jan – May 2025 · India, remote', 'Turned Figma designs into a guest-house finder with BLoC, REST APIs and Razorpay.'],
  ['7e2a6f1', 'Flutter Developer', 'Hermex Travels', 'Oct – Dec 2024 · Lagos', 'An AI support chatbot and Flutterwave payments for flights and hotels; cut UI boilerplate by about 40%.'],
  ['c08d3b4', 'Flutter Developer', 'Decentralyne', 'Aug – Oct 2024 · Lagos', 'Audited a crypto app’s Android and iOS codebases and cut crashes by about 40%.'],
  ['3fa9e10', 'Network Engineer', 'Nigerian Ports Authority', 'Apr – Dec 2024 · Lagos', 'BGP routing, Cisco and Huawei switches, VLANs and firewalls. Why I care what happens on the wire.'],
  ['0e8f3b1', 'BEng Electrical & Electronics Engineering', 'Obafemi Awolowo University', '2020 – 2025', '', 'tag: v1.0'],
];

const POSTS = [
  ['Designing a Scalable, High-Performance Real-Time Social Feed with Flutter', 'Aug 2026', 10, 'designing-a-scalable-high-performance-real-time-social-feed-with-flutter', 'Hashnode', 1],
  ['The Share Sheet Wanted Coordinates', 'Jun 2026', 5, 'the-share-sheet-wanted-coordinates', 'Hashnode', 0],
  ['The OTP Boxes That Would Not Let Go', 'Jun 2026', 6, 'the-otp-boxes-that-would-not-let-go', 'Hashnode', 1],
  ['The Logo Wasn’t Stretched. Flutter Was Just Being Literal.', 'May 2026', 7, 'the-logo-wasn-t-stretched-flutter-was-just-being-literal', 'Hashnode', 1],
  ['The Day a Text Cursor Fought the Keyboard', 'May 2026', 4, 'the-day-a-text-cursor-fought-the-keyboard', 'Hashnode', 0],
  ['The Quiet Work Behind a Flutter Endpoint', 'May 2026', 6, 'the-quiet-work-behind-a-flutter-endpoint', 'Hashnode', 0],
];

const ESSAYS = [
  ['Making the World a Better Place', 'Apr 2024 · 2 min', 'https://medium.com/wake-write-win/making-the-world-a-better-place-025bda69cc1f', 'better-place.jpg'],
  ['Do Not Care About What Others Think', 'Mar 2024 · 2 min', 'https://medium.com/new-writers-welcome/do-not-care-about-what-others-think-db9cc3a21b6c', 'what-others-think.jpg'],
  ['Is True Happiness an Illusion?', 'Jan 2024 · 3 min', 'https://medium.com/wake-write-win/is-true-happiness-an-illusion-0a64490a9e9f', 'happiness.jpg'],
];

const LEARNING = [
  ['Golang', 'I already ship Go on the backend at NeoCash, and I’m still levelling up on the server side of the APIs my apps talk to.'],
  ['ISO/IEC 27001', 'How an information security management system works: risk assessment, controls, and keeping evidence of both.'],
  ['Encryption & compliance', 'Encryption at rest and in transit, key management, and the frameworks fintech apps answer to.'],
];

// ── Editable values (each click moves to the next option) ─────────────────

const OPTIONS = {
  name: ['Damola Nelson', 'damooola'],
  role: ['Flutter mobile engineer', 'Flutter + Go engineer', 'Mobile engineer, fintech'],
  specialty: ['apps that work on one bar of signal', 'payments that never double-charge', 'code the next developer can maintain'],
  basedIn: ['Lagos, NG', 'Remote, any timezone'],
  status: ['openToWork', 'shipping'],
  ships: ['[Platform.android, Platform.ios]', '[Platform.android, Platform.ios, Platform.web]'],
  theme: ['paper', 'night', 'lagos'],
  loanDemo: ['loanFix', 'faceCheck'],
  ajarraDemo: ['calendar', 'chat', 'routeMap'],
  airplane: ['false', 'true'],
  sort: ['favourites', 'newest'],
  learning: ['golang', 'iso27001', 'encryption'],
  lastWin: ['false', 'true'],
  autoplay: ['false', 'true'],
  club: ['chelsea'],
};
const STRING_KEYS = new Set(['name', 'role', 'specialty', 'basedIn']);
const state = Object.fromEntries(Object.keys(OPTIONS).map((k) => [k, 0]));
const val = (k) => OPTIONS[k][state[k]];

const SPECIALTY_LINE = {
  'apps that work on one bar of signal': 'I build apps that still work on one bar of signal.',
  'payments that never double-charge': 'I build payment flows that never charge anyone twice.',
  'code the next developer can maintain': 'I write code the next developer can actually maintain.',
};

// ── Code files ────────────────────────────────────────────────────────────

const k = (s) => `<span class="kw">${s}</span>`;
const t = (s) => `<span class="ty">${s}</span>`;
const p = (s) => `<span class="pr">${s}</span>`;
const s = (x) => `<span class="str">'${x}'</span>`;
const n = (x) => `<span class="nu">${x}</span>`;
const c = (x) => `<span class="cm">${x}</span>`;
const v = (key, prefix = '') => STRING_KEYS.has(key)
  ? `<span class="v str-v" data-k="${key}">'${val(key)}'</span>`
  : `${prefix}<span class="v" data-k="${key}">${val(key)}</span>`;
const go = (file, label) => `<span class="jump" data-file="${file}">${label}</span>`;

const FILES = {
  'main.dart': { section: 'home', crumb: 'lib › <b>main.dart</b> › DamolaApp › build', lines: () => [
    [`${k('import')} ${s('package:flutter/material.dart')};`],
    [`${k('import')} '${go('work.dart', 'work.dart')}';`],
    [`${k('import')} '${go('writing.dart', 'writing.dart')}';`],
    [`${k('import')} '${go('after_hours.dart', 'after_hours.dart')}';`],
    [''],
    [`${k('void')} main() => runApp(${k('const')} ${t('DamolaApp')}());`],
    [''],
    [`${k('class')} ${t('DamolaApp')} ${k('extends')} ${t('StatelessWidget')} {`],
    [`  ${k('const')} ${t('DamolaApp')}({${k('super')}.key});`],
    [''],
    [`  ${c('@override')}`],
    [`  ${t('Widget')} build(${t('BuildContext')} context) {`],
    [`    ${k('return')} ${t('Engineer')}(`],
    [`      ${p('name')}: ${v('name')},`, 'name'],
    [`      ${p('role')}: ${v('role')},`, 'role'],
    [`      ${p('specialty')}: ${v('specialty')},`, 'role'],
    [`      ${p('basedIn')}: ${v('basedIn')},`, 'status'],
    [`      ${p('status')}: ${t('Status')}.${v('status')},`, 'status'],
    [`      ${p('ships')}: ${v('ships')},`, 'platforms'],
    [`      ${p('theme')}: ${t('AppTheme')}.${v('theme')},  ${c('// try me')}`, 'page'],
    [`      ${p('stats')}: kResumeStats,  ${c('// all from my resume')}`, 'stats'],
    [`      ${p('home')}: ${k('const')} ${t('Portfolio')}(),`, 'cta'],
    [`    );`],
    [`  }`],
    [`}`],
  ]},
  'work.dart': { section: 'work', crumb: 'lib › <b>work.dart</b> › projects', lines: () => [
    [c('// The real apps belong to the companies I built them for.')],
    [c('// These are working versions, rebuilt from scratch on mock data.')],
    [''],
    [`${k('final')} projects = <${t('Project')}>[`],
    [`  ${t('FieldAgentApp')}(`, 'project-field'],
    [`    ${p('client')}: ${s('NeoCash')},`, 'project-field'],
    [`    ${p('commits')}: (${n(360)}, of: ${n(448)}),  ${c('// main contributor')}`, 'project-field'],
    [`    ${p('airplaneMode')}: ${v('airplane')},`, 'project-field'],
    [`    ${p('demo')}: ${t('Demo')}.offlineSync,`, 'project-field'],
    [`  ),`, 'project-field'],
    [`  ${t('LoanApp')}(`, 'project-loan'],
    [`    ${p('stores')}: [${t('Store')}.play, ${t('Store')}.appStore],`, 'project-loan'],
    [`    ${p('retention')}: ${n('+0.15')},`, 'project-loan'],
    [`    ${p('demo')}: ${t('Demo')}.${v('loanDemo')},`, 'project-loan'],
    [`  ),`, 'project-loan'],
    [`  ${t('Ajarra')}(`, 'project-ajarra'],
    [`    ${p('commits')}: (${n(694)}, of: ${n(707)}),  ${c('// only mobile engineer')}`, 'project-ajarra'],
    [`    ${p('demo')}: ${t('Demo')}.${v('ajarraDemo')},`, 'project-ajarra'],
    [`  ),`, 'project-ajarra'],
    [`];`],
  ]},
  'career.log': { section: 'career', crumb: '<b>git log</b> --career --oneline', lines: () => CAREER.map(([hash, title, co, , , ref]) =>
    [`<span class="nu">${hash}</span> ${ref ? `<span class="ty">(${ref})</span> ` : ''}${title}${co ? ` <span class="kw">@</span> ${co}` : ''}`, `role-${hash}`]
  ).concat([[''], [c('# newest first · dates match LinkedIn')]]) },
  'writing.dart': { section: 'writing', crumb: 'lib › <b>writing.dart</b>', lines: () => [
    [`${k('final')} writing = ${t('Blog')}(`],
    [`  ${p('technical')}: ${t('Hashnode')}(${s('daily-flutters')}),  ${c('// 27 posts')}`, 'posts'],
    [`  ${p('crossPosted')}: ${t('CoderLegion')}(${s('damolanelson')}),`, 'posts'],
    [`  ${p('sort')}: ${t('Sort')}.${v('sort')},`, 'posts'],
    [`  ${p('offTheClock')}: ${t('Medium')}(${s('@damola_nelson')}),  ${c('// essays, not code')}`, 'essays'],
    [`);`],
  ]},
  'after_hours.dart': { section: 'afterhours', crumb: 'lib › <b>after_hours.dart</b>', lines: () => [
    [`${k('final')} afterHours = ${t('AfterHours')}(`],
    [`  ${p('learning')}: ${t('Learning')}.${v('learning')},`, 'tile-learning'],
    [`  ${p('chess')}: ${t('ChessCom')}(${s('ay0dam0la')}, ${p('showLastWin')}: ${v('lastWin')}),`, 'tile-chess'],
    [`  ${p('music')}: ${t('Spotify')}(${p('autoplay')}: ${v('autoplay')}),`, 'tile-music'],
    [`  ${p('club')}: ${t('Club')}.${v('club')},  ${c('// final')}`, 'tile-club'],
    [`);`],
  ]},
  'contact.sh': { section: 'contact', crumb: '<b>contact.sh</b>', lines: () => [
    [c('# say hello')],
    [`<span class="kw">open</span> ${s('mailto:damolanelson@gmail.com')}`, 'email'],
    [`<span class="kw">open</span> ${s('https://github.com/damooola')}`],
    [`<span class="kw">open</span> ${s('https://linkedin.com/in/damola-owonifari')}`],
    [`<span class="kw">open</span> resume.pdf`],
  ]},
};
const FILE_ORDER = Object.keys(FILES);
const FILE_FOR_SECTION = Object.fromEntries(FILE_ORDER.map((f) => [FILES[f].section, f]));

const TREE = [
  ['DamolaApp', 0, 'home', null],
  ['Home', 1, 'home', null],
  ['Work', 1, 'work', null],
  ['FieldAgentApp', 2, 'work', 'project-field'],
  ['LoanApp', 2, 'work', 'project-loan'],
  ['Ajarra', 2, 'work', 'project-ajarra'],
  ['Career', 1, 'career', null],
  ['Writing', 1, 'writing', null],
  ['Hashnode', 2, 'writing', 'posts'],
  ['Medium', 2, 'writing', 'essays'],
  ['AfterHours', 1, 'afterhours', null],
  ['Contact', 1, 'contact', null],
];

// ── DOM helpers ───────────────────────────────────────────────────────────

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => [...document.querySelectorAll(sel)];
const ide = $('#ide');
const scroller = $('#scroller');
const page = $('#page');
const phone = () => window.matchMedia('(max-width: 860px)').matches;
let currentFile = 'main.dart';

// ── Render: code ──────────────────────────────────────────────────────────

function codeHtml(file) {
  return FILES[file].lines().map(([html, target], i) =>
    `<div class="line"${target ? ` data-target="${target}"` : ''}><span class="n">${i + 1}</span><span>${html || ' '}</span></div>`
  ).join('');
}

function renderTabs() {
  $('#tabs').innerHTML = FILE_ORDER.map((f) => {
    const kind = f.endsWith('.log') ? 'log' : f.endsWith('.sh') ? 'sh' : '';
    return `<button class="tab${f === currentFile ? ' on' : ''}" data-file="${f}"><span class="ic ${kind}"></span>${f}</button>`;
  }).join('');
}

function renderCode(changedKey) {
  $('#code').innerHTML = codeHtml(currentFile);
  $('#crumbs').innerHTML = FILES[currentFile].crumb;
  $('#sheetCode').innerHTML = codeHtml(currentFile);
  $('#sheetFile').textContent = currentFile;
  if (changedKey) {
    $$(`[data-k="${changedKey}"]`).forEach((el) => el.closest('.line')?.classList.add('changed'));
  }
}

function openFile(file, { scroll = false } = {}) {
  if (!FILES[file]) return;
  currentFile = file;
  renderTabs();
  renderCode();
  if (scroll) jumpTo(FILES[file].section);
}

// ── Render: page ──────────────────────────────────────────────────────────

function renderPage() {
  page.dataset.theme = val('theme');

  const name = val('name');
  $('#nameText').innerHTML = name === 'damooola' ? '@damooola' : 'Damola <em>Nelson</em>';
  $('#roleText').textContent = `${val('role')}.`;
  $('#specialtyText').textContent = SPECIALTY_LINE[val('specialty')];

  const shipping = val('status') === 'shipping';
  const where = val('basedIn');
  $('#statusText').textContent = shipping
    ? `Heads down, shipping · ${where}`
    : `Open to Flutter roles · full time · contract · ${where}`;
  $('[data-id="status"]').classList.toggle('busy', shipping);

  const platforms = val('ships').includes('web') ? ['Android', 'iOS', 'Web'] : ['Android', 'iOS'];
  $('#platformChips').innerHTML = `Ships to ${platforms.map((x) => `<b>${x}</b>`).join('')}`;

  $('#stats').innerHTML = STATS.map(([big, small]) => `<div class="stat"><b>${big}</b><span>${small}</span></div>`).join('');

  $('#projects').innerHTML = PROJECTS.map((pr, i) => {
    const key = pr.id === 'loan' ? 'loanDemo' : pr.id === 'ajarra' ? 'ajarraDemo' : null;
    const active = key ? val(key) : pr.demos[0][0];
    const demo = pr.demos.find((d) => d[0] === active);
    const offline = pr.id === 'field' && val('airplane') === 'true';
    return `
      <article class="project" id="project-${pr.id}" data-id="project-${pr.id}" data-widget="${pr.cls}()">
        <div>
          <div class="p-meta">0${i + 1} · ${pr.client} · ${pr.years}</div>
          <h3>${pr.name}</h3>
          <p>${pr.blurb}</p>
          <p class="real">${pr.real}</p>
          <div class="tags">${pr.stack.map((x) => `<span>${x}</span>`).join('')}</div>
          ${pr.demos.length > 1 ? `<div class="demo-tabs">${pr.demos.map(([id, label]) =>
            `<button type="button" data-demo-key="${key}" data-demo="${id}" class="${id === active ? 'on' : ''}">${label}</button>`).join('')}</div>` : ''}
        </div>
        <div class="device-frame"><div class="island"></div>
          <div class="screen${offline ? ' is-offline' : ''}">
            <div class="offline">✈ Airplane mode</div>
            <div class="rings"></div>
            <div class="demo-name">${demo[1]}</div>
            <div class="demo-desc">${demo[2]}</div>
            <div class="run-pill">▶ live Flutter demo</div>
          </div>
        </div>
      </article>`;
  }).join('');

  $('#timeline').innerHTML = CAREER.map(([hash, title, co, when, body, ref]) => `
    <li id="role-${hash}" data-id="role-${hash}" data-widget="Commit(${hash})" class="${ref && ref.startsWith('tag') ? 'edu' : ''}">
      <div class="hash">${hash}</div>
      <div><div class="head">${title} <span class="at">@ ${co}</span></div><div class="when">${when}</div>${body ? `<p>${body}</p>` : ''}</div>
    </li>`).join('');

  const posts = val('sort') === 'newest' ? POSTS : [...POSTS].sort((a, b) => b[5] - a[5]);
  $('#posts').innerHTML = posts.map(([title, date, mins, slug, src]) => `
    <a class="post" href="https://daily-flutters.hashnode.dev/${slug}" target="_blank" rel="noopener">
      <span class="src"><span>${src}</span><span>${date}</span></span>
      <h4>${title}</h4>
      <span class="mins">${mins} min read →</span>
    </a>`).join('');
  $('#posts').dataset.id = 'posts';
  $('#posts').dataset.widget = 'ListView(posts)';

  $('#essays').innerHTML = ESSAYS.map(([title, meta, url, img]) => `
    <a class="essay" href="${url}" target="_blank" rel="noopener">
      <div class="frame"><img src="../../assets/writing/${img}" alt="${title} on Medium"></div>
      <div class="cap">${title}<span>${meta}</span></div>
    </a>`).join('');
  $('#essays').dataset.id = 'essays';
  $('#essays').dataset.widget = 'ListView(essays)';

  const learning = LEARNING[state.learning];
  const playing = val('autoplay') === 'true';
  const lastWin = val('lastWin') === 'true';
  $('#tiles').innerHTML = `
    <div class="tile" data-id="tile-learning" data-widget="LearningTile"><div class="label">Learning<span>${state.learning + 1}/3</span></div>
      <div class="big">${learning[0]}</div><p>${learning[1]}</p></div>
    <div class="tile" data-id="tile-chess" data-widget="ChessTile"><div class="label">Chess.com<i>● live</i></div>
      <div class="big">${lastWin ? 'Last win, replayed' : 'ay0dam0la'}</div>
      <p>${lastWin ? 'The final position of my last win, drawn from the game record.' : 'My current rating and last result, read live.'}</p></div>
    <div class="tile${playing ? ' playing' : ''}" data-id="tile-music" data-widget="PlaylistTile"><div class="label">Spotify<span class="eq"><b></b><b></b><b></b></span></div>
      <div class="big">${playing ? 'Now playing' : 'My playlist'}</div><p>Nine tracks, thirty-second previews, in a player that matches the site.</p></div>
    <div class="tile" data-id="tile-club" data-widget="ClubTile"><div class="label">Chelsea<i>● live</i></div>
      <div class="big">Chelsea FC</div><p>Last result and next fixture, live. Non-negotiable.</p></div>`;
}

// ── Navigation ────────────────────────────────────────────────────────────

function renderTree(active) {
  $('#tree').innerHTML = TREE.map(([label, depth, section, anchor]) => `
    <li data-depth="${depth}" class="${active === (anchor || section) ? 'on' : ''}">
      <button type="button" style="--depth:${depth}" data-section="${section}" data-anchor="${anchor || ''}">
        <span class="node-dot${anchor ? ' leaf' : ''}"></span>${label}${depth === 0 ? '<span class="hint">root</span>' : ''}
      </button>
    </li>`).join('');
}

function renderProps(section) {
  const props = {
    home: [['status', val('status')], ['theme', val('theme')], ['basedIn', val('basedIn')]],
    work: [['projects', '3'], ['demos', '6 live']],
    career: [['commits', String(CAREER.length)], ['since', '2024']],
    writing: [['posts', '27'], ['essays', '3']],
    afterhours: [['tiles', '4'], ['live', 'chess, chelsea']],
    contact: [['reply', 'within a day']],
  }[section] || [];
  $('#props').innerHTML = `<div style="margin-bottom:6px;color:var(--ide-text)">Properties</div>` +
    props.map(([a, b]) => `<div><b>${a}</b>: <span>${b}</span></div>`).join('');
}

function jumpTo(section, anchor) {
  const target = document.getElementById(anchor || section);
  if (!target) return;
  if (phone()) {
    window.scrollTo({ top: target.getBoundingClientRect().top + window.scrollY - 60, behavior: 'smooth' });
  } else {
    scroller.scrollTo({ top: target.offsetTop - 12, behavior: 'smooth' });
  }
}

let activeSection = 'home';
function setActive(section) {
  if (section === activeSection) return;
  activeSection = section;
  renderTree(section);
  renderProps(section);
  $('#urlHash').textContent = section === 'home' ? '' : `/#${section}`;
  const file = FILE_FOR_SECTION[section];
  if (file && file !== currentFile) openFile(file);
}

// ── Hot reload ────────────────────────────────────────────────────────────

const consoleBody = $('#consoleBody');
let consoleMode = 'debug';
const debugLog = [];
function log(cls, html) {
  debugLog.push(`<div class="${cls}">${html}</div>`);
  if (debugLog.length > 60) debugLog.shift();
  if (consoleMode === 'debug') {
    consoleBody.innerHTML = debugLog.join('');
    consoleBody.scrollTop = consoleBody.scrollHeight;
  }
}

let reloads = 0;
function hotReload(changedKey, note) {
  const ms = 160 + Math.round(Math.random() * 160);
  log('', 'Performing hot reload...');
  setTimeout(() => {
    renderPage();
    renderCode(changedKey);
    renderProps(activeSection);
    const flash = $('#flash');
    flash.classList.remove('go'); void flash.offsetWidth; flash.classList.add('go');
    reloads += 1;
    log('ok', `Reloaded ${changedKey ? 1 : 0} of 412 libraries in ${ms}ms (compile: ${Math.round(ms * .3)} ms, reload: ${Math.round(ms * .2)} ms, reassemble: ${Math.round(ms * .5)} ms).`);
    if (note) log('info', `flutter: ${note}`);
  }, 220);
}

function hotRestart() {
  Object.keys(state).forEach((key) => { state[key] = 0; });
  log('', 'Performing hot restart...');
  page.style.transition = 'opacity .25s';
  page.style.opacity = 0;
  setTimeout(() => {
    renderPage();
    renderCode();
    renderProps(activeSection);
    page.style.opacity = 1;
    log('ok', `Restarted application in ${520 + Math.round(Math.random() * 180)}ms.`);
  }, 320);
}

const NOTES = {
  status: () => val('status') === 'shipping' ? 'Heads down. Still answering email.' : 'Open to Flutter roles.',
  theme: () => `Theme set to ${val('theme')}.`,
  airplane: () => val('airplane') === 'true' ? 'Offline. Saves queue on the device.' : 'Back online. Syncing the queue.',
  club: () => 'Club is final. It’s Chelsea.',
  sort: () => `Posts sorted by ${val('sort')}.`,
};

function cycle(key) {
  if (!OPTIONS[key]) return;
  state[key] = (state[key] + 1) % OPTIONS[key].length;
  hotReload(key, NOTES[key]?.());
}

// ── Inspector hover (code ↔ page) ─────────────────────────────────────────

function clearInspect() {
  $$('.inspected').forEach((el) => el.classList.remove('inspected'));
  $$('.line.hl').forEach((el) => el.classList.remove('hl'));
}

function inspectTarget(id) {
  clearInspect();
  if (!id) return;
  const el = id === 'page' ? page : document.querySelector(`[data-id="${id}"]`);
  if (!el) return;
  if (id !== 'page') el.classList.add('inspected');
  if (phone()) return;
  const r = el.getBoundingClientRect();
  const box = scroller.getBoundingClientRect();
  if (r.top < box.top || r.bottom > box.bottom) scroller.scrollTo({ top: el.offsetTop - 80, behavior: 'smooth' });
}

$('#code').addEventListener('mouseover', (e) => inspectTarget(e.target.closest('.line')?.dataset.target));
$('#code').addEventListener('mouseleave', clearInspect);
page.addEventListener('mouseover', (e) => {
  const el = e.target.closest('[data-id]');
  $$('.line.hl').forEach((l) => l.classList.remove('hl'));
  if (el) $$(`#code [data-target="${el.dataset.id}"]`).forEach((l) => l.classList.add('hl'));
});
page.addEventListener('mouseleave', () => $$('.line.hl').forEach((l) => l.classList.remove('hl')));

// ── Events ────────────────────────────────────────────────────────────────

document.addEventListener('click', (e) => {
  const value = e.target.closest('[data-k]');
  if (value) return cycle(value.dataset.k);

  const file = e.target.closest('[data-file]');
  if (file) return openFile(file.dataset.file, { scroll: true });

  const node = e.target.closest('#tree [data-section]');
  if (node) {
    const { section, anchor } = node.dataset;
    renderTree(anchor || section);
    openFile(FILE_FOR_SECTION[section]);
    return jumpTo(section, anchor);
  }

  const demo = e.target.closest('[data-demo]');
  if (demo) {
    state[demo.dataset.demoKey] = OPTIONS[demo.dataset.demoKey].indexOf(demo.dataset.demo);
    return hotReload(demo.dataset.demoKey);
  }

  const jump = e.target.closest('[data-jump]');
  if (jump) { e.preventDefault(); return jumpTo(jump.dataset.jump); }

  const ctl = e.target.closest('[data-action]');
  if (ctl) return ctl.dataset.action === 'reload' ? hotReload(null) : hotRestart();

  const tab = e.target.closest('[data-console]');
  if (tab) {
    consoleMode = tab.dataset.console;
    $$('[data-console]').forEach((b) => b.classList.toggle('on', b === tab));
    consoleBody.innerHTML = consoleMode === 'debug' ? debugLog.join('') : TERMINAL;
    return;
  }

  const copy = e.target.closest('[data-copy]');
  if (copy) {
    navigator.clipboard?.writeText(copy.dataset.copy);
    log('ok', `Copied ${copy.dataset.copy} to the clipboard.`);
  }
});

document.addEventListener('keydown', (e) => {
  if (e.metaKey || e.ctrlKey || e.altKey || e.target.closest('input, textarea')) return;
  if (e.key === 'r') hotReload(null);
  if (e.key === 'R') hotRestart();
});

$('#readToggle').addEventListener('click', (e) => {
  const on = ide.classList.toggle('reading');
  e.currentTarget.setAttribute('aria-pressed', String(on));
  log('info', on ? 'Reading mode: code hidden.' : 'Code visible again. Hover any line to inspect it.');
});

// Phone: the source slides up in a sheet.
const sheet = $('#sheet');
$('#sourceBtn').addEventListener('click', () => { sheet.classList.add('open'); sheet.setAttribute('aria-hidden', 'false'); });
$('#sheetClose').addEventListener('click', () => { sheet.classList.remove('open'); sheet.setAttribute('aria-hidden', 'true'); });

const TERMINAL = `
  <div><span class="prompt">damola@lagos</span> ~ $ <span class="cmd" data-copy="damolanelson@gmail.com">copy email</span></div>
  <div><span class="prompt">damola@lagos</span> ~ $ <a href="mailto:damolanelson@gmail.com">mail damolanelson@gmail.com</a></div>
  <div><span class="prompt">damola@lagos</span> ~ $ <a href="../../assets/resume.pdf" target="_blank" rel="noopener">open resume.pdf</a></div>
  <div><span class="prompt">damola@lagos</span> ~ $ <a href="https://github.com/damooola" target="_blank" rel="noopener">open github.com/damooola</a></div>
  <div><span class="prompt">damola@lagos</span> ~ $ <a href="https://www.linkedin.com/in/damola-owonifari" target="_blank" rel="noopener">open linkedin</a></div>`;

// Keep the tree, tab and URL in step with what's on screen.
const observer = new IntersectionObserver((entries) => {
  const visible = entries.filter((x) => x.isIntersecting).sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
  if (visible) setActive(visible.target.dataset.section);
}, { root: phone() ? null : scroller, threshold: [0.25, 0.5] });

// ── Boot ──────────────────────────────────────────────────────────────────

renderTabs();
renderCode();
renderPage();
activeSection = '';
setActive('home');
$$('[data-section]').filter((el) => el.tagName === 'SECTION').forEach((el) => observer.observe(el));

const size = () => { $('#previewSize').textContent = `${Math.round(scroller.clientWidth)} × ${Math.round(scroller.clientHeight)}`; };
size(); window.addEventListener('resize', size);

[
  ['', 'Launching lib/main.dart on Chrome in debug mode...'],
  ['ok', '✓ Built build/web'],
  ['', 'Debug service listening on ws://127.0.0.1:7357'],
  ['info', 'flutter: Hello. Hover any line to see what it builds.'],
  ['info', 'flutter: Click an <span style="color:var(--val)">orange</span> or <span style="color:var(--str)">green</span> value to change it. <kbd>r</kbd> reloads, <kbd>R</kbd> restarts.'],
].forEach(([cls, html], i) => setTimeout(() => log(cls, html), 250 + i * 260));

#!/usr/bin/env node
/**
 * mcp-doctor — diagnostica e repara os MCP servers do Claude Code.
 *
 *   node mcp-doctor.js            diagnostico (handshake MCP real em cada servidor)
 *   node mcp-doctor.js --fix      repara: reinstala pacotes globais faltando e
 *                                 reaplica o patch do plugin firebase
 *   node mcp-doctor.js --quiet    so imprime se achar problema (uso em hook)
 *
 * Motivo de existir: servidores declarados como `npx pacote@latest` consultam o
 * registry npm a cada sessao e estouram o timeout de conexao. Este script garante
 * que todos apontem para binarios instalados localmente e que esses binarios existam.
 */

const fs = require('fs');
const path = require('path');
const { spawn, execFileSync } = require('child_process');

const HOME = process.env.USERPROFILE || process.env.HOME;
const CLAUDE_JSON = path.join(HOME, '.claude.json');
const NM = path.join(HOME, 'AppData', 'Roaming', 'npm', 'node_modules');
const PLUGINS = path.join(HOME, '.claude', 'plugins', 'cache');

const args = process.argv.slice(2);
const FIX = args.includes('--fix');
const QUIET = args.includes('--quiet');

/** Pacotes globais que precisam existir, com o caminho do entrypoint relativo ao node_modules global. */
const REQUIRED = {
  'chrome-devtools-mcp': 'chrome-devtools-mcp/build/src/bin/chrome-devtools-mcp.js',
  '@playwright/mcp': '@playwright/mcp/cli.js',
  'obsidian-mcp': 'obsidian-mcp/dist/main.js',
  'n8n-mcp': 'n8n-mcp/dist/mcp/stdio-wrapper.js',
  '@kaptionai/mcp-extension': '@kaptionai/mcp-extension/dist/index.js',
  'firebase-tools': 'firebase-tools/lib/bin/firebase.js',
  shadcn: 'shadcn/dist/index.js',
};

/** Config que o plugin firebase deve ter. O plugin volta pro `npx @latest` quando atualiza. */
const FIREBASE_MCP = {
  mcpServers: {
    firebase: {
      command: 'node',
      args: [path.join(NM, 'firebase-tools', 'lib', 'bin', 'firebase.js'), 'mcp', '--dir', '.'],
      env: { IS_FIREBASE_MCP: 'true' },
    },
  },
};

const problems = [];   // pendentes, exigem acao
const repaired = [];   // corrigidos nesta execucao
const log = (...a) => { if (!QUIET) console.log(...a); };

/** Move um problema ja resolvido de `problems` para `repaired`. */
const markRepaired = (msg) => {
  const i = problems.indexOf(msg);
  if (i !== -1) problems.splice(i, 1);
  repaired.push(msg);
};

// ---------------------------------------------------------------- verificacoes

function checkGlobals() {
  const missing = [];
  for (const [pkg, entry] of Object.entries(REQUIRED)) {
    if (!fs.existsSync(path.join(NM, entry))) missing.push(pkg);
  }
  if (missing.length) {
    problems.push(`pacotes globais faltando: ${missing.join(', ')}`);
    // No hook (--quiet) nunca instala: 30s de npm travariam o inicio da sessao.
    if (FIX && !QUIET) {
      log(`  instalando ${missing.join(' ')} ...`);
      execFileSync('npm', ['i', '-g', ...missing], { stdio: 'inherit', shell: true });
    }
  }
  return missing;
}

/** Servidores declarados com `npx` voltam a estourar o timeout. Sinaliza todos. */
function checkNoNpx() {
  const offenders = [];
  const scan = (label, servers) => {
    for (const [name, s] of Object.entries(servers || {})) {
      const cmd = String(s.command || '');
      if (/^npx/i.test(cmd) || (s.args || []).some((a) => String(a).includes('@latest'))) {
        offenders.push(`${label}:${name}`);
      }
    }
  };

  if (fs.existsSync(CLAUDE_JSON)) {
    scan('global', JSON.parse(fs.readFileSync(CLAUDE_JSON, 'utf8')).mcpServers);
  }
  for (const f of findPluginMcpFiles()) {
    scan(path.basename(path.dirname(f)), JSON.parse(fs.readFileSync(f, 'utf8')).mcpServers);
  }

  if (offenders.length) problems.push(`servidores ainda usando npx/@latest: ${offenders.join(', ')}`);
  return offenders;
}

function findPluginMcpFiles() {
  const out = [];
  const walk = (dir, depth) => {
    if (depth > 4 || !fs.existsSync(dir)) return;
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const p = path.join(dir, e.name);
      if (e.isDirectory()) walk(p, depth + 1);
      else if (e.name === '.mcp.json') out.push(p);
    }
  };
  walk(PLUGINS, 0);
  return out;
}

/** O plugin firebase reverte pro npx a cada atualizacao. Reaplica o patch. */
function checkFirebasePlugin() {
  const files = findPluginMcpFiles().filter((f) => f.includes(`${path.sep}firebase${path.sep}`));
  let reverted = false;
  for (const f of files) {
    const cur = JSON.parse(fs.readFileSync(f, 'utf8'));
    if (cur.mcpServers?.firebase?.command !== 'node') {
      reverted = true;
      const msg = `plugin firebase voltou para npx (${f})`;
      problems.push(msg);
      // Reparo de config e instantaneo, entao o hook tambem aplica.
      if (FIX || QUIET) {
        fs.writeFileSync(f, JSON.stringify(FIREBASE_MCP, null, 2) + '\n');
        markRepaired(msg);
        log(`  repatchado: ${f}`);
      }
    }
  }
  return reverted;
}

/**
 * O @playwright/mcp cria um `lockfile` dentro do --user-data-dir e recusa subir com
 * "Browser is already in use" se ele sobrar de um processo morto. Remove o orfao.
 */
function checkPlaywrightLock() {
  if (!fs.existsSync(CLAUDE_JSON)) return;
  const pw = JSON.parse(fs.readFileSync(CLAUDE_JSON, 'utf8')).mcpServers?.playwright;
  const i = (pw?.args || []).indexOf('--user-data-dir');
  if (i === -1) return;

  const profile = pw.args[i + 1];
  const lock = path.join(profile, 'lockfile');
  if (!fs.existsSync(lock)) return;

  // Lock legitimo se algum processo vivo ainda referencia esse perfil.
  let alive = false;
  try {
    const out = execFileSync('powershell', ['-NoProfile', '-Command',
      `(Get-CimInstance Win32_Process -Filter "Name='node.exe' OR Name='chrome.exe'" |` +
      ` Where-Object { $_.CommandLine -like '*${path.basename(profile)}*' } | Measure-Object).Count`,
    ], { encoding: 'utf8', timeout: 15000 });
    alive = Number(String(out).trim()) > 0;
  } catch {
    alive = true; // na duvida, nao mexe
  }

  if (alive) return;
  const msg = `lockfile orfao do playwright em ${profile}`;
  problems.push(msg);
  if (FIX || QUIET) {
    try {
      fs.unlinkSync(lock);
      markRepaired(msg);
      log(`  lockfile orfao removido: ${lock}`);
    } catch (e) {
      log(`  nao consegui remover ${lock}: ${e.message}`);
    }
  }
}

function checkTimeout() {
  const sp = path.join(HOME, '.claude', 'settings.json');
  if (!fs.existsSync(sp)) return;
  const s = JSON.parse(fs.readFileSync(sp, 'utf8'));
  const t = Number(s.env?.MCP_TIMEOUT || 0);
  if (t < 60000) problems.push(`MCP_TIMEOUT baixo ou ausente em settings.json (atual: ${t || 'nao definido'})`);
}

// ------------------------------------------------------- handshake MCP de fato

/**
 * Mata o processo E os filhos dele. No Windows, `child.kill()` so atinge o processo
 * direto: servidores como o @kaptionai/mcp-extension sobem um hub separado que
 * sobrevive e vira orfao. `taskkill /T` derruba a arvore inteira.
 */
function killTree(child) {
  if (!child?.pid) return;
  try {
    if (process.platform === 'win32') {
      execFileSync('taskkill', ['/PID', String(child.pid), '/T', '/F'], { stdio: 'ignore' });
    } else {
      process.kill(-child.pid, 'SIGKILL');
    }
  } catch {
    try { child.kill('SIGKILL'); } catch {}
  }
}

/**
 * Servidores MCP cujo processo pai (a sessao do Claude Code) ja morreu ficam vivos
 * consumindo memoria e, no caso do whatsapp, segurando a porta 7865 do hub.
 */
function checkOrphans() {
  if (process.platform !== 'win32') return;

  // A consulta CIM custa ~1.5s. No hook isso atrasaria toda sessao, e orfaos se
  // acumulam devagar — entao ali roda no maximo de 6 em 6 horas.
  const stamp = path.join(HOME, '.claude', '.mcp-doctor-orphan-check');
  if (QUIET) {
    const last = fs.existsSync(stamp) ? fs.statSync(stamp).mtimeMs : 0;
    if (Date.now() - last < 6 * 60 * 60 * 1000) return;
  }
  try { fs.writeFileSync(stamp, ''); } catch {}

  let rows;
  try {
    const out = execFileSync('powershell', ['-NoProfile', '-Command',
      "$live=@{}; Get-Process -EA SilentlyContinue | %{ $live[$_.Id]=1 };" +
      " Get-CimInstance Win32_Process -Filter \"Name='node.exe'\" |" +
      " ? { $_.CommandLine -match 'chrome-devtools-mcp|@playwright.mcp|obsidian-mcp|n8n-mcp|kaptionai|firebase\\.js mcp|shadcn.dist'" +
      "     -and -not $live[[int]$_.ParentProcessId] } | %{ $_.ProcessId }",
    ], { encoding: 'utf8', timeout: 20000 });
    rows = String(out).trim().split(/\s+/).filter(Boolean);
  } catch {
    return;
  }
  if (!rows.length) return;

  const msg = `${rows.length} processo(s) MCP orfao(s) (pai morto): PID ${rows.join(', ')}`;
  problems.push(msg);
  if (FIX || QUIET) {
    let killed = 0;
    for (const pid of rows) {
      try { execFileSync('taskkill', ['/PID', pid, '/T', '/F'], { stdio: 'ignore' }); killed++; } catch {}
    }
    if (killed === rows.length) markRepaired(msg);
    log(`  ${killed} processo(s) orfao(s) encerrado(s)`);
  }
  return rows;
}

/** Sobe o servidor, manda `initialize` e mede o tempo ate a resposta. */
function handshake(name, cfg, timeoutMs = 60000) {
  return new Promise((resolve) => {
    if (cfg.type === 'http' || cfg.url) return resolve({ name, ms: null, ok: null, note: 'http (nao testado)' });

    const t0 = Date.now();
    let done = false;
    const finish = (ok, note) => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      killTree(child);
      resolve({ name, ms: Date.now() - t0, ok, note });
    };

    let child;
    try {
      child = spawn(cfg.command, cfg.args || [], {
        env: { ...process.env, ...(cfg.env || {}) },
        stdio: ['pipe', 'pipe', 'pipe'],
        shell: process.platform === 'win32' && !/\.(js|exe)$/i.test(cfg.command),
      });
    } catch (e) {
      return resolve({ name, ms: 0, ok: false, note: e.message });
    }

    const timer = setTimeout(() => finish(false, `TIMEOUT >${timeoutMs}ms`), timeoutMs);
    let buf = '';
    child.stdout.on('data', (d) => {
      buf += d.toString();
      // resposta do initialize: primeiro JSON-RPC com id 1
      if (/"id"\s*:\s*1/.test(buf)) finish(true, '');
    });
    child.on('error', (e) => finish(false, e.message));
    child.on('exit', (code) => finish(false, `saiu com codigo ${code}`));

    child.stdin.write(JSON.stringify({
      jsonrpc: '2.0', id: 1, method: 'initialize',
      params: {
        protocolVersion: '2024-11-05',
        capabilities: {},
        clientInfo: { name: 'mcp-doctor', version: '1.0.0' },
      },
    }) + '\n');
  });
}

async function probeAll() {
  const servers = {};
  if (fs.existsSync(CLAUDE_JSON)) {
    Object.assign(servers, JSON.parse(fs.readFileSync(CLAUDE_JSON, 'utf8')).mcpServers || {});
  }
  for (const f of findPluginMcpFiles()) {
    for (const [n, s] of Object.entries(JSON.parse(fs.readFileSync(f, 'utf8')).mcpServers || {})) {
      servers[`plugin:${n}`] = s;
    }
  }

  // Concorrencia limitada: 10 servidores subindo juntos disputam CPU e inflam o
  // tempo medido (firebase ja mediu 31s em paralelo e 1.7s sozinho).
  const entries = Object.entries(servers);
  const results = [];
  const LIMIT = 3;
  for (let i = 0; i < entries.length; i += LIMIT) {
    const lote = entries.slice(i, i + LIMIT);
    results.push(...await Promise.all(lote.map(([n, c]) => handshake(n, c))));
  }
  results.sort((a, b) => (b.ms || 0) - (a.ms || 0));

  log('\n=== handshake MCP ===');
  for (const r of results) {
    const mark = r.ok === null ? ' -- ' : r.ok ? ' OK ' : 'FALHA';
    const slow = r.ms > 25000 ? '  <-- perto do limite padrao de 30s' : '';
    log(`${mark} ${String(r.name).padEnd(24)} ${r.ms === null ? '' : String(r.ms) + 'ms'}${slow} ${r.note}`);
    if (r.ok === false) problems.push(`${r.name}: ${r.note}`);
  }
  return results;
}

// ------------------------------------------------------------------------ main

(async () => {
  const fast = args.includes('--fast') || QUIET;

  checkGlobals();
  checkFirebasePlugin(); // antes do checkNoNpx: repara e ai o scan nao acusa de novo
  checkNoNpx();
  checkOrphans();       // antes do lock: matar o dono libera o lockfile
  checkPlaywrightLock();
  checkTimeout();

  if (!fast) await probeAll();

  if (repaired.length) {
    console.log('\n[mcp-doctor] reparado automaticamente:');
    for (const r of repaired) console.log('  - ' + r);
  }

  if (problems.length) {
    console.log('\n[mcp-doctor] problemas pendentes:');
    for (const p of problems) console.log('  - ' + p);
    if (!FIX) console.log('\n  rode `node ~/.claude/mcp-doctor.js --fix` para reparar');
    // No hook o texto acima vira contexto da sessao; sair 1 so geraria ruido de "hook falhou".
    process.exit(QUIET ? 0 : 1);
  }

  if (!repaired.length) log('\n[mcp-doctor] tudo certo.');
  // exit forcado: servidores sondados deixam processos filhos vivos no Windows
  process.exit(0);
})();

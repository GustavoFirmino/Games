/* Código Secreto — versão web.
   A lógica abaixo é o mesmo algoritmo do GameViewModel.swift do app nativo:
   mesma distribuição, mesma ordem de decisões ao revelar uma carta. */

'use strict';

// ============================================================
// Regras
// ============================================================
const RULES = { columns: 5, rows: 5, size: 25, starting: 9, second: 8, neutral: 7, assassin: 1 };
const other = t => (t === 'red' ? 'blue' : 'red');
const NAME = { red: 'Vermelho', blue: 'Azul' };
const STORE_KEY = 'codigo-secreto/sessao';

function shuffle(arr) {
  // Fisher-Yates: embaralhamento uniforme de verdade.
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

function makeGrid(startingTeam, words) {
  const picked = shuffle([...new Set(words)]).slice(0, RULES.size);
  const types = [];
  for (let i = 0; i < RULES.starting; i++) types.push({ k: 'team', team: startingTeam });
  for (let i = 0; i < RULES.second;   i++) types.push({ k: 'team', team: other(startingTeam) });
  for (let i = 0; i < RULES.neutral;  i++) types.push({ k: 'neutral' });
  for (let i = 0; i < RULES.assassin; i++) types.push({ k: 'assassin' });
  shuffle(types);
  return picked.map((w, i) => ({ id: i, word: w, type: types[i], isRevealed: false }));
}

// ============================================================
// Estado da partida
// ============================================================
class Game {
  constructor(words) {
    this.words = words;
    this.score = { red: 0, blue: 0 };
    this.roundNumber = 1;
    this.startNewRound(false);
  }

  startNewRound(resetScore) {
    if (resetScore) { this.score = { red: 0, blue: 0 }; this.roundNumber = 1; }
    const starter = Math.random() < 0.5 ? 'red' : 'blue';
    this.startingTeam = starter;
    this.currentTeam = starter;
    this.clue = null;
    this.guessesRemaining = 0;
    this.cards = makeGrid(starter, this.words);
    this.phase = { name: 'clueEntry' };
  }

  startNextRound() { this.roundNumber++; this.startNewRound(false); }
  resetEverything() { this.startNewRound(true); }

  get isRoundOver() { return this.phase.name === 'roundOver'; }
  get winner() { return this.phase.winner || null; }

  remaining(team) {
    return this.cards.filter(c => c.type.k === 'team' && c.type.team === team && !c.isRevealed).length;
  }

  submitClue(word, count) {
    const trimmed = (word || '').trim();
    if (!trimmed || this.isRoundOver) return;
    const bounded = Math.min(Math.max(count, 0), this.remaining(this.currentTeam));
    this.clue = { word: trimmed, count: bounded, team: this.currentTeam };
    this.guessesRemaining = bounded + 1;
    this.phase = { name: 'handoff' };
  }

  beginGuessing() { if (this.phase.name === 'handoff') this.phase = { name: 'guessing' }; }

  revealCard(card) {
    if (this.phase.name !== 'guessing' || card.isRevealed) return;
    card.isRevealed = true;
    this.guessesRemaining -= 1;

    if (card.type.k === 'assassin') {
      // Quem tocou perde na hora; o ponto vai para o adversário.
      this.finishRound(other(this.currentTeam), { r: 'assassin', by: this.currentTeam });
    } else if (card.type.k === 'team' && card.type.team === this.currentTeam) {
      if (this.remaining(this.currentTeam) === 0) this.finishRound(this.currentTeam, { r: 'all' });
      else if (this.guessesRemaining <= 0) this.endTurn();
    } else if (card.type.k === 'team') {
      // Revelou carta do adversário — pode até entregar a vitória a ele.
      const owner = card.type.team;
      if (this.remaining(owner) === 0) this.finishRound(owner, { r: 'all' });
      else this.endTurn();
    } else {
      this.endTurn();
    }
  }

  passTurn() { if (this.phase.name === 'guessing') this.endTurn(); }

  endTurn() {
    this.currentTeam = other(this.currentTeam);
    this.clue = null;
    this.guessesRemaining = 0;
    this.phase = { name: 'clueEntry' };
  }

  finishRound(winner, reason) {
    this.score[winner] = (this.score[winner] || 0) + 1;
    this.clue = null;
    this.guessesRemaining = 0;
    this.cards.forEach(c => { c.isRevealed = true; });   // abre o mapa inteiro
    this.phase = { name: 'roundOver', winner, reason };
  }
}

// ============================================================
// Infra
// ============================================================
const $ = sel => document.querySelector(sel);
const phaseEl = $('#phase');

let packs = [];
let selectedPackId = 'padrao';
let game = null;

// Estado só do formulário do mestre-espião (não faz parte da partida).
let clueWord = '';
let clueCount = 1;
let mapUnlocked = false;

function buzz(ms) { if (navigator.vibrate) navigator.vibrate(ms); }

function saveSession() {
  try {
    localStorage.setItem(STORE_KEY, JSON.stringify({
      score: game.score, roundNumber: game.roundNumber, packId: selectedPackId
    }));
  } catch (_) { /* modo privado: seguir sem persistir */ }
}

function loadSession() {
  try { return JSON.parse(localStorage.getItem(STORE_KEY)) || null; }
  catch (_) { return null; }
}

const currentPack = () => packs.find(p => p.id === selectedPackId) || packs[0];

// ============================================================
// Render
// ============================================================
function render() {
  const t = game.isRoundOver ? game.winner : game.currentTeam;
  const tc = `var(--team-${t})`;
  $('#app').style.setProperty('--tc', tc);
  $('#app').style.setProperty('--phase-tint',
    `linear-gradient(to bottom, color-mix(in srgb, ${tc} 14%, transparent), transparent 45%)`);

  renderScoreboard();

  const map = {
    clueEntry: renderClueEntry,
    handoff: renderHandoff,
    guessing: renderGuessing,
    roundOver: renderRoundOver
  };
  phaseEl.innerHTML = '';
  phaseEl.appendChild(map[game.phase.name]());
}

function renderScoreboard() {
  $('#score-red').textContent = game.score.red;
  $('#score-blue').textContent = game.score.blue;
  $('#rem-red').textContent = `${game.remaining('red')} restam`;
  $('#rem-blue').textContent = `${game.remaining('blue')} restam`;
  $('#round-n').textContent = game.roundNumber;
  document.querySelectorAll('.team-panel').forEach(el => {
    const isActive = !game.isRoundOver && el.dataset.team === game.currentTeam;
    el.classList.toggle('active', isActive);
  });
}

/** @param showsSecret revela as cores mesmo sem a carta estar virada (mestre-espião) */
function buildBoard(showsSecret, interactive) {
  const board = document.createElement('div');
  board.className = 'board';

  for (const card of game.cards) {
    const btn = document.createElement('button');
    btn.className = 'card';
    btn.disabled = !interactive || card.isRevealed;

    const kind = card.type.k === 'team' ? card.type.team : card.type.k;

    if (card.isRevealed) {
      btn.classList.add('revealed', `t-${kind}`);
      if (card.type.k === 'assassin') {
        const b = document.createElement('span');
        b.textContent = '💥';
        btn.appendChild(b);
      }
    } else if (showsSecret) {
      btn.classList.add(`hint-${kind}`);
    }

    const w = document.createElement('span');
    w.textContent = card.word;
    btn.appendChild(w);

    if (showsSecret && !card.isRevealed) {
      const stripe = document.createElement('span');
      stripe.className = 'stripe';
      stripe.style.background = kind === 'neutral' ? 'var(--neutral)'
        : kind === 'assassin' ? 'var(--assassin)' : `var(--team-${kind})`;
      btn.appendChild(stripe);
    }

    if (interactive) {
      btn.addEventListener('click', () => {
        buzz(10);
        game.revealCard(card);
        if (game.isRoundOver) { buzz([40, 60, 40]); saveSession(); }
        render();
      });
    }
    board.appendChild(btn);
  }
  return board;
}

function el(tag, cls, text) {
  const e = document.createElement(tag);
  if (cls) e.className = cls;
  if (text != null) e.textContent = text;
  return e;
}

// ---------- fase 1: mestre-espião ----------
function renderClueEntry() {
  const team = game.currentTeam;
  const wrap = el('div', 'phase-wrap');

  const head = el('div', 'header-block');
  head.append(
    el('div', 'eyebrow', 'MESTRE-ESPIÃO'),
    el('div', 'title-team', `Time ${NAME[team]}`),
    el('div', 'subtle', `Faltam ${game.remaining(team)} agentes seus`)
  );

  const stack = el('div', 'board-stack');
  const board = buildBoard(mapUnlocked, false);
  if (!mapUnlocked) board.classList.add('blurred');
  stack.appendChild(board);

  if (!mapUnlocked) {
    const ov = el('div', 'locked-overlay');
    ov.append(
      el('div', 'big', '🙈'),
      el('div', 'l1', 'Mapa secreto oculto'),
      el('div', 'l2', 'Segure o botão abaixo para revelar')
    );
    stack.appendChild(ov);
  }

  // Precisa manter o dedo pressionado: soltou, o mapa some.
  // É o que impede os operativos de verem o mapa por descuido.
  const hold = el('button', 'btn btn-dark hold-btn');
  hold.textContent = mapUnlocked ? '👁 Solte para ocultar' : '👆 Segure para ver o mapa';
  hold.classList.toggle('on', mapUnlocked);
  const show = ev => { ev.preventDefault(); if (!mapUnlocked) { mapUnlocked = true; buzz(15); render(); } };
  const hide = ev => { ev.preventDefault(); if (mapUnlocked) { mapUnlocked = false; render(); } };
  hold.addEventListener('pointerdown', show);
  hold.addEventListener('pointerup', hide);
  hold.addEventListener('pointercancel', hide);
  hold.addEventListener('pointerleave', hide);
  hold.addEventListener('contextmenu', e => e.preventDefault());

  // formulário da dica
  const form = el('div', 'clue-form');

  const input = el('input', 'input-word');
  input.type = 'text';
  input.placeholder = 'Palavra da dica';
  input.value = clueWord;
  input.autocomplete = 'off';
  input.autocapitalize = 'characters';
  input.spellcheck = false;
  input.addEventListener('input', () => {
    clueWord = input.value;
    submit.disabled = clueWord.trim() === '';
  });

  const maxCount = Math.max(game.remaining(team), 1);
  clueCount = Math.min(clueCount, maxCount);

  const stepper = el('div', 'stepper-row');
  const minus = el('button', 'step-btn', '−');
  const val = el('span', 'step-val', String(clueCount));
  const plus = el('button', 'step-btn', '+');
  minus.addEventListener('click', () => { clueCount = Math.max(0, clueCount - 1); val.textContent = clueCount; });
  plus.addEventListener('click', () => { clueCount = Math.min(maxCount, clueCount + 1); val.textContent = clueCount; });
  stepper.append(el('span', 'lbl', 'Quantidade'), minus, val, plus);

  const submit = el('button', 'btn btn-primary', 'Registrar dica');
  submit.disabled = clueWord.trim() === '';
  submit.addEventListener('click', () => {
    buzz(15);
    game.submitClue(clueWord, clueCount);
    clueWord = ''; clueCount = 1; mapUnlocked = false;
    render();
  });

  form.append(input, stepper, submit);
  wrap.append(head, stack, hold, form);
  return wrap;
}

// ---------- fase 2: cortina ----------
function renderHandoff() {
  const team = game.currentTeam;
  const wrap = el('div', 'handoff');
  wrap.append(
    el('div', 'icon', '📱'),
    el('div', 'h1', 'Passe o dispositivo'),
    el('div', 'h2', `Operativos do time ${NAME[team]}`),
    el('div', 'h3', 'O mestre-espião já registrou a dica. Toque abaixo quando estiver com o time certo em mãos.')
  );
  const go = el('button', 'btn btn-primary', '👁 Ver a dica');
  go.addEventListener('click', () => { buzz(15); game.beginGuessing(); render(); });
  wrap.appendChild(go);
  return wrap;
}

// ---------- fase 3: operativos ----------
function renderGuessing() {
  const wrap = el('div', 'phase-wrap');

  const banner = el('div', 'clue-banner');
  const pills = el('div', 'pills');
  pills.append(
    el('span', 'pill', `${game.clue.count} cartas`),
    el('span', 'pill', `${Math.max(game.guessesRemaining, 0)} palpites`)
  );
  banner.append(
    el('div', 'eyebrow', 'DICA DO MESTRE-ESPIÃO'),
    el('div', 'clue-word', game.clue.word.toUpperCase()),
    pills
  );

  const pass = el('button', 'btn btn-soft', '🏳 Encerrar turno');
  pass.addEventListener('click', () => { buzz(10); game.passTurn(); render(); });

  wrap.append(banner, buildBoard(false, true), pass);
  return wrap;
}

// ---------- fase 4: fim de rodada ----------
function renderRoundOver() {
  const { winner, reason } = game.phase;
  const wrap = el('div', 'phase-wrap');

  const banner = el('div', 'result-banner');
  const why = reason.r === 'assassin'
    ? `O time ${NAME[reason.by]} acionou a bomba. Fim de jogo.`
    : `O time ${NAME[winner]} encontrou todos os seus agentes.`;
  banner.append(
    el('div', 'emoji', reason.r === 'assassin' ? '💥' : '🏆'),
    el('div', 'who', `Time ${NAME[winner]} venceu`),
    el('div', 'why', why)
  );

  const row = el('div', 'row-2');
  const next = el('button', 'btn btn-primary', 'Próxima rodada');
  next.addEventListener('click', () => { game.startNextRound(); saveSession(); render(); });
  const reset = el('button', 'btn btn-soft narrow', '↺');
  reset.title = 'Zerar placar';
  reset.addEventListener('click', () => { game.resetEverything(); saveSession(); render(); });
  row.append(next, reset);

  wrap.append(banner, buildBoard(true, false), row);
  return wrap;
}

// ============================================================
// Ajustes
// ============================================================
function setupSettings() {
  const dlg = $('#settings');
  const select = $('#pack-select');

  select.innerHTML = '';
  for (const p of packs) {
    const o = document.createElement('option');
    o.value = p.id;
    o.textContent = `${p.emoji}  ${p.name} · ${p.words.length}`;
    select.appendChild(o);
  }
  select.value = selectedPackId;

  select.addEventListener('change', () => {
    selectedPackId = select.value;
    game.words = currentPack().words;   // vale a partir da próxima rodada
    saveSession();
  });

  $('#btn-settings').addEventListener('click', () => dlg.showModal());
  $('#btn-next-round').addEventListener('click', () => {
    game.startNextRound(); saveSession(); render(); dlg.close();
  });
  $('#btn-reset').addEventListener('click', () => {
    if (confirm('Zerar o placar e começar uma partida nova?')) {
      game.resetEverything(); saveSession(); render(); dlg.close();
    }
  });
}

// ============================================================
// Boot
// ============================================================
async function boot() {
  try {
    const res = await fetch('./words.json');
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const file = await res.json();
    // Só pacotes com palavras suficientes para formar uma grade.
    packs = file.packs.filter(p => p.words.length >= RULES.size);
    if (!packs.length) throw new Error('nenhum pacote jogável');
  } catch (e) {
    phaseEl.innerHTML =
      `<div class="header-block"><div class="title-team">Erro ao carregar</div>` +
      `<div class="subtle">Não consegui ler o banco de palavras (${e.message}).</div></div>`;
    return;
  }

  const saved = loadSession();
  if (saved && packs.some(p => p.id === saved.packId)) selectedPackId = saved.packId;

  game = new Game(currentPack().words);
  if (saved && saved.score) {
    game.score = { red: saved.score.red | 0, blue: saved.score.blue | 0 };
    game.roundNumber = saved.roundNumber || 1;
  }

  setupSettings();
  render();

  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('./sw.js').catch(() => { /* offline é opcional */ });
  }
}

boot();

/* Gera os PNGs do ícone sem depender de nenhuma biblioteca.
   Uso:  node gerar-icones.mjs
   O desenho é uma mini-grade 5x5 com as cores dos times. */

import { deflateSync } from 'node:zlib';
import { writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const AQUI = dirname(fileURLToPath(import.meta.url));

const BG       = [0x11, 0x11, 0x14];
const CORES = {
  r: [0xE6, 0x5A, 0x60],   // vermelho
  b: [0x54, 0x94, 0xEB],   // azul
  n: [0x8B, 0x82, 0x74],   // neutra
  a: [0x00, 0x00, 0x00],   // bomba
};

// Layout fixo: 9 vermelhas, 8 azuis, 7 neutras, 1 bomba — a distribuição do jogo.
const GRADE = [
  'r b n r b',
  'b r r n r',
  'n a b r n',
  'r b n b r',
  'b n r n b',
].map(l => l.split(' '));

function crc32(buf) {
  let c, tabela = [];
  for (let n = 0; n < 256; n++) {
    c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
    tabela[n] = c >>> 0;
  }
  let crc = 0xFFFFFFFF;
  for (const byte of buf) crc = tabela[(crc ^ byte) & 0xFF] ^ (crc >>> 8);
  return (crc ^ 0xFFFFFFFF) >>> 0;
}

function chunk(tipo, dados) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(dados.length);
  const corpo = Buffer.concat([Buffer.from(tipo, 'ascii'), dados]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(corpo));
  return Buffer.concat([len, corpo, crc]);
}

function png(largura, altura, rgba) {
  const assinatura = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(largura, 0);
  ihdr.writeUInt32BE(altura, 4);
  ihdr[8] = 8;    // bits por canal
  ihdr[9] = 6;    // RGBA
  // 10,11,12 = compressão/filtro/entrelaçamento padrão (0)

  // Cada linha começa com o byte de filtro (0 = nenhum).
  const bruto = Buffer.alloc(altura * (1 + largura * 4));
  for (let y = 0; y < altura; y++) {
    const destino = y * (1 + largura * 4);
    bruto[destino] = 0;
    rgba.copy(bruto, destino + 1, y * largura * 4, (y + 1) * largura * 4);
  }

  return Buffer.concat([
    assinatura,
    chunk('IHDR', ihdr),
    chunk('IDAT', deflateSync(bruto, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function desenhar(tamanho, { margemSegura = 0.14 } = {}) {
  const px = Buffer.alloc(tamanho * tamanho * 4);
  const set = (x, y, [r, g, b]) => {
    const i = (y * tamanho + x) * 4;
    px[i] = r; px[i + 1] = g; px[i + 2] = b; px[i + 3] = 255;
  };

  for (let y = 0; y < tamanho; y++)
    for (let x = 0; x < tamanho; x++) set(x, y, BG);

  // Área útil, respeitando a zona segura de ícone maskable.
  const margem = Math.round(tamanho * margemSegura);
  const util = tamanho - margem * 2;
  const espaco = Math.max(2, Math.round(util * 0.022));
  const carta = (util - espaco * 4) / 5;
  const raio = Math.max(2, Math.round(carta * 0.18));

  for (let linha = 0; linha < 5; linha++) {
    for (let col = 0; col < 5; col++) {
      const cor = CORES[GRADE[linha][col]];
      const x0 = margem + Math.round(col * (carta + espaco));
      const y0 = margem + Math.round(linha * (carta + espaco));
      const larg = Math.round(carta);
      const alt = Math.round(carta * 0.78);

      for (let y = 0; y < alt; y++) {
        for (let x = 0; x < larg; x++) {
          // cantos arredondados
          const dx = Math.min(x, larg - 1 - x);
          const dy = Math.min(y, alt - 1 - y);
          if (dx < raio && dy < raio) {
            const d = Math.hypot(raio - dx, raio - dy);
            if (d > raio) continue;
          }
          const px_ = x0 + x, py_ = y0 + y;
          if (px_ >= 0 && px_ < tamanho && py_ >= 0 && py_ < tamanho) set(px_, py_, cor);
        }
      }
    }
  }
  return png(tamanho, tamanho, px);
}

for (const [arquivo, tamanho] of [
  ['icon-192.png', 192],
  ['icon-512.png', 512],
  ['apple-touch-icon-180.png', 180],
]) {
  const buf = desenhar(tamanho);
  writeFileSync(join(AQUI, arquivo), buf);
  console.log(`${arquivo}  ${tamanho}x${tamanho}  ${(buf.length / 1024).toFixed(1)} KB`);
}

#!/usr/bin/env node
// Generate multilingual time-telling audio files using Edge TTS
// Usage: node generate_time_audio.mjs --lang it [--all]

import { execSync } from 'child_process';
import { mkdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { createRequire } from 'module';

const require = createRequire('/Users/riccardo/git/openclaw/package.json');
const { EdgeTTS } = require('node-edge-tts');

const __dirname = dirname(fileURLToPath(import.meta.url));
const ASSETS_DIR = join(__dirname, '..', 'assets', 'audio');

// ─── Voice config per language ───
const VOICES = {
  french:  { voice: 'fr-FR-DeniseNeural',   lang: 'fr-FR' },
  italian: { voice: 'it-IT-ElsaNeural',     lang: 'it-IT' },
  german:  { voice: 'de-DE-KatjaNeural',    lang: 'de-DE' },
  english: { voice: 'en-GB-SoniaNeural',    lang: 'en-GB' },
};

// ─── French phrases ───
const FRENCH = (() => {
  const H = {
    0:'minuit', 1:'une heure', 2:'deux heures', 3:'trois heures',
    4:'quatre heures', 5:'cinq heures', 6:'six heures', 7:'sept heures',
    8:'huit heures', 9:'neuf heures', 10:'dix heures', 11:'onze heures', 12:'midi'
  };
  const next = h => { if (h===11) return 'midi'; if (h===12||h===0) return 'une heure'; return H[(h+1)%13]; };
  return buildPhrases(H, next, (h,m,hName) => `Il est ${hName}`, {
    q_frac:  (h,hN) => `Il est ${hN} et quart`,
    q_num:   (h,hN) => `Il est ${hN} quinze`,
    half_frac:(h,hN) => `Il est ${hN} et demie`,
    half_num: (h,hN) => `Il est ${hN} trente`,
    t_num:   (h,hN) => `Il est ${hN} quarante-cinq`,
    t_frac:  (h,hN,nH) => `Il est ${nH} moins le quart`,
    t_minus: (h,hN,nH) => `Il est ${nH} moins quinze`,
  });
})();

// ─── Italian phrases ───
const ITALIAN = (() => {
  // "È l'una" (singular), "Sono le due/tre/..." (plural), special for 0 and 12
  const H = {
    0:'mezzanotte', 1:'una', 2:'due', 3:'tre', 4:'quattro', 5:'cinque',
    6:'sei', 7:'sette', 8:'otto', 9:'nove', 10:'dieci', 11:'undici', 12:'mezzogiorno'
  };
  const prefix = h => (h===0||h===1||h===12) ? 'È' : 'Sono';
  const hourFull = h => {
    if (h===0) return 'mezzanotte';
    if (h===12) return 'mezzogiorno';
    if (h===1) return "l'una";
    return `le ${H[h]}`;
  };
  const nextHourFull = h => {
    if (h===11) return 'mezzogiorno';
    if (h===12||h===0) return "l'una";
    return `le ${H[(h+1)%13]}`;
  };
  const nextPrefix = h => {
    const nh = (h+1)%13; if (nh===0) nh === 13;
    return (nh===1||nh===12||nh===0) ? 'È' : 'Sono';
  };

  const entries = [];
  for (let h = 0; h <= 12; h++) {
    const hh = String(h).padStart(2,'0');
    const pf = prefix(h);
    const hF = hourFull(h);
    const nF = nextHourFull(h);
    const np = (h===11) ? 'È' : ((h===12||h===0) ? 'È' : 'Sono');

    // :00
    entries.push({ file:`${hh}_00.mp3`, text:`${pf} ${hF}` });
    // :15
    entries.push({ file:`${hh}_15_frac.mp3`, text:`${pf} ${hF} e un quarto` });
    entries.push({ file:`${hh}_15_num.mp3`,  text:`${pf} ${hF} e quindici` });
    // :30 — "e mezza" for hours, "e mezzo" for mezzogiorno/mezzanotte
    const mezzo = (h===0||h===12) ? 'e mezzo' : 'e mezza';
    entries.push({ file:`${hh}_30_frac.mp3`, text:`${pf} ${hF} ${mezzo}` });
    entries.push({ file:`${hh}_30_num.mp3`,  text:`${pf} ${hF} e trenta` });
    // :45
    entries.push({ file:`${hh}_45_num.mp3`,   text:`${pf} ${hF} e quarantacinque` });
    entries.push({ file:`${hh}_45_frac.mp3`,  text:`${np} ${nF} meno un quarto` });
    entries.push({ file:`${hh}_45_minus.mp3`, text:`${np} ${nF} meno quindici` });
  }
  return entries;
})();

// ─── German phrases ───
const GERMAN = (() => {
  const H = {
    0:'Mitternacht', 1:'eins', 2:'zwei', 3:'drei', 4:'vier', 5:'fünf',
    6:'sechs', 7:'sieben', 8:'acht', 9:'neun', 10:'zehn', 11:'elf', 12:'Mittag'
  };
  // German hour for "Es ist X Uhr" — "ein Uhr" not "eins Uhr"
  const uhr = h => { if (h===0) return 'Mitternacht'; if (h===12) return 'zwölf Uhr'; if (h===1) return 'ein Uhr'; return `${H[h]} Uhr`; };
  const nextH = h => { if (h===11) return 'zwölf'; if (h===12||h===0) return 'eins'; return H[(h+1)%13]; };

  const entries = [];
  for (let h = 0; h <= 12; h++) {
    const hh = String(h).padStart(2,'0');
    const u = uhr(h);
    const nH = nextH(h);
    // :00
    entries.push({ file:`${hh}_00.mp3`, text:`Es ist ${u}` });
    // :15 — "Viertel nach eins" or "eins Uhr fünfzehn"
    entries.push({ file:`${hh}_15_frac.mp3`, text:`Es ist Viertel nach ${H[h]||'zwölf'}` });
    entries.push({ file:`${hh}_15_num.mp3`,  text:`Es ist ${u} fünfzehn` });
    // :30 — "halb zwei" (half towards next hour!) or "eins Uhr dreißig"
    entries.push({ file:`${hh}_30_frac.mp3`, text:`Es ist halb ${nH}` });
    entries.push({ file:`${hh}_30_num.mp3`,  text:`Es ist ${u} dreißig` });
    // :45 — "Viertel vor zwei", "eins Uhr fünfundvierzig", "dreiviertel zwei"
    entries.push({ file:`${hh}_45_num.mp3`,   text:`Es ist ${u} fünfundvierzig` });
    entries.push({ file:`${hh}_45_frac.mp3`,  text:`Es ist Viertel vor ${nH}` });
    entries.push({ file:`${hh}_45_minus.mp3`, text:`Es ist dreiviertel ${nH}` });
  }
  return entries;
})();

// ─── English phrases ───
const ENGLISH = (() => {
  const H = {
    0:'midnight', 1:'one', 2:'two', 3:'three', 4:'four', 5:'five',
    6:'six', 7:'seven', 8:'eight', 9:'nine', 10:'ten', 11:'eleven', 12:'noon'
  };
  const oclock = h => { if(h===0) return 'midnight'; if(h===12) return 'noon'; return `${H[h]} o'clock`; };
  const nextH = h => { if(h===11) return 'noon'; if(h===12||h===0) return 'one'; return H[(h+1)%13]; };

  const entries = [];
  for (let h = 0; h <= 12; h++) {
    const hh = String(h).padStart(2,'0');
    // :00
    entries.push({ file:`${hh}_00.mp3`, text:`It's ${oclock(h)}` });
    // :15
    entries.push({ file:`${hh}_15_frac.mp3`, text:`It's a quarter past ${H[h]}` });
    entries.push({ file:`${hh}_15_num.mp3`,  text:`It's ${H[h]} fifteen` });
    // :30
    entries.push({ file:`${hh}_30_frac.mp3`, text:`It's half past ${H[h]}` });
    entries.push({ file:`${hh}_30_num.mp3`,  text:`It's ${H[h]} thirty` });
    // :45
    entries.push({ file:`${hh}_45_num.mp3`,   text:`It's ${H[h]} forty-five` });
    entries.push({ file:`${hh}_45_frac.mp3`,  text:`It's a quarter to ${nextH(h)}` });
    entries.push({ file:`${hh}_45_minus.mp3`, text:`It's fifteen to ${nextH(h)}` });
  }
  return entries;
})();

// ─── Helper ───
function buildPhrases(H, nextFn, onHour, fns) {
  const entries = [];
  for (let h = 0; h <= 12; h++) {
    const hh = String(h).padStart(2,'0');
    const hN = H[h]; const nH = nextFn(h);
    entries.push({ file:`${hh}_00.mp3`, text: onHour(h, 0, hN) });
    entries.push({ file:`${hh}_15_frac.mp3`, text: fns.q_frac(h, hN) });
    entries.push({ file:`${hh}_15_num.mp3`,  text: fns.q_num(h, hN) });
    entries.push({ file:`${hh}_30_frac.mp3`, text: fns.half_frac(h, hN) });
    entries.push({ file:`${hh}_30_num.mp3`,  text: fns.half_num(h, hN) });
    entries.push({ file:`${hh}_45_num.mp3`,   text: fns.t_num(h, hN) });
    entries.push({ file:`${hh}_45_frac.mp3`,  text: fns.t_frac(h, hN, nH) });
    entries.push({ file:`${hh}_45_minus.mp3`, text: fns.t_minus(h, hN, nH) });
  }
  return entries;
}

const ALL_LANGS = { french: FRENCH, italian: ITALIAN, german: GERMAN, english: ENGLISH };

// ─── TTS generation ───
async function generateAudio(text, outPath, voiceCfg) {
  try {
    const tts = new EdgeTTS({ voice: voiceCfg.voice, lang: voiceCfg.lang });
    await tts.ttsPromise(text, outPath);
    return true;
  } catch (e) {
    console.error(`  ❌ Failed: ${text} → ${e.message}`);
    return false;
  }
}

async function main() {
  const args = process.argv.slice(2);
  const doAll = args.includes('--all');
  const langArg = args.find(a => !a.startsWith('-'));
  
  const langsToGen = langArg ? [langArg] : Object.keys(ALL_LANGS);

  for (const langKey of langsToGen) {
    if (!ALL_LANGS[langKey]) { console.error(`Unknown language: ${langKey}`); continue; }
    
    const voiceCfg = VOICES[langKey];
    const outDir = join(ASSETS_DIR, langKey);
    mkdirSync(outDir, { recursive: true });

    let phrases = ALL_LANGS[langKey];

    if (!doAll) {
      const sample = ['00','01','06','12'];
      phrases = phrases.filter(p => sample.some(h => p.file.startsWith(h+'_')));
      console.log(`\n🧪 ${langKey.toUpperCase()}: sample ${phrases.length} files (use --all for 104)`);
    } else {
      console.log(`\n🎙️  ${langKey.toUpperCase()}: generating ${phrases.length} files with ${voiceCfg.voice}`);
    }

    let ok = 0, fail = 0;
    for (const phrase of phrases) {
      const outPath = join(outDir, phrase.file);
      process.stdout.write(`  🔊 ${phrase.file.padEnd(22)} "${phrase.text}" ... `);
      const success = await generateAudio(phrase.text, outPath, voiceCfg);
      if (success) { console.log('✅'); ok++; } else { fail++; }
    }
    console.log(`  📊 ${langKey}: ${ok} OK, ${fail} failed`);
  }

  console.log('\n✨ Done!');
}

main().catch(e => { console.error(e); process.exit(1); });

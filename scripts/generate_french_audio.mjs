#!/usr/bin/env node
// Generate French time-telling audio files using Edge TTS
// Usage: node generate_french_audio.mjs [--all]
// Without --all, generates only a sample set for testing.

import { execSync } from 'child_process';
import { mkdirSync, existsSync, unlinkSync } from 'fs';
import { join } from 'path';
import { createRequire } from 'module';

// Resolve node-edge-tts from openclaw's node_modules
const require = createRequire('/Users/riccardo/git/openclaw/package.json');
const { EdgeTTS } = require('node-edge-tts');

const VOICE = 'fr-FR-DeniseNeural';
const LANG = 'fr-FR';
const OUT_DIR = join(import.meta.dirname, '..', 'assets', 'audio', 'french');
const OPENCLAW_DIR = '/Users/riccardo/git/openclaw'; // for node_modules

// French hour words
const HOURS_FR = {
  0: { name: 'minuit', plural: false },
  1: { name: 'une heure', plural: false },
  2: { name: 'deux heures', plural: true },
  3: { name: 'trois heures', plural: true },
  4: { name: 'quatre heures', plural: true },
  5: { name: 'cinq heures', plural: true },
  6: { name: 'six heures', plural: true },
  7: { name: 'sept heures', plural: true },
  8: { name: 'huit heures', plural: true },
  9: { name: 'neuf heures', plural: true },
  10: { name: 'dix heures', plural: true },
  11: { name: 'onze heures', plural: true },
  12: { name: 'midi', plural: false },
};

// Next hour for "moins" forms
function nextHourName(h) {
  const next = (h + 1) % 13;
  // Special: after 11 comes midi (12), after 12 comes une heure (1)
  if (h === 11) return 'midi';
  if (h === 12) return 'une heure';
  if (h === 0) return 'une heure';
  return HOURS_FR[next].name;
}

// Build all phrases for a given hour (0-12)
function phrasesForHour(h) {
  const hourName = HOURS_FR[h].name;
  const nextH = nextHourName(h);
  const hh = String(h).padStart(2, '0');

  const entries = [];

  // :00 — one variant
  entries.push({
    file: `${hh}_00.mp3`,
    text: `Il est ${hourName}`,
  });

  // :15 — two variants: frac (et quart) and num (quinze)
  entries.push({
    file: `${hh}_15_frac.mp3`,
    text: `Il est ${hourName} et quart`,
  });
  entries.push({
    file: `${hh}_15_num.mp3`,
    text: `Il est ${hourName} quinze`,
  });

  // :30 — two variants: frac (et demie) and num (trente)
  entries.push({
    file: `${hh}_30_frac.mp3`,
    text: `Il est ${hourName} et demie`,
  });
  entries.push({
    file: `${hh}_30_num.mp3`,
    text: `Il est ${hourName} trente`,
  });

  // :45 — three variants: num (quarante-cinq), frac (moins le quart), minus (moins quinze)
  entries.push({
    file: `${hh}_45_num.mp3`,
    text: `Il est ${hourName} quarante-cinq`,
  });
  entries.push({
    file: `${hh}_45_frac.mp3`,
    text: `Il est ${nextH} moins le quart`,
  });
  entries.push({
    file: `${hh}_45_minus.mp3`,
    text: `Il est ${nextH} moins quinze`,
  });

  return entries;
}

// Special fix: minuit and midi don't take "quinze/trente/quarante-cinq" directly
// in formal French, but it's acceptable in spoken French. We keep it for learning.

async function generateAudio(text, outPath) {
  try {
    const tts = new EdgeTTS({ voice: VOICE, lang: LANG });
    await tts.ttsPromise(text, outPath);
    return true;
  } catch (e) {
    console.error(`  ❌ Failed: ${text} → ${e.message}`);
    return false;
  }
}

async function main() {
  const doAll = process.argv.includes('--all');

  mkdirSync(OUT_DIR, { recursive: true });

  // Build full phrase list
  let allPhrases = [];
  for (let h = 0; h <= 12; h++) {
    allPhrases.push(...phrasesForHour(h));
  }

  // If not --all, just do a sample: hours 0, 1, 6, 12
  if (!doAll) {
    const sampleHours = ['00', '01', '06', '12'];
    allPhrases = allPhrases.filter(p => sampleHours.some(h => p.file.startsWith(h + '_')));
    console.log(`🧪 Sample mode: generating ${allPhrases.length} files (use --all for all 104)`);
  } else {
    console.log(`🎙️  Full mode: generating ${allPhrases.length} files`);
  }

  let ok = 0, fail = 0;
  for (const phrase of allPhrases) {
    const outPath = join(OUT_DIR, phrase.file);
    process.stdout.write(`  🔊 ${phrase.file.padEnd(22)} "${phrase.text}" ... `);
    const success = await generateAudio(phrase.text, outPath);
    if (success) {
      console.log('✅');
      ok++;
    } else {
      fail++;
    }
  }

  console.log(`\n📊 Done: ${ok} OK, ${fail} failed, ${allPhrases.length} total`);
  console.log(`📂 Files in: ${OUT_DIR}`);
}

main().catch(e => { console.error(e); process.exit(1); });

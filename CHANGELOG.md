# Changelog

All notable changes to orologia.io will be documented in this file.

## [1.2.0] - 2026-09-01

### Added
- 🇩🇪 **German audio** — 104 MP3s with Katja (female), includes "halb zwei", "Viertel vor/nach", "dreiviertel"
- 🇮🇹 **Italian audio** — 104 MP3s with Elsa (female), includes "e un quarto", "meno un quarto", "e mezza"
- 🇬🇧 **English audio** — 104 MP3s with Sonia (British female), includes "quarter past/to", "half past"
- All 4 language flags now active in the header

### Fixed
- Footer position (was top-right, now bottom-center)
- Variant pill buttons no longer wrap text

## [1.1.0] - 2026-09-01

### Added
- 🔊 **Multilingual time-telling audio** — hear the time pronounced in French!
  - 104 MP3 files generated with Edge TTS (voice: Denise, female)
  - Every 15 minutes from 0:00 to 12:45
  - 2-3 variants per time: fraction (et quart), numeric (quinze), minus (moins le quart)
- 🇫🇷🇮🇹🇩🇪🇬🇧 **Global language selector** in the header (French active, others coming)
- 🔊 **Speaker button** in Mode 1 (Analog → Digital) and Mode 2 (Digital → Analog)
- **Dynamic variant pills** — visual buttons like `3¼`, `3:15`, `10-¼` that change per question
- **Auto-play** on variant switch
- **Version footer** — subtle version display at bottom of page
- `VERSION` and `CHANGELOG.md` files
- `scripts/generate_time_audio.mjs` — unified TTS generation script for all 4 languages

## [1.0.0] - 2026-06-15

### Initial Release
- 🕐 Three game modes: Analog→Digital, Digital→Analog, Interactive
- ⭐ Three difficulty levels: Easy (hours only), Medium (+quarters), Hard (+5 min)
- 🎨 Light/Dark theme with Google-branded colors
- 🔊 Sound effects (correct, incorrect, tick, celebration)
- ❤️ Lives system with game-over and restart
- 🏆 Streak milestones and victory celebrations
- 🔒 Safe-cracking mini-game (Easter egg)
- 📱 Responsive design for mobile and desktop

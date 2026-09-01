# Orologia.io (Codenamed: Time Master)

🕐 Play the game here: **https://palladius.github.io/orologia.io/**

![Orologia.io Logo](logo.jpg)

A mobile clock-learning game designed to teach children (Sebi and Alessandro) how to read analog clocks, update digital displays, and understand 7-segment digital watch digit configurations.

## Key Features

1. **Interactive Analog Clock**: Smoothly drag the hour hand or minute hand (dual-zone continuous dragging) and see the times and hands adjust in perfect synchronization.
2. **Game Modes**:
   - **Mode 1 (Analog ➔ Digital)**: Select the correct digital time matching the clock hands.
   - **Mode 2 (Digital ➔ Analog)**: Identify the correct clock face for a given digital target (including 24-hour PM conversions for older kids).
   - **Mode 3 (Interactive & Digital Display)**: Explore how clock hands update the digital time and visualize the active/inactive elements on a classic 7-segment digital watch display in real-time.
3. **🔊 Multilingual Time Audio** *(v1.1.0)*: Hear the time pronounced in 4 languages!
   - 🇫🇷 French (Denise), 🇮🇹 Italian (Elsa), 🇩🇪 German (Katja), 🇬🇧 English (Sonia)
   - 104 audio files per language (every 15 min, 0:00–12:45)
   - Multiple variants: fractions (*et quart*), numeric (*quinze*), and minus (*moins le quart*)
   - Dynamic variant buttons: `3¼`, `3:15`, `10-¼`, `10-15` — click to hear each way of saying the time
4. **Smart Distractor System**: Leverages algorithmic rules to prevent guessing ("A Usta") by generating extremely plausible wrong answers (e.g. swapping hands, off-by-one hour, or close minutes) appropriate for the selected difficulty.
5. **Educational Guides**: Offers a visual guide detailing the quarter sub-ticks between hours (🔵 :15, 🟡 :30, 🔴 :45), making the slow shifting of the hour hand intuitive.
6. **Aesthetics & Audio**: Gorgeous glassmorphism, responsive interface supporting both Light (Daylight) and Dark (Neon Space) themes, and synthesized cute Web Audio SFX (chime, buzzer, ticking, celebration) with zero external assets needed.

## How to Play

Simply visit **https://palladius.github.io/orologia.io/** or open `solutions/20260615-antigravity-managed-agents/index.html` locally.

## Generating Audio Files

Audio files are generated using [Edge TTS](https://github.com/nicebro/node-edge-tts) with female voices:

```bash
# Generate all audio for a language:
node scripts/generate_time_audio.mjs french --all
node scripts/generate_time_audio.mjs italian --all
node scripts/generate_time_audio.mjs german --all
node scripts/generate_time_audio.mjs english --all

# Copy into solution directory for deployment:
cp -r assets/audio/<language> solutions/20260615-antigravity-managed-agents/assets/audio/
```

## Solutions

1. **Antigravity Managed Agents Web Solution** (Vanilla JS):
   - **Path**: [solutions/20260615-antigravity-managed-agents/](solutions/20260615-antigravity-managed-agents/)
   - **Deployment**: [GitHub Pages](https://palladius.github.io/orologia.io/) — auto-deploys on push to `main`
   - **Description**: A fully interactive, responsive clock-learning game featuring analog clock rotation, a 7-segment watch display, safe cracker combination lock, multilingual audio pronunciation, sound effects, and input diagnostics testing.

2. **Flutter Mobile Prototype** (Antigravity UI Solution):
   - **Path**: [solutions/antigravity2.0-multi-agent-flutter/](solutions/antigravity2.0-multi-agent-flutter/)
   - **Description**: A more complex Flutter-based UI solution that took 30 minutes to build, implementing the mobile transition specifications, and is being pushed to Google Play as we speak.

## Documentation
*   [docs/BDD.md](docs/BDD.md) — Product requirements and behavior specifications (Gherkin features)
*   [CHANGELOG.md](CHANGELOG.md) — Version history
*   [GEMINI.md](GEMINI.md) — AI agent instructions

## Tech Stack
*   **Web Prototype:** HTML5, CSS3 (Custom properties, CSS Grid/Flexbox), Vanilla Javascript (ES6+, Web Audio API, SVG graphics).
*   **Audio Generation:** Node.js, Edge TTS (Microsoft neural voices).
*   **Mobile App Framework:** Flutter (Dart) - *PRD specifications aligned for mobile transition*.

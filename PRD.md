# PRD: "Orologia.io" (Codenamed: Time Master)

## 1. Project Objective
Create a mobile game (Android/iOS) to teach children (specifically Sebi and Alessandro) to read analog clocks.

## 2. Target Users
- **Seby (Easy):** Full hours and half-hours (0, 30 min).
- **Alessandro (Medium/Hard):** Quarters, specific minutes, and complex conversions.

## 3. Gameplay Dynamics
Players must map analog clock hands to their digital representation.
- **Mode 1:** Analog -> Digital (Select from 4 digital options).
- **Mode 2:** Digital -> Analog (Select from 4 clock options).
- **Mode 3 (Interactive):** The user can rotate the clock hands with their finger ("Rotational Input"). As the hands rotate, the digital display updates in real-time.
- **BCD Integration:** In Mode 3, the HH:MM digital display is simultaneously represented in **BCD (Binary Coded Decimal)** format, teaching kids both traditional and binary-like logic.
- **Sistema di distrazione:** Le opzioni errate devono essere simili all'orario corretto (es. errore sulle ore o minuti vicini) per evitare che il giocatore vada "a usta".

## 4. Difficulty Levels
- **Easy:** Only hours and half-hours (0, 30 min).
- **Medium:** Quarters (0, 15, 30, 45 min).
- **Hard:** Any minute (e.g., 43 min).

## 5. Technical Stack
- **Framework:** **Flutter** (Dart) for cross-platform support and responsive UI.
- **AI Integration:** AI-generated logic for game mechanics and procedural level generation.

## 6. Business Requirements (BDD/User Stories)
- **User Story:** As a parent, I want my children to learn to read clocks while playing.
- **Gherkin Example:**
  - *Given* the user is in 'Rotational Mode'
  - *When* the user rotates the hands to 07:45
  - *Then* the digital display shows 07:45 AND the BCD display updates to the correct binary representation.

---
*Note: Next step: feed this PRD to an AI agent to generate the Flutter prototype.*
EOF

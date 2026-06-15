# PRD & BDD: Orologia.io (Codenamed: Time Master / Sebi Time Master)

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
- **7-Segment Display Integration:** In Mode 3, the HH:MM digital display is represented using a classic **7-segment display** (like in digital watches), teaching kids how the digits 0-9 are visually constructed using active and inactive segments.
- **Sistema di distrazione (Distraction System):** Le opzioni errate devono essere simili all'orario corretto (es. errore sulle ore o minuti vicini) per evitare che il giocatore vada "a usta" (to prevent guessing).
- **Visual Aid (Clock Ticks & Hands):** To help children understand the fractional positioning of the short hour hand (**asticella**), the analog clock face must feature:
  * **12 bumps (hour ticks)** around the dial.
  * **4 smaller "tacchettine" (markers)** placed at the quarter points (15, 30, 45, 60/0 minutes) to visualize where the hour hand should point fractionally when minutes are at quarters (e.g. at 45 minutes, the hour hand is 3/4 of the way between the current hour and the next, aligning with the quarter guides).

## 4. Difficulty Levels
- **Easy:** Only hours and half-hours (0, 30 min).
- **Medium:** Quarters (0, 15, 30, 45 min).
- **Hard:** Any minute (e.g., 43 min).

## 5. Technical Stack
- **Framework:** **Flutter** (Dart) for cross-platform support and responsive UI.
- **AI Integration:** AI-generated logic for game mechanics and procedural level generation.

---

## 6. Behavior-Driven Development (BDD) Specifications
*Behavior-Driven Development specifications and Gherkin feature files for the analog/digital clock game.*

### Feature 1: Mode 1 - Analog to Digital Mapping
*As a young player, I want to see an analog clock and choose the correct digital time so I can learn how to read clock hands.*

  Scenario: Easy mode - Correct digital option selected
    Given the player is in 'Analog to Digital' game mode
    And the difficulty level is set to 'Easy'
    And the analog clock displays the hands at "03:30"
    When the player selects the digital option "03:30"
    Then the system registers a correct answer
    And the score is incremented by 10 points
    And a cheerful sound effect is played
    And a positive visual celebration is displayed on the screen

  Scenario: Easy mode - Incorrect digital option selected (Simulating "A Usta" Prevention)
    Given the player is in 'Analog to Digital' game mode
    And the difficulty level is set to 'Easy'
    And the analog clock displays the hands at "03:30"
    When the player selects the digital option "04:30"
    Then the system registers an incorrect answer
    And the player's life count is decremented by 1
    And a subtle buzzing sound effect is played
    And the correct option "03:30" is highlighted in green

---

### Feature 2: Mode 2 - Digital to Analog Mapping
*As a player, I want to see a digital time and choose the correct analog clock face to master visual time translation.*

  Scenario: Medium mode - Correct analog option selected
    Given the player is in 'Digital to Analog' game mode
    And the difficulty level is set to 'Medium'
    And the digital display shows "15:45"
    When the player taps the analog clock displaying the hands at "03:45"
    Then the system registers a correct answer
    And the score is incremented by 15 points
    And the next level is loaded

---

### Feature 3: Mode 3 - Rotational Input, 7-Segment Display, and Safe Lock Mode
*As an advanced player, I want to rotate the clock hands with my finger and see the digital display update in real-time as a 7-segment layout, or toggle Safe Lock Mode to solve combination puzzles with satisfying clicking sounds.*

  Scenario: Real-time update of 7-segment digital display on hand rotation
    Given the player is in 'Rotational Mode'
    And the current time displayed is "12:00"
    When the player drags the minute hand with their finger to "45" minutes
    And the hour hand shifts to "07"
    Then the digital text display shows "07:45"
    And the 7-segment display segments (a-g) update dynamically for each digit:
      | Digit | Active Segments | Description of Active Segments |
      | '0'   | a, b, c, d, e, f| Outer loop active, middle off |
      | '7'   | a, b, c         | Top and right segments active |
      | '4'   | b, c, f, g      | Left-top, middle, and right segments active |
      | '5'   | a, c, d, f, g   | Top, left-top, middle, right-bottom, bottom active |

  Scenario: Safe Lock Mode (Cassaforte) - Movie combination style unlocking
    Given the player is in 'Rotational Mode'
    When the player toggles 'Safe Mode' on
    Then the clock styling changes to a metallic safe lock face
    And the safe combination displays three target ticks (e.g. Right to 20, Left to 40, Right to 10)
    And the safe status starts as 'LOCKED 🔒'
    When the player rotates the dial (minute hand) in the expected direction (CW / CCW)
    Then the system plays a metallic clicking sound ('safe_click') at each tick
    And the click sound is completely silenced ("no sound when its correct") when the dial is within the ±3 minutes (5%) error margin of the current target
    When the player changes direction or releases the dial inside the correct target range
    Then the step is registered as completed in the UI combination steps
    When the player makes an incorrect turn or overshoots and reverses direction outside the target range
    Then the combination progress resets to step 0 and locks again
    When the player completes all three steps in sequence (Right ➔ Left ➔ Right)
    Then the safe opens and status changes to 'OPENED 🔓'
    And a celebration sound effect is played
    And a glorious treasure chest illustration is displayed on screen

---

### Feature 4: Difficulty Level Configurations
*As a parent, I want to choose different levels of difficulty so my kids can learn at their own pace.*

  Scenario: Easy mode restricted to hours and half-hours
    Given the player starts a new game on 'Easy' level
    Then the game engine only generates levels with clock times ending in ":00" or ":30"

  Scenario: Medium mode restricted to quarters
    Given the player starts a new game on 'Medium' level
    Then the game engine only generates levels with clock times ending in ":00", ":15", ":30", or ":45"

  Scenario: Hard mode allows any minute
    Given the player starts a new game on 'Hard' level
    Then the game engine generates levels with clock times containing any minute from "00" to "59"

---
*Note: Next step: feed this BDD to an AI agent to generate the Flutter prototype.*

# PRD & BDD: Orologia.io (Codenamed: Time Master / Sebi Time Master)

Note: This BDD can be found in this repo: https://github.com/palladius/orologia.io/

## 1. Project Objective
Create a mobile game (Android/iOS) to teach children (specifically Sebi and Alessandro) to read analog clocks.

## 2. Target Users
- **Seby (Easy):** Full hours and half-hours (0, 30 min).
- **Alessandro (Medium):** Quarters,
- **Adults**: Hard. specific minutes, and complex conversions.

## 3. Gameplay Dynamics

Players must map analog clock hands to their digital representation.
- **Mode 1:** Analog -> Digital (Select from 4 digital options).
- **Mode 2:** Digital -> Analog (Select from 4 clock options).
- **Mode 3 (Interactive):** The user can rotate the clock hands with their finger ("Rotational Input"). As the hands rotate, the digital display updates in real-time.
- **7-Segment Display Integration:** In Mode 3, the HH:MM digital display is represented using a classic **7-segment display** (like in digital watches), teaching kids how the digits 0-9 are visually constructed using active and inactive segments.
- **Distraction System:** Incorrect options must be similar to the correct time (e.g., error on the hour or nearby minutes) to prevent the player from guessing.
- **Visual Aid (Clock Ticks & Hands):** To help children understand the fractional positioning of the short hour hand, the analog clock face must feature:
  * **12 bumps (hour ticks)** around the dial.
  * **4 smaller markers (quarter ticks)** placed at the quarter points (15, 30, 45, 60/0 minutes) to visualize where the hour hand should point fractionally when minutes are at quarters (e.g. at 45 minutes, the hour hand is 3/4 of the way between the current hour and the next, aligning with the quarter guides).

## 4. Difficulty Levels
- **Easy:** Only hours and half-hours (0, 30 min).
- **Medium:** Quarters and multiples of 10 (0, 10, 15, 20, 30, 40, 45, 50 min).
- **Hard:** Any minute (e.g., 43 min).

## 5. Technical Stack
- **Framework:** **Flutter** (Dart) for cross-platform support and responsive UI.
- **AI Integration:** (optional) AI-generated logic for game mechanics and procedural level generation.

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

  Scenario: Easy mode - Incorrect digital option selected (Simulating guessing prevention)
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

  Scenario: Safe Lock Mode (Safe) - Movie combination style unlocking
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

  Scenario: Medium mode restricted to quarters and multiples of 10
    Given the player starts a new game on 'Medium' level
    Then the game engine only generates levels with clock times ending in ":00", ":10", ":15", ":20", ":30", ":40", ":45", or ":50"

  Scenario: Hard mode allows any minute
    Given the player starts a new game on 'Hard' level
    Then the game engine generates levels with clock times containing any minute from "00" to "59"

---

### Feature 5: Multi-Device Input Controls, Responsiveness, and Explicit Diagnostics Testing
*As a player, I want to use my preferred input device (Keyboard, Mouse, or Fingers/Touch) on both Desktop and Mobile devices, and have a visual way to explicitly verify that each device type is correctly detected and working.*

  Scenario: Layout responsiveness across Desktop and Mobile screen viewports
    Given the player is viewing the application UI
    When the screen width is greater than 900 pixels (Desktop)
    Then the app shows a two-column grid layout with the main clock panel on the left and the guide sidebar on the right
    When the screen width is 900 pixels or less (Mobile/Tablet)
    Then the app wraps into a single-column layout
    And all headers, stat bars, and option grids scale down dynamically
    And the watch 7-segment digits shrink and reduce gap spacing if the viewport width drops below 400 pixels to prevent layout overflow

  Scenario: Touch screen dragging behavior on mobile devices
    Given the player is on a mobile device and in 'Rotational Mode'
    When the player drags the clock hands with their finger
    Then the screen does not scroll or pan (touch-action is disabled on dragging)
    And the hands follow the finger smoothly and update the time continuously

  Scenario: Keyboard navigation controls in Rotational and Quiz modes
    Given the player is using a keyboard
    When the player is in 'Rotational Mode' (Mode 3)
    And presses the 'ArrowRight' key
    Then the minute hand rotates clockwise by 1 minute
    When the player presses the 'ArrowLeft' key
    Then the minute hand rotates counter-clockwise by 1 minute
    When the player presses the 'ArrowUp' key and 'Safe Mode' is inactive
    Then the hour hand rotates clockwise by 1 hour
    When the player presses the 'ArrowDown' key and 'Safe Mode' is inactive
    Then the hour hand rotates counter-clockwise by 1 hour
    When the player is in 'Analog to Digital' (Mode 1) or 'Digital to Analog' (Mode 2)
    And presses any number key '1', '2', '3', or '4'
    Then the corresponding multiple-choice option button is selected as their answer

  Scenario: Explicit diagnostics testing panel (Input Device Tests)
    Given the player opens the help sidebar
    Then a card titled 'Input Device Tests' is displayed
    And it lists three test status items: 'Keyboard', 'Mouse', and 'Touch'
    And all three status items are initialized with a red cross "❌" icon and "Not Tested" text
    When the player presses any key on their keyboard
    Then the Keyboard status item instantly updates to a green check "✅" icon and "Keyboard OK!" text
    When the player clicks the mouse anywhere on the application window
    Then the Mouse status item instantly updates to a green check "✅" icon and "Mouse OK!" text
    When the player touches the screen or drags a hand with their finger
    Then the Touch status item instantly updates to a green check "✅" icon and "Touch OK!" text

---
*Note: Next step: feed this BDD to an AI agent to generate the Flutter prototype.*

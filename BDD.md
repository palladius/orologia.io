# BDD: Orologia.io (Codenamed: Sebi Time Master)
*Behavior-Driven Development specifications and Gherkin feature files for the analog/digital clock game.*

---

## Feature 1: Mode 1 - Analog to Digital Mapping
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

## Feature 2: Mode 2 - Digital to Analog Mapping
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

## Feature 3: Mode 3 - Rotational Input and BCD Display
*As an advanced player, I want to rotate the clock hands with my finger and see both digital and Binary Coded Decimal displays update in real-time to learn binary logic.*

  Scenario: Real-time update of digital and BCD display on hand rotation
    Given the player is in 'Rotational Mode'
    And the current time displayed is "12:00"
    When the player drags the minute hand with their finger to "45" minutes
    And the hour hand shifts to "07"
    Then the digital text display shows "07:45"
    And the BCD (Binary Coded Decimal) display updates dynamically to:
      | Column | Binary Representation | Decimal Value |
      | Hour   | 0111                  | 7             |
      | Min T  | 0100                  | 4             |
      | Min U  | 0101                  | 5             |

---

## Feature 4: Difficulty Level Configurations
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

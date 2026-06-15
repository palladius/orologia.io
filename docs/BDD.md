# Short BDD: Orologia.io (Time Master)

BDD v**1.3**.

## 1. Project Objective
A mobile clock-learning game designed to teach children (Sebi and Alessandro) to read analog clocks, update digital displays, and visualize 7-segment watch digits.

## 2. Gameplay Modes
- **Mode 1 (Analog ➔ Digital):** Players view an analog clock and select the correct digital time from 4 options.
- **Mode 2 (Digital ➔ Analog):** Players view a target digital time and select the correct analog clock face from 4 options.
- **Mode 3 (Interactive):** Dragging clock hands updates a digital watch segment display in real-time. Includes an optional safe-cracking game (CW-CCW-CW rotation combination).

## 3. Difficulty Settings
- **Easy (Sebi):** Hours and half-hours (`:00`, `:30`).
- **Medium (Alessandro):** Quarters and multiples of 10 (`:00`, `:10`, `:15`, `:20`, `:30`, `:40`, `:45`, `:50`).
- **Hard (Adults):** Any minute (`:00` to `:59`).

---

## 4. Key Behavior Specifications

### Feature 1: Mode 1 & 2 Answers
- **Scenario: Correct Selection**
  - **Given** the player selects the correct option
  - **Then** score increases (Easy: 10, Medium: 15, Hard: 20 points)
  - **And** chime plays and visual celebration is shown.
- **Scenario: Guessing Prevention**
  - **Given** the player selects a wrong option (smart distractors with close hours/minutes)
  - **Then** lives decrease by 1, buzzer plays, and correct answer is highlighted.

### Feature 2: Mode 3 Rotation & Safe Unlocking
- **Scenario: Real-Time Segment Updates**
  - **When** player rotates hands
  - **Then** digital watch 7-segment display updates active segments dynamically.
- **Scenario: Safe combination cracker**
  - **When** safe mode is toggled, metal layout is loaded
  - **And** player rotates the minute hand CW-CCW-CW to target minutes (within ±3 mins error margin)
  - **Then** wheel clicking sound is silenced on correct targets
  - **When** combination is complete, safe opens and reveals treasure.

### Feature 3: Multi-Device Input & Responsiveness
- **Scenario: Input Devices**
  - **Given** player uses Keyboard, Mouse, or Touch Screen
  - **When** Arrow keys adjust hands in Mode 3 OR hotkeys 1-4 select quiz options
  - **Or** touch dragging does not scroll screen (touch-action disabled)
  - **Then** the diagnostic card registers and marks "✅ Device OK!".
- **Scenario: Screen Layout**
  - **When** screen width ≤ 900px (Mobile), layout shifts to one column
  - **And** watch segments scale down if viewport width < 400px.

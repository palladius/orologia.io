// Orologia.io - Game Logic & Interactions

// Global State
const state = {
    gameMode: 1, // 1: Analog -> Digital, 2: Digital -> Analog, 3: Interactive
    difficulty: 'easy', // easy, medium, hard
    score: 0,
    highScore: 0,
    lives: 3,
    streak: 0,
    currentQuestion: null, // { correctTime: {h, m, h24}, options: [{h, m, formatted}], answered: false }
    interactiveTime: { hour: 12, minute: 0 },
    soundEnabled: true,
    audioCtx: null,
    dragState: {
        isDragging: false,
        target: null, // 'hour' or 'minute'
    },
    safeModeActive: false,
    safeCombination: [20, 40, 10],
    safeDirections: ['CW', 'CCW', 'CW'],
    safeStep: 0,
    safeTargetReached: [false, false, false],
    safeLastAngle: null,
    safeOpened: false
};

// Initialize the Application
window.addEventListener('DOMContentLoaded', () => {
    loadHighScore();
    loadPreferences();
    setupEventListeners();
    initGame();
});

// Load High Score from Local Storage
function loadHighScore() {
    const saved = localStorage.getItem('orologia_highscore');
    if (saved) {
        state.highScore = parseInt(saved, 10);
        document.getElementById('high-score').textContent = state.highScore;
    }
}

// Save High Score to Local Storage
function saveHighScore() {
    localStorage.setItem('orologia_highscore', state.score);
    state.highScore = state.score;
    document.getElementById('high-score').textContent = state.highScore;
}

// Load Preferences (Theme & Sound)
function loadPreferences() {
    const theme = localStorage.getItem('orologia_theme') || 'dark';
    document.documentElement.setAttribute('data-theme', theme);
    const themeIcon = document.getElementById('theme-icon');
    themeIcon.textContent = theme === 'light' ? '☀️' : '🌙';

    const sound = localStorage.getItem('orologia_sound');
    state.soundEnabled = sound === null ? true : sound === 'true';
    document.getElementById('sound-icon').textContent = state.soundEnabled ? '🔊' : '🔇';
}

// Web Audio API Sound Generator
function playSound(type) {
    if (!state.soundEnabled) return;

    try {
        // Lazily initialize AudioContext on first user interaction
        if (!state.audioCtx) {
            state.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        }
        
        if (state.audioCtx.state === 'suspended') {
            state.audioCtx.resume();
        }

        const ctx = state.audioCtx;
        const now = ctx.currentTime;

        if (type === 'correct') {
            // Sweet rising major chime (C5 -> G5)
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            
            osc.type = 'triangle';
            osc.frequency.setValueAtTime(523.25, now); // C5
            osc.frequency.exponentialRampToValueAtTime(783.99, now + 0.15); // G5
            
            gain.gain.setValueAtTime(0.15, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + 0.4);
            
            osc.connect(gain);
            gain.connect(ctx.destination);
            
            osc.start(now);
            osc.stop(now + 0.4);

        } else if (type === 'incorrect') {
            // Gentle double-buzz
            const osc1 = ctx.createOscillator();
            const osc2 = ctx.createOscillator();
            const gain = ctx.createGain();
            
            osc1.type = 'sawtooth';
            osc2.type = 'square';
            
            osc1.frequency.setValueAtTime(140, now);
            osc2.frequency.setValueAtTime(144, now); // detuned slightly for beating
            
            gain.gain.setValueAtTime(0.12, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);
            
            osc1.connect(gain);
            osc2.connect(gain);
            gain.connect(ctx.destination);
            
            osc1.start(now);
            osc2.start(now);
            
            osc1.stop(now + 0.35);
            osc2.stop(now + 0.35);

        } else if (type === 'tick') {
            // Tiny wooden mechanical clock click
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            
            osc.type = 'sine';
            osc.frequency.setValueAtTime(1800, now);
            
            gain.gain.setValueAtTime(0.05, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + 0.015);
            
            osc.connect(gain);
            gain.connect(ctx.destination);
            
            osc.start(now);
            osc.stop(now + 0.02);

        } else if (type === 'safe_click') {
            // A crisp, metallic safe wheel gear click
            const osc1 = ctx.createOscillator();
            const osc2 = ctx.createOscillator();
            const gain = ctx.createGain();
            
            osc1.type = 'triangle';
            osc1.frequency.setValueAtTime(1200, now);
            osc1.frequency.exponentialRampToValueAtTime(100, now + 0.03);
            
            osc2.type = 'sine';
            osc2.frequency.setValueAtTime(300, now);
            osc2.frequency.exponentialRampToValueAtTime(80, now + 0.04);
            
            gain.gain.setValueAtTime(0.15, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + 0.04);
            
            osc1.connect(gain);
            osc2.connect(gain);
            gain.connect(ctx.destination);
            
            osc1.start(now);
            osc2.start(now);
            osc1.stop(now + 0.05);
            osc2.stop(now + 0.05);

        } else if (type === 'celebrate') {
            // Magical sparkly arpeggio (C5 -> E5 -> G5 -> C6)
            const freqs = [523.25, 659.25, 783.99, 1046.50];
            freqs.forEach((freq, idx) => {
                const noteTime = now + idx * 0.08;
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                
                osc.type = 'sine';
                osc.frequency.setValueAtTime(freq, noteTime);
                
                gain.gain.setValueAtTime(0.12, noteTime);
                gain.gain.exponentialRampToValueAtTime(0.001, noteTime + 0.3);
                
                osc.connect(gain);
                gain.connect(ctx.destination);
                
                osc.start(noteTime);
                osc.stop(noteTime + 0.3);
            });
        }
    } catch (e) {
        console.warn("Web Audio API failed to play sound: ", e);
    }
}

// Multilingual Time Audio Playback
// Plays a pre-recorded MP3 of the current time in the selected language
let currentTimeAudio = null; // Track playing audio to avoid overlaps
let autoPlayTimer = null;    // 5-second auto-play timer

// Start a 5-second timer that auto-plays a random variant if user is idle
// Only for Mode 1 (AD) and Mode 2 (DA), not Master difficulty
function startAutoPlayTimer() {
    cancelAutoPlayTimer();

    // Don't auto-play for Master difficulty (may have non-quarter times) or Mode 3
    if (state.difficulty === 'hard' || state.gameMode === 3) return;
    if (!state.currentQuestion) return;

    const minute = state.currentQuestion.correctTime.minute;
    // Only auto-play for times that have audio files
    if (minute !== 0 && minute !== 15 && minute !== 30 && minute !== 45) return;

    autoPlayTimer = setTimeout(() => {
        autoPlayTimer = null;
        if (!state.currentQuestion || state.currentQuestion.answered) return;

        // Pick a random variant pill and activate it before playing
        const activeScreen = document.querySelector('.game-screen.active');
        if (!activeScreen) return;
        const pills = activeScreen.querySelectorAll('.pill-btn');
        if (pills.length > 0) {
            const randomPill = pills[Math.floor(Math.random() * pills.length)];
            pills.forEach(p => p.classList.remove('active'));
            randomPill.classList.add('active');
        }

        console.log('⏰ Auto-play after 5s idle');
        playTimeAudio();
    }, 5000);
}

function cancelAutoPlayTimer() {
    if (autoPlayTimer) {
        clearTimeout(autoPlayTimer);
        autoPlayTimer = null;
    }
}

function playTimeAudio() {
    if (!state.currentQuestion) return;
    cancelAutoPlayTimer();

    const q = state.currentQuestion.correctTime;
    const hour12 = q.hour === 12 ? 12 : q.hour % 12;
    const minute = q.minute;
    const langBtn = document.querySelector('#global-lang-flags .flag-btn.active');

    // Find the active variant pill in the VISIBLE game screen only
    const activeScreen = document.querySelector('.game-screen.active') || document;
    const variantBtn = activeScreen.querySelector('.pill-btn.active');

    const lang = langBtn ? langBtn.dataset.lang : 'french';
    const variant = variantBtn ? variantBtn.dataset.variant : 'frac';

    const hh = String(hour12).padStart(2, '0');
    const mm = String(minute).padStart(2, '0');

    let filename;
    if (minute === 0) {
        filename = `${hh}_00.mp3`;
    } else if (minute === 15 || minute === 30) {
        // frac or num variant
        const v = (variant === 'minus') ? 'frac' : variant; // minus only for :45
        filename = `${hh}_${mm}_${v}.mp3`;
    } else if (minute === 45) {
        filename = `${hh}_${mm}_${variant}.mp3`;
    } else {
        // For non-quarter times, no audio file exists yet
        showToast('Audio only for :00, :15, :30, :45', 'fail', '🔇');
        return;
    }

    const url = `assets/audio/${lang}/${filename}`;
    console.log(`🔊 Playing: ${url} (variant=${variant})`);

    // Stop any currently playing audio
    if (currentTimeAudio) {
        currentTimeAudio.pause();
        currentTimeAudio = null;
    }

    const audio = new Audio(url);
    currentTimeAudio = audio;

    // Visual feedback on the speak button (works for both Mode 1 and Mode 2)
    const btn = activeScreen.querySelector('.speak-btn');
    if (btn) {
        btn.classList.add('playing');
        btn.textContent = '🔉';
    }

    audio.play().catch(err => {
        console.warn('Audio playback failed:', err);
        showToast('Audio not available yet', 'fail', '🔇');
    });

    audio.addEventListener('ended', () => {
        if (btn) {
            btn.classList.remove('playing');
            btn.textContent = '🔊';
        }
        currentTimeAudio = null;
    });

    audio.addEventListener('error', () => {
        btn.classList.remove('playing');
        btn.textContent = '🔊';
        currentTimeAudio = null;
    });
}

// Event Listeners Setup
function setupEventListeners() {
    // Mode selector buttons
    document.querySelectorAll('.mode-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const mode = parseInt(btn.getAttribute('data-mode'), 10);
            changeMode(mode);
        });
    });

    // Difficulty selector buttons
    document.querySelectorAll('.diff-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const diff = btn.getAttribute('data-diff');
            changeDifficulty(diff);
        });
    });

    // Theme toggle
    document.getElementById('theme-toggle').addEventListener('click', () => {
        const currentTheme = document.documentElement.getAttribute('data-theme');
        const nextTheme = currentTheme === 'light' ? 'dark' : 'light';
        document.documentElement.setAttribute('data-theme', nextTheme);
        localStorage.setItem('orologia_theme', nextTheme);
        document.getElementById('theme-icon').textContent = nextTheme === 'light' ? '☀️' : '🌙';
        playSound('tick');
    });

    // Sound toggle
    document.getElementById('sound-toggle').addEventListener('click', () => {
        state.soundEnabled = !state.soundEnabled;
        localStorage.setItem('orologia_sound', state.soundEnabled);
        document.getElementById('sound-icon').textContent = state.soundEnabled ? '🔊' : '🔇';
        
        // Initialize AudioContext if not done yet
        if (state.soundEnabled && !state.audioCtx) {
            state.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        }
        playSound('tick');
    });

    // Restart button on Game Over
    document.getElementById('btn-restart').addEventListener('click', () => {
        hideModal('game-over-modal');
        resetGame();
    });

    // Continue button on Milestone victory
    document.getElementById('btn-continue').addEventListener('click', () => {
        hideModal('victory-modal');
        generateQuestion();
    });

    // Setup dragging handlers on Interactive Mode Clock
    const interactiveClock = document.getElementById('interactive-clock-container');
    
    interactiveClock.addEventListener('pointerdown', handlePointerDown);
    window.addEventListener('pointermove', handlePointerMove);
    window.addEventListener('pointerup', handlePointerUp);

    // Safe Mode Toggle Button
    const safeToggle = document.getElementById('safe-mode-toggle');
    if (safeToggle) {
        safeToggle.addEventListener('click', () => {
            toggleSafeMode();
        });
    }

    // Play Again button inside Safe Treasure Reveal Area
    const nextSafeBtn = document.getElementById('btn-next-safe');
    if (nextSafeBtn) {
        nextSafeBtn.addEventListener('click', () => {
            generateSafeCombination();
        });
    }

    // 🔊 Speak Time buttons (Mode 1 & Mode 2)
    document.querySelectorAll('.speak-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            playTimeAudio();
        });
    });

    // 🇫🇷🇮🇹🇩🇪🇬🇧 Language flag buttons (global)
    document.querySelectorAll('#global-lang-flags .flag-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            if (btn.disabled) return;
            document.querySelectorAll('#global-lang-flags .flag-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            playSound('tick');
        });
    });

}

// Main Game Initialization
function initGame() {
    resetGame();
}

// Reset Game State
function resetGame() {
    state.score = 0;
    state.lives = 3;
    state.streak = 0;
    document.getElementById('current-score').textContent = '0';
    updateHearts();
    generateQuestion();
    updateInteractiveDisplay();
}

// Update the hearts UI indicator
function updateHearts() {
    const container = document.getElementById('hearts-container');
    container.innerHTML = '';
    for (let i = 0; i < 3; i++) {
        const heartSpan = document.createElement('span');
        heartSpan.className = i < state.lives ? 'heart active' : 'heart';
        heartSpan.textContent = '❤️';
        container.appendChild(heartSpan);
    }
}

// Change Game Mode
function changeMode(mode) {
    if (state.gameMode === mode) return;
    
    // Turn Safe Mode off if navigating away from Mode 3
    if (mode !== 3 && state.safeModeActive) {
        toggleSafeMode();
    }

    // Deactivate previous button and screen
    document.querySelectorAll('.mode-btn').forEach(btn => {
        if (parseInt(btn.getAttribute('data-mode'), 10) === mode) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });

    document.querySelectorAll('.game-screen').forEach(scr => {
        scr.classList.remove('active');
    });

    // Activate selected screen
    state.gameMode = mode;
    document.getElementById(`screen-mode-${mode}`).classList.add('active');

    // Stats and difficulty bar are only relevant for quiz modes (1 and 2)
    const statsBar = document.getElementById('stats-bar');
    if (mode === 3) {
        statsBar.style.opacity = '0.5';
        // Make interactive clock reflect current saved interactive time
        updateInteractiveDisplay();
    } else {
        statsBar.style.opacity = '1';
        generateQuestion();
    }
    
    playSound('tick');
}

// Change Difficulty Level
function changeDifficulty(diff) {
    if (state.difficulty === diff) return;

    document.querySelectorAll('.diff-btn').forEach(btn => {
        if (btn.getAttribute('data-diff') === diff) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });

    state.difficulty = diff;
    state.streak = 0; // Reset streak on difficulty change
    if (state.gameMode === 3) {
        if (state.safeModeActive) {
            generateSafeCombination();
        }
    } else {
        generateQuestion();
    }
    playSound('tick');
}

// Format time nicely into standard HH:MM representation
function formatTime(h, m, is24h = false) {
    const hh = String(is24h ? h : (h === 12 ? 12 : h % 12)).padStart(2, '0');
    const mm = String(m).padStart(2, '0');
    return `${hh}:${mm}`;
}

// Generate procedurally tailored questions based on Difficulty & preventing "A Usta" (guessing)
function generateQuestion() {
    if (state.gameMode === 3) return; // Not applicable for interactive mode

    let hour = Math.floor(Math.random() * 12) + 1; // 1 to 12
    let minute = 0;

    // 1. Determine minutes based on difficulty
    if (state.difficulty === 'easy') {
        // Sebi: hours and half-hours
        minute = Math.random() > 0.5 ? 0 : 30;
    } else if (state.difficulty === 'medium') {
        // Alessandro: Quarters (0, 15, 30, 45)
        const quarters = [0, 15, 30, 45];
        minute = quarters[Math.floor(Math.random() * quarters.length)];
    } else {
        // Hard: Any minute
        minute = Math.floor(Math.random() * 60);
    }

    // 2. Determine if we use 24-hour format for conversion (50% chance in Medium/Hard)
    let is24h = false;
    let hour24 = hour;
    if ((state.difficulty === 'medium' || state.difficulty === 'hard') && Math.random() > 0.5) {
        is24h = true;
        // Map to evening/afternoon (13 to 23), keep 12 as 12 (noon), or 24/00 for midnight
        hour24 = hour === 12 ? 12 : hour + 12;
    }

    const correctTime = { hour, minute, hour24, is24h };
    state.currentQuestion = {
        correctTime: correctTime,
        answered: false,
        options: []
    };

    // 3. Generate distractors conforming to difficulty constraints
    const distractors = generateDistractors(correctTime);
    
    // Create option pool (correct + 3 distractors)
    const optionsPool = [
        { hour, minute, formatted: formatTime(hour24, minute, is24h), isCorrect: true }
    ];

    distractors.forEach(dist => {
        // Distractors share the same 24-hour presentation style as the correct answer
        let distHour24 = dist.hour;
        if (is24h) {
            distHour24 = dist.hour === 12 ? 12 : dist.hour + 12;
        }
        optionsPool.push({
            hour: dist.hour,
            minute: dist.minute,
            formatted: formatTime(distHour24, dist.minute, is24h),
            isCorrect: false
        });
    });

    // Shuffle options so correct answer isn't fixed
    state.currentQuestion.options = shuffleArray(optionsPool);

    // 4. Render active Quiz Screen
    if (state.gameMode === 1) {
        renderMode1();
    } else if (state.gameMode === 2) {
        renderMode2();
    }

    // Start 5-second auto-play timer for audio pronunciation
    startAutoPlayTimer();
}

// Generate 3 extremely smart distractors to prevent guessing ("A Usta")
function generateDistractors(correct) {
    const pool = [];
    const h = correct.hour;
    const m = correct.minute;

    // Define minutes allowed based on difficulty
    let allowedMinutes = [0, 30];
    if (state.difficulty === 'medium') allowedMinutes = [0, 15, 30, 45];
    if (state.difficulty === 'hard') {
        allowedMinutes = Array.from({length: 60}, (_, i) => i);
    }

    // Candidate 1: Same minutes, off by 1 hour (very common mistake for kids)
    const prevHour = h === 1 ? 12 : h - 1;
    const nextHour = h === 12 ? 1 : h + 1;
    pool.push({ hour: prevHour, minute: m });
    pool.push({ hour: nextHour, minute: m });

    // Candidate 2: Same hour, off by minutes
    if (state.difficulty === 'easy') {
        pool.push({ hour: h, minute: m === 0 ? 30 : 0 });
    } else if (state.difficulty === 'medium') {
        // Off by 15 or 30 mins
        [15, 30, 45].forEach(offset => {
            pool.push({ hour: h, minute: (m + offset) % 60 });
        });
    } else {
        // Hard: off by 5, 10, or 15 mins
        [-15, -10, -5, 5, 10, 15].forEach(offset => {
            const targetMin = (m + offset + 60) % 60;
            pool.push({ hour: h, minute: targetMin });
        });
    }

    // Candidate 3: Hand Swap (highly effective distractor!)
    // If the minute is a multiple of 5, the hand position matches an hour number.
    // e.g., at 04:20 (minute hand points at 4). Swapping makes it 04:20, which is identical.
    // e.g., at 03:30 (minute points at 6, hour at 3). Swapping hand numbers -> hour 6, minute 15 (06:15)
    if (m % 5 === 0) {
        const swapHour = Math.floor(m / 5) || 12;
        const swapMinute = (h * 5) % 60;
        
        // Ensure the swapped minutes are valid for the current difficulty
        if (allowedMinutes.includes(swapMinute)) {
            pool.push({ hour: swapHour, minute: swapMinute });
        }
    }

    // Candidate 4: Off by 1 hour AND minutes offset
    if (state.difficulty === 'medium') {
        pool.push({ hour: nextHour, minute: (m + 15) % 60 });
        pool.push({ hour: prevHour, minute: (m + 30) % 60 });
    } else if (state.difficulty === 'hard') {
        pool.push({ hour: nextHour, minute: (m + 5) % 60 });
        pool.push({ hour: prevHour, minute: (m - 5 + 60) % 60 });
    }

    // Filter candidates: must be valid, must not be equal to the correct answer
    let uniqueCandidates = [];
    const seen = new Set();
    const correctKey = `${h}:${m}`;
    seen.add(correctKey);

    pool.forEach(c => {
        const key = `${c.hour}:${c.minute}`;
        if (!seen.has(key)) {
            seen.add(key);
            uniqueCandidates.push(c);
        }
    });

    // If we have fewer than 3 unique candidates, backfill with random valid selections
    while (uniqueCandidates.length < 3) {
        const randHour = Math.floor(Math.random() * 12) + 1;
        const randMin = allowedMinutes[Math.floor(Math.random() * allowedMinutes.length)];
        const key = `${randHour}:${randMin}`;
        if (!seen.has(key)) {
            seen.add(key);
            uniqueCandidates.push({ hour: randHour, minute: randMin });
        }
    }

    // Shuffle and slice to get exactly 3 distractors
    const shuffled = shuffleArray(uniqueCandidates);
    return shuffled.slice(0, 3);
}

// Mode 1: Render Analog Clock & Digital Options
function renderMode1() {
    const q = state.currentQuestion;
    
    // Draw the main large analog clock with the correct target time
    const container = document.getElementById('main-clock-container');
    container.innerHTML = drawClockSvg(q.correctTime.hour, q.correctTime.minute, 320, false);

    // Update variant buttons for this time
    updateVariantButtons(q.correctTime.hour, q.correctTime.minute, 'variant-pills-mode1');

    // Render 4 digital option buttons
    const optionsContainer = document.getElementById('mode1-options');
    optionsContainer.innerHTML = '';

    q.options.forEach((opt, idx) => {
        const btn = document.createElement('button');
        btn.className = 'option-btn';
        btn.textContent = opt.formatted;
        btn.setAttribute('data-index', idx);
        btn.addEventListener('click', () => handleQuizAnswer(opt, btn));
        optionsContainer.appendChild(btn);
    });
}

// Mode 2: Render Digital Target & Mini Analog Clock Options
function renderMode2() {
    const q = state.currentQuestion;

    // Display target digital time
    const digitalDisplay = document.getElementById('mode2-target-digital');
    digitalDisplay.textContent = formatTime(q.correctTime.hour24, q.correctTime.minute, q.correctTime.is24h);

    // Update variant buttons for this time
    updateVariantButtons(q.correctTime.hour, q.correctTime.minute, 'variant-pills');

    // Render 4 mini analog clock buttons
    const gridContainer = document.getElementById('mode2-options');
    gridContainer.innerHTML = '';

    q.options.forEach((opt, idx) => {
        const div = document.createElement('div');
        div.className = 'mini-clock-option';
        div.innerHTML = drawClockSvg(opt.hour, opt.minute, 140, false);
        div.setAttribute('data-index', idx);
        div.addEventListener('click', () => handleQuizAnswer(opt, div));
        gridContainer.appendChild(div);
    });
}

// Build variant buttons dynamically based on the current time
// Shows visual labels like "3¼", "3:15" for quarter past, or "9:45", "10-¼", "10-15" for quarter to
function updateVariantButtons(hour, minute, containerId) {
    const container = document.getElementById(containerId || 'variant-pills');
    if (!container) return;
    container.innerHTML = '';

    const h12 = hour === 12 ? 12 : hour % 12;
    const nextH = h12 === 12 ? 1 : h12 + 1;

    // Unicode fraction chars
    const FRAC = { 15: '¼', 30: '½', 45: '¾' };

    let variants = [];

    if (minute === 0) {
        // Only one way to say :00
        variants.push({ variant: 'frac', label: `${h12}:00`, active: true });
    } else if (minute === 15) {
        variants.push({ variant: 'frac', label: `${h12}¼`, active: true });
        variants.push({ variant: 'num', label: `${h12}:15` });
    } else if (minute === 30) {
        variants.push({ variant: 'frac', label: `${h12}½`, active: true });
        variants.push({ variant: 'num', label: `${h12}:30` });
    } else if (minute === 45) {
        variants.push({ variant: 'num',   label: `${h12}:45` });
        variants.push({ variant: 'frac',  label: `${nextH}-¼`, active: true });
        variants.push({ variant: 'minus', label: `${nextH}-15` });
    } else {
        // Non-quarter: no variant audio available
        variants.push({ variant: 'num', label: `${h12}:${String(minute).padStart(2,'0')}`, active: true });
    }

    variants.forEach(v => {
        const btn = document.createElement('button');
        btn.className = 'pill-btn' + (v.active ? ' active' : '');
        btn.dataset.variant = v.variant;
        btn.textContent = v.label;
        btn.addEventListener('click', () => {
            container.querySelectorAll('.pill-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            playTimeAudio(); // auto-play on variant switch
        });
        container.appendChild(btn);
    });
}

// Quiz Option Click Handler
function handleQuizAnswer(selectedOption, element) {
    const q = state.currentQuestion;
    if (q.answered) return; // Prevent double answering
    q.answered = true;
    cancelAutoPlayTimer();

    if (selectedOption.isCorrect) {
        // Correct Answer
        element.classList.add('correct');
        playSound('correct');
        
        let scoreGain = 10;
        if (state.difficulty === 'medium') scoreGain = 15;
        if (state.difficulty === 'hard') scoreGain = 20;

        state.score += scoreGain;
        state.streak += 1;
        
        document.getElementById('current-score').textContent = state.score;
        showToast(`Correct! +${scoreGain} Points`, 'success', '🎉');

        // Check and update high score
        if (state.score > state.highScore) {
            saveHighScore();
        }

        // Milestone achievements (Every 5 streak)
        if (state.streak > 0 && state.streak % 5 === 0) {
            setTimeout(() => {
                showMilestoneVictory();
            }, 800);
        } else {
            // Proceed to next level
            setTimeout(() => {
                generateQuestion();
            }, 1500);
        }

    } else {
        // Incorrect Answer
        element.classList.add('incorrect');
        playSound('incorrect');

        state.lives -= 1;
        state.streak = 0;
        updateHearts();
        
        showToast("Incorrect time!", "fail", "😢");

        // Highlight the correct option so the player learns
        highlightCorrectOption();

        if (state.lives <= 0) {
            setTimeout(() => {
                showGameOver();
            }, 1500);
        } else {
            // Proceed to next level anyway after a short delay
            setTimeout(() => {
                generateQuestion();
            }, 2200);
        }
    }
}

// Automatically highlight the correct option in quiz screens
function highlightCorrectOption() {
    if (state.gameMode === 1) {
        const btns = document.querySelectorAll('#mode1-options .option-btn');
        state.currentQuestion.options.forEach((opt, idx) => {
            if (opt.isCorrect) {
                btns[idx].classList.add('correct');
            }
        });
    } else if (state.gameMode === 2) {
        const divs = document.querySelectorAll('#mode2-options .mini-clock-option');
        state.currentQuestion.options.forEach((opt, idx) => {
            if (opt.isCorrect) {
                divs[idx].classList.add('correct');
            }
        });
    }
}

// Draw the Clock SVG markup dynamically
function drawClockSvg(hour, minute, size, interactive = false) {
    const cx = 200;
    const cy = 200;
    
    // Hands positioning angles
    const minuteAngle = (minute * 6); // 6 deg per minute
    // Hour hand moves continuous fractionally depending on minutes!
    const hourAngle = ((hour % 12) * 30) + (minute * 0.5); // 30 deg per hour, 0.5 deg per minute

    // Start generating SVG elements
    let svg = `<svg viewBox="0 0 400 400" width="${size}" height="${size}" xmlns="http://www.w3.org/2000/svg" style="pointer-events: ${interactive ? 'none' : 'auto'};">`;

    // 1. Draw 12 decorative outer bumps around the rim (playful gear/flower look)
    const bumpRadius = 186;
    for (let i = 0; i < 12; i++) {
        const angleRad = (i * 30) * Math.PI / 180;
        const bx = cx + bumpRadius * Math.sin(angleRad);
        const by = cy - bumpRadius * Math.cos(angleRad);
        svg += `<circle cx="${bx}" cy="${by}" r="11" class="clock-outer-bump" />`;
    }

    // 2. Clock dial (face background)
    svg += `<circle cx="${cx}" cy="${cy}" r="180" class="clock-face" />`;
    svg += `<circle cx="${cx}" cy="${cy}" r="172" class="clock-rim-accent" />`;

    // 3. Draw standard 60 minute ticks & 12 major hour ticks
    for (let i = 0; i < 60; i++) {
        const angleRad = (i * 6) * Math.PI / 180;
        const sin = Math.sin(angleRad);
        const cos = Math.cos(angleRad);

        if (i % 5 === 0) {
            // Major hour ticks
            const x1 = cx + 164 * sin;
            const y1 = cy - 164 * cos;
            const x2 = cx + 178 * sin;
            const y2 = cy - 178 * cos;
            svg += `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" class="clock-ticks-hour" />`;
        } else {
            // Minor minute ticks
            const x1 = cx + 171 * sin;
            const y1 = cy - 171 * cos;
            const x2 = cx + 178 * sin;
            const y2 = cy - 178 * cos;
            svg += `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" class="clock-ticks-minute" />`;
        }
    }

    // 4. Draw Quarter Sub-Ticks (Educational Guides) between each hour
    // Placed at an inner radius (e.g. 115) to align perfectly with the hour hand tip
    const subRadius = 115;
    for (let hIndex = 0; hIndex < 12; hIndex++) {
        const baseAngle = hIndex * 30; // degrees
        
        // 15-min guide (cyan)
        const rad15 = (baseAngle + 7.5) * Math.PI / 180;
        const x15 = cx + subRadius * Math.sin(rad15);
        const y15 = cy - subRadius * Math.cos(rad15);
        svg += `<circle cx="${x15}" cy="${y15}" r="3.5" class="sub-tick sub-tick-15" title="Quarter past guides" />`;

        // 30-min guide (yellow)
        const rad30 = (baseAngle + 15) * Math.PI / 180;
        const x30 = cx + subRadius * Math.sin(rad30);
        const y30 = cy - subRadius * Math.cos(rad30);
        svg += `<circle cx="${x30}" cy="${y30}" r="3.5" class="sub-tick sub-tick-30" title="Half past guides" />`;

        // 45-min guide (pink)
        const rad45 = (baseAngle + 22.5) * Math.PI / 180;
        const x45 = cx + subRadius * Math.sin(rad45);
        const y45 = cy - subRadius * Math.cos(rad45);
        svg += `<circle cx="${x45}" cy="${y45}" r="3.5" class="sub-tick sub-tick-45" title="Quarter to guides" />`;
    }

    // Draw helper guide tracks
    svg += `<circle cx="${cx}" cy="${cy}" r="${subRadius}" class="clock-quarter-guide" />`;

    // 5. Draw Hour Numbers (1 to 12)
    const numRadius = 142;
    for (let hNum = 1; hNum <= 12; hNum++) {
        const angleRad = (hNum * 30) * Math.PI / 180;
        const nx = cx + numRadius * Math.sin(angleRad);
        const ny = cy - numRadius * Math.cos(angleRad);
        svg += `<text x="${nx}" y="${ny}" class="clock-number">${hNum}</text>`;
    }

    // 6. Draw Hands
    // Hour hand (Short & Thick)
    svg += `<g transform="rotate(${hourAngle} ${cx} ${cy})">`;
    svg += `<line x1="${cx}" y1="${cy + 15}" x2="${cx}" y2="${cy - 100}" class="clock-hand hour-hand" />`;
    svg += `</g>`;

    // Minute hand (Long & Thinner)
    svg += `<g transform="rotate(${minuteAngle} ${cx} ${cy})">`;
    svg += `<line x1="${cx}" y1="${cy + 20}" x2="${cx}" y2="${cy - 155}" class="clock-hand minute-hand" />`;
    svg += `</g>`;

    // 7. Pivot Center Cap
    svg += `<circle cx="${cx}" cy="${cy}" r="9" class="clock-center-cap" />`;

    svg += `</svg>`;
    return svg;
}

// ----------------------------------------------------
// MODE 3: INTERACTIVE CLOCK & DRAGGING LOGIC
// ----------------------------------------------------

// Render and bind interactive clock elements
function updateInteractiveDisplay() {
    const container = document.getElementById('interactive-clock-container');
    const h = state.interactiveTime.hour;
    const m = state.interactiveTime.minute;
    
    // Draw the clock (with pointer events allowed inside)
    container.innerHTML = drawClockSvg(h, m, 320, false);
    
    // Update digital LED panel
    const ledText = formatTime(h, m, false);
    document.getElementById('interactive-digital').textContent = ledText;

    // Update 7-segment display panels
    update7SegmentDisplay(h, m);
}

// Handle pointer dragging initiation
function handlePointerDown(e) {
    if (state.gameMode !== 3) return;

    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    // Convert click location to local SVG coordinates (0 to 400)
    const scale = 400 / rect.width;
    const clickX = x * scale;
    const clickY = y * scale;

    const dx = clickX - 200;
    const dy = clickY - 200;
    const radius = Math.sqrt(dx * dx + dy * dy);

    // Filter out clicks on the center hub
    if (radius < 25) return;

    // Select target hand:
    // Inner area (R <= 125) drags Hour hand
    // Outer area (125 < R <= 195) drags Minute hand
    if (state.safeModeActive) {
        state.dragState.target = 'minute';
    } else {
        if (radius <= 122) {
            state.dragState.target = 'hour';
        } else if (radius > 122 && radius <= 195) {
            state.dragState.target = 'minute';
        } else {
            return; // Click is outside clock face
        }
    }

    state.dragState.isDragging = true;
    e.currentTarget.setPointerCapture(e.pointerId);
}

// Handle active pointer dragging
function handlePointerMove(e) {
    if (state.gameMode !== 3 || !state.dragState.isDragging) return;

    const clockContainer = document.getElementById('interactive-clock-container');
    const rect = clockContainer.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const scale = 400 / rect.width;
    const dragX = x * scale;
    const dragY = y * scale;

    const dx = dragX - 200;
    const dy = dragY - 200;

    // Angle relative to 12 o'clock position (Upwards is 0, Clockwise is positive)
    let angle = Math.atan2(dx, -dy);
    if (angle < 0) angle += 2 * Math.PI;

    // Calculate rotation direction in Safe Mode
    let direction = null;
    if (state.safeModeActive && state.dragState.target === 'minute') {
        if (state.safeLastAngle !== null) {
            let diff = angle - state.safeLastAngle;
            if (diff > Math.PI) diff -= 2 * Math.PI;
            else if (diff < -Math.PI) diff += 2 * Math.PI;
            
            if (Math.abs(diff) > 0.01) {
                direction = diff > 0 ? 'CW' : 'CCW';
            }
        }
        state.safeLastAngle = angle;
    }

    let timeChanged = false;

    if (state.dragState.target === 'minute') {
        // Dragging the Minute hand
        const newMinute = Math.round((angle / (2 * Math.PI)) * 60) % 60;
        const oldMinute = state.interactiveTime.minute;

        if (newMinute !== oldMinute) {
            // Track minute hand rotation wrapping to increment/decrement hours
            const diff = newMinute - oldMinute;
            
            if (diff > 30) {
                // Wrapped counter-clockwise (e.g., from 0 to 59) -> decrement hour
                state.interactiveTime.hour = (state.interactiveTime.hour - 1 - 1 + 12) % 12 + 1;
            } else if (diff < -30) {
                // Wrapped clockwise (e.g., from 59 to 0) -> increment hour
                state.interactiveTime.hour = (state.interactiveTime.hour % 12) + 1;
            }

            state.interactiveTime.minute = newMinute;
            timeChanged = true;
        }

    } else if (state.dragState.target === 'hour') {
        // Dragging the Hour Hand (Synchronous dual-movement)
        // Hour hand position reflects the entire time block (Hour + Minute fraction)
        const hourFraction = (angle / (2 * Math.PI)) * 12; // 0.0 to 12.0
        const totalMinutes = Math.round(hourFraction * 60) % 720; // 0 to 719 minutes in 12 hours

        const newHour = Math.floor(totalMinutes / 60) || 12;
        const newMinute = totalMinutes % 60;

        if (newHour !== state.interactiveTime.hour || newMinute !== state.interactiveTime.minute) {
            state.interactiveTime.hour = newHour;
            state.interactiveTime.minute = newMinute;
            timeChanged = true;
        }
    }

    if (timeChanged) {
        updateInteractiveDisplay();
        if (state.safeModeActive) {
            trackSafeCombination(direction);
        } else {
            playSound('tick');
        }
    }
}

// Dragging completed
function handlePointerUp(e) {
    if (state.dragState.isDragging) {
        state.dragState.isDragging = false;
        state.dragState.target = null;
        state.safeLastAngle = null;

        if (state.safeModeActive && !state.safeOpened) {
            // Final check on pointer release
            if (state.safeStep === 2 && state.safeTargetReached[2]) {
                unlockSafe();
            }
        }
    }
}


// ----------------------------------------------------
// 7-SEGMENT DIGITAL WATCH VISUALIZATION LOGIC
// ----------------------------------------------------

// Segment mapping for digits 0-9
const SEGMENT_MAP = {
    0: ['a', 'b', 'c', 'd', 'e', 'f'],
    1: ['b', 'c'],
    2: ['a', 'b', 'd', 'e', 'g'],
    3: ['a', 'b', 'c', 'd', 'g'],
    4: ['b', 'c', 'f', 'g'],
    5: ['a', 'c', 'd', 'f', 'g'],
    6: ['a', 'c', 'd', 'e', 'f', 'g'],
    7: ['a', 'b', 'c'],
    8: ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
    9: ['a', 'b', 'c', 'd', 'f', 'g']
};

// Update active segments for all digits
function update7SegmentDisplay(hour, minute) {
    // Format hour and minute as strings with leading zero (e.g. "08", "45")
    const hStr = String(hour).padStart(2, '0');
    const mStr = String(minute).padStart(2, '0');

    // Update each digit
    updateDigitSegments('digit-h1', parseInt(hStr[0]), 'active-hour', 'val-digit-h1');
    updateDigitSegments('digit-h2', parseInt(hStr[1]), 'active-hour', 'val-digit-h2');
    updateDigitSegments('digit-m1', parseInt(mStr[0]), 'active-mint', 'val-digit-m1');
    updateDigitSegments('digit-m2', parseInt(mStr[1]), 'active-minu', 'val-digit-m2');
}

// Helper to activate segments for a specific digit container
function updateDigitSegments(digitId, value, activeClass, valueId) {
    const digitContainer = document.getElementById(digitId);
    if (!digitContainer) return;

    // Get list of active segments for this digit value
    const activeSegments = SEGMENT_MAP[value] || [];

    // Find all segment polygons in this digit container
    const segments = digitContainer.querySelectorAll('.segment');
    segments.forEach(seg => {
        const segLetter = seg.getAttribute('data-segment');
        if (activeSegments.includes(segLetter)) {
            seg.classList.add(activeClass);
        } else {
            seg.classList.remove(activeClass);
        }
    });

    // Update numerical value indicator text
    const valIndicator = document.getElementById(valueId);
    if (valIndicator) {
        valIndicator.textContent = value;
    }
}


// ----------------------------------------------------
// FEEDBACKS, TOASTS & MODALS
// ----------------------------------------------------

// Show sliding status toast feedback messages
function showToast(message, type, icon) {
    const toast = document.getElementById('toast-feedback');
    const toastIcon = toast.querySelector('.toast-icon');
    const toastMsg = toast.querySelector('.toast-message');

    toast.className = 'toast-feedback'; // reset
    toast.classList.add(type === 'success' ? 'success' : 'fail');
    
    toastIcon.textContent = icon;
    toastMsg.textContent = message;

    toast.classList.add('visible');

    setTimeout(() => {
        toast.classList.remove('visible');
    }, 1500);
}

// Game Over Presentation
function showGameOver() {
    const modal = document.getElementById('game-over-modal');
    document.getElementById('final-score').textContent = state.score;
    document.getElementById('modal-high-score').textContent = state.highScore;
    modal.classList.add('active');
}

// Show Milestone celebration victory
function showMilestoneVictory() {
    const modal = document.getElementById('victory-modal');
    const badgeTitle = document.getElementById('badge-title');
    const victoryMsg = document.getElementById('victory-msg');
    
    victoryMsg.textContent = `You answered ${state.streak} questions correctly in a row!`;

    // Tailored milestones badges
    if (state.streak === 5) {
        badgeTitle.textContent = "Clock Apprentice";
    } else if (state.streak === 10) {
        badgeTitle.textContent = "Time Scholar";
    } else if (state.streak === 15) {
        badgeTitle.textContent = "Chronos Champion";
    } else {
        badgeTitle.textContent = "Time Lord";
    }

    modal.classList.add('active');
    playSound('celebrate');
}

// Hide Modals
function hideModal(id) {
    document.getElementById(id).classList.remove('active');
}


// ----------------------------------------------------
// UTILITY HELPERS
// ----------------------------------------------------

// Simple modern shuffle array algorithm
function shuffleArray(array) {
    const arr = [...array];
    for (let i = arr.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
}


// ----------------------------------------------------
// SAFE LOCK GAME MODE LOGIC (MOVIE COMBINATION STYLE)
// ----------------------------------------------------

function toggleSafeMode() {
    state.safeModeActive = !state.safeModeActive;
    
    const safeToggle = document.getElementById('safe-mode-toggle');
    const safePanel = document.getElementById('safe-game-panel');
    const clockContainer = document.getElementById('interactive-clock-container');
    
    if (state.safeModeActive) {
        safeToggle.classList.add('active');
        safeToggle.innerHTML = '<span class="safe-icon">🔓</span> Safe Active';
        safePanel.classList.remove('hidden');
        clockContainer.classList.add('safe-mode-active');
        generateSafeCombination();
    } else {
        safeToggle.classList.remove('active');
        safeToggle.innerHTML = '<span class="safe-icon">🔒</span> Safe Mode';
        safePanel.classList.add('hidden');
        clockContainer.classList.remove('safe-mode-active');
        
        // Hide treasure box if lingering
        const treasureBox = document.getElementById('safe-treasure-box');
        if (treasureBox) treasureBox.classList.add('hidden');
    }
}

function generateSafeCombination() {
    state.safeOpened = false;
    state.safeStep = 0;
    state.safeTargetReached = [false, false, false];
    state.safeLastAngle = null;

    // Hide treasure box
    const treasureBox = document.getElementById('safe-treasure-box');
    if (treasureBox) {
        treasureBox.classList.add('hidden');
    }

    // Generate 3 target positions (minutes 0 to 59)
    // aligned to 5-minute ticks to make it readable and child-friendly
    const combination = [];
    for (let i = 0; i < 3; i++) {
        let val;
        do {
            val = Math.floor(Math.random() * 12) * 5;
        } while (combination.includes(val) || (i > 0 && Math.abs(val - combination[i-1]) < 10));
        combination.push(val);
    }
    state.safeCombination = combination;
    state.safeDirections = ['CW', 'CCW', 'CW']; // Right, Left, Right

    // Update UI step indicator text labels
    for (let i = 0; i < 3; i++) {
        const targetLabel = document.getElementById(`target-step-${i}`);
        if (targetLabel) {
            targetLabel.textContent = combination[i];
        }
    }

    const statusBadge = document.getElementById('safe-status');
    if (statusBadge) {
        statusBadge.textContent = 'LOCKED 🔒';
        statusBadge.classList.remove('unlocked');
    }

    updateSafeUIIndicators(false);
}

function trackSafeCombination(direction) {
    if (state.safeOpened) return;

    const currentMin = state.interactiveTime.minute;
    const currentStep = state.safeStep;
    const targetMin = state.safeCombination[currentStep];
    const expectedDir = state.safeDirections[currentStep];

    // Check distance with modular arithmetic (wrapping around 60 mins)
    // Accepting ±3 minutes error margin (~5% error of 60 positions)
    const diff = Math.abs(currentMin - targetMin);
    const distance = Math.min(diff, 60 - diff);
    const onTarget = distance <= 3;

    updateSafeUIIndicators(onTarget);

    if (onTarget) {
        // "with no sound when its correct" -> suppress safe clicking sound when inside target range!
        state.safeTargetReached[currentStep] = true;
    } else {
        playSound('safe_click');
    }

    if (direction !== null && direction !== expectedDir) {
        // Rotation reversal detected
        if (state.safeTargetReached[currentStep]) {
            // Reached target and reversed -> Lock in the step!
            if (currentStep < 2) {
                state.safeStep++;
                playSound('tick'); // Distinct mechanical thud click
                updateSafeUIIndicators(false);
                showToast(`Step ${currentStep + 1} locked in! 🔓`, 'success', '🔑');
            } else {
                unlockSafe();
            }
        } else if (state.safeStep > 0 || state.safeTargetReached[0]) {
            // Resets sequence only if they had made active progress
            resetSafeCombinationProgress();
            playSound('incorrect');
            showToast('Combination reset! Start over.', 'fail', '🔒');
        }
    }
}

function resetSafeCombinationProgress() {
    state.safeStep = 0;
    state.safeTargetReached = [false, false, false];
    updateSafeUIIndicators(false);
}

function updateSafeUIIndicators(onTarget) {
    for (let i = 0; i < 3; i++) {
        const indicator = document.getElementById(`indicator-step-${i}`);
        if (!indicator) continue;

        indicator.className = 'safe-step-indicator';
        if (i < state.safeStep) {
            indicator.classList.add('completed');
        } else if (i === state.safeStep) {
            indicator.classList.add('current');
            if (onTarget) {
                indicator.style.borderColor = 'var(--green-correct)';
            } else {
                indicator.style.borderColor = '';
            }
        }
    }
}

function unlockSafe() {
    state.safeOpened = true;
    playSound('celebrate');
    
    const statusBadge = document.getElementById('safe-status');
    if (statusBadge) {
        statusBadge.textContent = 'OPENED 🔓';
        statusBadge.classList.add('unlocked');
    }

    // Reveal treasure box
    const treasureBox = document.getElementById('safe-treasure-box');
    if (treasureBox) {
        treasureBox.classList.remove('hidden');
    }

    showToast('Cassaforte unlocked! 🎁', 'success', '👑');
}

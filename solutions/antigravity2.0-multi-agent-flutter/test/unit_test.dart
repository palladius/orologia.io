import 'package:flutter_test/flutter_test.dart';
import 'package:orologia_io/models/clock_time.dart';
import 'package:orologia_io/models/difficulty.dart';
import 'package:orologia_io/models/safe_step.dart';
import 'package:orologia_io/services/time_generator.dart';
import 'package:orologia_io/services/audio_service.dart';
import 'package:orologia_io/state/game_notifier.dart';
import 'package:orologia_io/state/quiz_notifier.dart';
import 'package:orologia_io/state/sandbox_notifier.dart';
import 'package:orologia_io/state/safe_lock_notifier.dart';

void main() {
  group('ClockTime Model Tests', () {
    test('Constructor validation', () {
      expect(() => ClockTime(-1, 0), throwsAssertionError);
      expect(() => ClockTime(24, 0), throwsAssertionError);
      expect(() => ClockTime(12, -1), throwsAssertionError);
      expect(() => ClockTime(12, 60), throwsAssertionError);
      
      const time = ClockTime(15, 45);
      expect(time.hour, 15);
      expect(time.minute, 45);
    });

    test('String formatting and parsing', () {
      const time = ClockTime(3, 5);
      expect(time.toFormattedString(), '03:05');
      expect(time.toString(), '03:05');

      final parsed = ClockTime.fromString('15:45');
      expect(parsed, const ClockTime(15, 45));

      final parsedSingleDigit = ClockTime.fromString('3:05');
      expect(parsedSingleDigit, const ClockTime(3, 5));

      expect(ClockTime.fromString('invalid'), isNull);
      expect(ClockTime.fromString('24:00'), isNull);
      expect(ClockTime.fromString('12:60'), isNull);
    });

    test('Hour 12-hour normalization', () {
      expect(const ClockTime(0, 0).hour12, 12);
      expect(const ClockTime(12, 0).hour12, 12);
      expect(const ClockTime(13, 0).hour12, 1);
      expect(const ClockTime(23, 0).hour12, 11);
    });

    test('Hand angles logic', () {
      const time3 = ClockTime(3, 0);
      expect(time3.hourAngleDegrees, 90.0);
      expect(time3.minuteAngleDegrees, 0.0);

      const time330 = ClockTime(3, 30);
      expect(time330.hourAngleDegrees, 105.0);
      expect(time330.minuteAngleDegrees, 180.0);

      expect(time3.hourAngleRadians, closeTo(3.141592653589793 / 2, 0.001));
    });
  });

  group('TimeGenerator & Distractor Algorithms Tests', () {
    final generator = TimeGenerator();

    test('Easy Level Generation Constraints', () {
      final question = generator.generateQuestion(Difficulty.easy);
      
      expect([0, 30].contains(question.targetTime.minute), isTrue);
      expect(question.options.length, 4);
      expect(question.options.toSet().length, 4);

      for (final option in question.options) {
        expect([0, 30].contains(option.minute), isTrue, 
            reason: 'Distractor $option minutes must be 0 or 30');
      }
    });

    test('Medium Level Generation Constraints', () {
      final question = generator.generateQuestion(Difficulty.medium);
      
      const mediumMinutes = [0, 15, 30, 45];
      expect(mediumMinutes.contains(question.targetTime.minute), isTrue);
      expect(question.options.length, 4);
      expect(question.options.toSet().length, 4);

      for (final option in question.options) {
        expect(mediumMinutes.contains(option.minute), isTrue,
            reason: 'Distractor $option minutes must be 0, 15, 30, or 45');
      }
    });

    test('Swap Hands Transposition (Medium & Hard)', () {
      const target = ClockTime(3, 45);
      
      int newHour = (target.minute ~/ 5) % 12;
      if (newHour == 0) newHour = 12;
      int newMin = (target.hour * 5) % 60;
      newMin = ((newMin + 7) ~/ 15) * 15 % 60;
      final swapped = ClockTime(newHour, newMin);
      
      expect(swapped, const ClockTime(9, 15));

      const targetMidnight = ClockTime(12, 0);
      int midnightH = (targetMidnight.minute ~/ 5) % 12;
      if (midnightH == 0) midnightH = 12;
      int midnightM = (targetMidnight.hour * 5) % 60;
      expect(ClockTime(midnightH, midnightM), const ClockTime(12, 0));
    });

    test('Hard Level Generation Constraints', () {
      final question = generator.generateQuestion(Difficulty.hard);
      
      expect(question.options.length, 4);
      expect(question.options.toSet().length, 4);

      for (final option in question.options) {
        if (option != question.targetTime) {
          expect(option.hour, inClosedOpenRange(0, 24));
          expect(option.minute, inClosedOpenRange(0, 60));
        }
      }
    });
  });

  group('GameNotifier Tests', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier();
    });

    test('Initial State', () {
      expect(notifier.score, 0);
      expect(notifier.lives, 3);
      expect(notifier.isGameOver, isFalse);
      expect(notifier.soundEnabled, isTrue);
    });

    test('Score Progression', () {
      notifier.incrementScore(amount: 10);
      expect(notifier.score, 10);

      notifier.incrementScore(amount: 15);
      expect(notifier.score, 25);

      notifier.decrementScore(amount: 30);
      expect(notifier.score, 0);
    });

    test('Life Progression & Game Over', () {
      notifier.decrementLife();
      expect(notifier.lives, 2);
      expect(notifier.isGameOver, isFalse);

      notifier.decrementLife();
      notifier.decrementLife();
      expect(notifier.lives, 0);
      expect(notifier.isGameOver, isTrue);

      notifier.incrementScore();
      expect(notifier.score, 0);
    });

    test('Settings Sound Toggle', () {
      notifier.toggleSound();
      expect(notifier.soundEnabled, isFalse);

      notifier.setSoundEnabled(true);
      expect(notifier.soundEnabled, isTrue);
    });

    test('Reset state', () {
      notifier.incrementScore(amount: 50);
      notifier.decrementLife();
      notifier.reset();

      expect(notifier.score, 0);
      expect(notifier.lives, 3);
    });
  });

  group('QuizNotifier Tests', () {
    late GameNotifier gameNotifier;
    late QuizNotifier quizNotifier;

    setUp(() {
      gameNotifier = GameNotifier();
      quizNotifier = QuizNotifier(gameNotifier: gameNotifier);
    });

    test('Load Next Question State Progression', () {
      expect(quizNotifier.status, QuizStatus.active);
      expect(quizNotifier.currentQuestion, isNotNull);
      expect(quizNotifier.selectedOption, isNull);
    });

    test('Answering Correctly', () {
      final question = quizNotifier.currentQuestion!;
      final target = question.targetTime;
      
      quizNotifier.checkAnswer(target);
      
      expect(quizNotifier.status, QuizStatus.answeredCorrect);
      expect(quizNotifier.selectedOption, target);
      expect(gameNotifier.score, 10);
      expect(gameNotifier.lives, 3);
    });

    test('Answering Incorrectly', () {
      final question = quizNotifier.currentQuestion!;
      final wrongOption = question.options.firstWhere((opt) => opt != question.targetTime);
      
      quizNotifier.checkAnswer(wrongOption);
      
      expect(quizNotifier.status, QuizStatus.answeredIncorrect);
      expect(quizNotifier.selectedOption, wrongOption);
      expect(gameNotifier.score, 0);
      expect(gameNotifier.lives, 2);
    });

    test('Blocking further taps', () {
      final question = quizNotifier.currentQuestion!;
      final target = question.targetTime;
      
      quizNotifier.checkAnswer(target);
      expect(quizNotifier.status, QuizStatus.answeredCorrect);
      
      final wrongOption = question.options.firstWhere((opt) => opt != question.targetTime);
      quizNotifier.checkAnswer(wrongOption);
      
      expect(quizNotifier.status, QuizStatus.answeredCorrect);
      expect(quizNotifier.selectedOption, target);
      expect(gameNotifier.score, 10);
    });
  });

  group('SandboxNotifier Tests', () {
    late SandboxNotifier notifier;

    setUp(() {
      notifier = SandboxNotifier(initialTime: const ClockTime(11, 50));
    });

    test('Time Adjustments Rollover', () {
      notifier.add15Minutes();
      expect(notifier.currentTime, const ClockTime(12, 5));

      notifier.subtract15Minutes();
      expect(notifier.currentTime, const ClockTime(11, 50));

      notifier.addHour();
      expect(notifier.currentTime, const ClockTime(12, 50));

      notifier.subtractHour();
      expect(notifier.currentTime, const ClockTime(11, 50));

      notifier.currentTime = const ClockTime(23, 59);
      notifier.add1Minute();
      expect(notifier.currentTime, const ClockTime(0, 0));

      notifier.subtract1Minute();
      expect(notifier.currentTime, const ClockTime(23, 59));
    });

    test('Drag Angle Mapping to Minutes', () {
      notifier.updateTimeFromMinuteAngle(0);
      expect(notifier.currentTime.minute, 0);

      notifier.updateTimeFromMinuteAngle(90);
      expect(notifier.currentTime.minute, 15);

      notifier.updateTimeFromMinuteAngle(180);
      expect(notifier.currentTime.minute, 30);

      notifier.updateTimeFromMinuteAngle(270);
      expect(notifier.currentTime.minute, 45);

      notifier.updateTimeFromMinuteAngle(-90);
      expect(notifier.currentTime.minute, 45);
    });

    test('Drag Angle Mapping to Hours', () {
      notifier.updateTimeFromHourAngle(0);
      expect(notifier.currentTime.hour12, 12);

      notifier.updateTimeFromHourAngle(90);
      expect(notifier.currentTime.hour12, 3);

      notifier.updateTimeFromHourAngle(180);
      expect(notifier.currentTime.hour12, 6);

      notifier.updateTimeFromHourAngle(330);
      expect(notifier.currentTime.hour12, 11);
    });
  });

  group('SafeLockNotifier Tests', () {
    late SafeLockNotifier notifier;

    setUp(() {
      AudioService.enableSound = false;
      AudioService.playedSounds.clear();
      notifier = SafeLockNotifier();
    });

    test('Initialization', () {
      expect(notifier.status, SafeStatus.locked);
      expect(notifier.currentStepIndex, 0);
      expect(notifier.dialMinute, 0);
      expect(notifier.steps.length, 3);
    });

    void rotateDial(SafeLockNotifier notifier, int start, int end, RotationDirection direction) {
      int current = start;
      while (current != end) {
        if (direction == RotationDirection.cw) {
          current = (current + 1) % 60;
        } else {
          current = (current - 1 + 60) % 60;
        }
        notifier.rotateTo(current);
      }
    }

    test('Start rotating in correct direction', () {
      rotateDial(notifier, 0, 5, RotationDirection.cw);
      expect(notifier.status, SafeStatus.rotating);
      expect(notifier.dialMinute, 5);
      expect(notifier.currentStepIndex, 0);
    });

    test('Click Sound Proximity Silence Zone', () {
      AudioService.playedSounds.clear();

      rotateDial(notifier, 0, 1, RotationDirection.cw);
      expect(AudioService.playedSounds.last, 'click');

      AudioService.playedSounds.clear();

      rotateDial(notifier, 16, 17, RotationDirection.cw);
      expect(AudioService.playedSounds.contains('click'), isFalse);

      rotateDial(notifier, 17, 20, RotationDirection.cw);
      expect(AudioService.playedSounds.contains('click'), isFalse);
    });

    test('Reverse direction inside target margin advances step', () {
      rotateDial(notifier, 0, 19, RotationDirection.cw);
      
      notifier.rotateTo(18);
      
      expect(notifier.currentStepIndex, 1);
      expect(notifier.status, SafeStatus.rotating);
    });

    test('Reverse direction outside target margin resets lock', () {
      rotateDial(notifier, 0, 10, RotationDirection.cw);
      
      notifier.rotateTo(9);
      
      expect(notifier.currentStepIndex, 0);
      expect(notifier.status, SafeStatus.locked);
    });

    test('Overshooting past target margin resets lock', () {
      rotateDial(notifier, 0, 20, RotationDirection.cw);
      rotateDial(notifier, 20, 22, RotationDirection.cw);
      expect(notifier.status, SafeStatus.rotating);
      
      rotateDial(notifier, 22, 24, RotationDirection.cw);
      expect(notifier.status, SafeStatus.locked);
      expect(notifier.currentStepIndex, 0);
    });

    test('Dial release inside vs outside target margin', () {
      // 1. Inside margin release
      rotateDial(notifier, 0, 20, RotationDirection.cw);
      notifier.releaseDial();
      expect(notifier.currentStepIndex, 1);

      // 2. Outside margin release (rotate to 50 CCW where target is 40 CCW, distance is 10 > 3, not overshot yet)
      rotateDial(notifier, 20, 50, RotationDirection.ccw);
      notifier.releaseDial();
      expect(notifier.currentStepIndex, 1);
      expect(notifier.status, SafeStatus.rotating);
    });

    test('Successful 3-step combination unlocking', () {
      rotateDial(notifier, 0, 20, RotationDirection.cw);
      notifier.rotateTo(19);

      expect(notifier.currentStepIndex, 1);

      rotateDial(notifier, 19, 40, RotationDirection.ccw);
      notifier.rotateTo(41);

      expect(notifier.currentStepIndex, 2);

      rotateDial(notifier, 41, 10, RotationDirection.cw);
      notifier.releaseDial();

      expect(notifier.status, SafeStatus.unlocked);
    });
  });
}

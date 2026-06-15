import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orologia_io/main.dart';
import 'package:orologia_io/models/clock_time.dart';
import 'package:orologia_io/models/difficulty.dart';
import 'package:orologia_io/services/time_generator.dart';
import 'package:orologia_io/state/game_notifier.dart';
import 'package:orologia_io/state/quiz_notifier.dart';
import 'package:orologia_io/state/sandbox_notifier.dart';
import 'package:orologia_io/state/safe_lock_notifier.dart';
import 'package:orologia_io/views/widgets/analog_clock.dart';
import 'package:orologia_io/views/widgets/segment_display.dart';

void main() {
  group('TimeGenerator Tests', () {
    test('Easy mode generator contains target and 3 distractors restricted to :00 or :30', () {
      final generator = TimeGenerator();
      final question = generator.generateQuestion(Difficulty.easy);
      
      expect(question.options.length, 4);
      expect(question.options.contains(question.targetTime), true);
      
      expect(question.options.toSet().length, 4);
      
      for (final opt in question.options) {
        expect(opt.minute == 0 || opt.minute == 30, true);
      }
    });

    test('Medium mode generator contains target and 3 distractors restricted to quarters', () {
      final generator = TimeGenerator();
      final question = generator.generateQuestion(Difficulty.medium);
      
      expect(question.options.length, 4);
      expect(question.options.contains(question.targetTime), true);
      
      expect(question.options.toSet().length, 4);
      
      final validMinutes = [0, 15, 30, 45];
      for (final opt in question.options) {
        expect(validMinutes.contains(opt.minute), true);
      }
    });
  });

  group('Widget Tests', () {
    late GameNotifier gameNotifier;
    late QuizNotifier quizNotifier;
    late SandboxNotifier sandboxNotifier;
    late SafeLockNotifier safeLockNotifier;

    setUp(() {
      gameNotifier = GameNotifier();
      quizNotifier = QuizNotifier(gameNotifier: gameNotifier);
      sandboxNotifier = SandboxNotifier();
      safeLockNotifier = SafeLockNotifier();
    });

    testWidgets('HomeScreen renders Orologia.io title and modes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          gameNotifier: gameNotifier,
          quizNotifier: quizNotifier,
          sandboxNotifier: sandboxNotifier,
          safeLockNotifier: safeLockNotifier,
        ),
      );

      expect(find.text('Orologia.io'), findsOneWidget);
      expect(find.text('Time Master ⏰'), findsOneWidget);

      expect(find.text('Analog ➔ Digital'), findsOneWidget);
      expect(find.text('Digital ➔ Analog'), findsOneWidget);
      expect(find.text('Sandbox Mode'), findsOneWidget);
      expect(find.text('Safe Lock'), findsOneWidget);
    });

    testWidgets('AnalogClock custom painter renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: AnalogClock(
                time: ClockTime(10, 10),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('SevenSegmentDisplay renders digits and colon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SevenSegmentDisplay(
              time: ClockTime(12, 34),
            ),
          ),
        ),
      );

      expect(find.byType(SevenSegmentDisplay), findsOneWidget);
      expect(find.byType(SevenSegmentDigit), findsNWidgets(4));
    });
  });
}

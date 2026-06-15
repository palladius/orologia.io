import 'package:flutter/material.dart';
import 'state/game_notifier.dart';
import 'state/quiz_notifier.dart';
import 'state/sandbox_notifier.dart';
import 'state/safe_lock_notifier.dart';
import 'views/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final gameNotifier = GameNotifier();
  final quizNotifier = QuizNotifier(gameNotifier: gameNotifier);
  final sandboxNotifier = SandboxNotifier();
  final safeLockNotifier = SafeLockNotifier();

  runApp(MyApp(
    gameNotifier: gameNotifier,
    quizNotifier: quizNotifier,
    sandboxNotifier: sandboxNotifier,
    safeLockNotifier: safeLockNotifier,
  ));
}

class MyApp extends StatelessWidget {
  final GameNotifier gameNotifier;
  final QuizNotifier quizNotifier;
  final SandboxNotifier sandboxNotifier;
  final SafeLockNotifier safeLockNotifier;

  const MyApp({
    super.key,
    required this.gameNotifier,
    required this.quizNotifier,
    required this.sandboxNotifier,
    required this.safeLockNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orologia.io',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C1033),
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.pinkAccent,
          surface: Color(0xFF180B30),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        gameNotifier: gameNotifier,
        quizNotifier: quizNotifier,
        sandboxNotifier: sandboxNotifier,
        safeLockNotifier: safeLockNotifier,
      ),
    );
  }
}

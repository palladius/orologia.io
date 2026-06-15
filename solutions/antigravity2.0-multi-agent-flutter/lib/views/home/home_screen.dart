import 'package:flutter/material.dart';
import '../../models/difficulty.dart';
import '../../state/game_notifier.dart';
import '../../state/quiz_notifier.dart';
import '../../state/sandbox_notifier.dart';
import '../../state/safe_lock_notifier.dart';
import '../widgets/glass_card.dart';
import '../quiz/quiz_screen.dart';
import '../sandbox/sandbox_screen.dart';
import '../safe_lock/safe_lock_screen.dart';

class HomeScreen extends StatelessWidget {
  final GameNotifier gameNotifier;
  final QuizNotifier quizNotifier;
  final SandboxNotifier sandboxNotifier;
  final SafeLockNotifier safeLockNotifier;

  const HomeScreen({
    super.key,
    required this.gameNotifier,
    required this.quizNotifier,
    required this.sandboxNotifier,
    required this.safeLockNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E0854),
              Color(0xFF180B30),
              Color(0xFF0C1033),
            ],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: gameNotifier,
            builder: (context, _) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Cute App Logo / Title
                      const Icon(
                        Icons.alarm,
                        size: 80,
                        color: Colors.cyanAccent,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Orologia.io',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Text(
                        'Time Master ⏰',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Difficulty & Sound Config Card
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Difficulty:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                DropdownButton<Difficulty>(
                                  value: gameNotifier.difficulty,
                                  dropdownColor: const Color(0xFF180B30),
                                  iconEnabledColor: Colors.cyanAccent,
                                  underline: Container(),
                                  style: const TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  items: Difficulty.values.map((diff) {
                                    return DropdownMenuItem<Difficulty>(
                                      value: diff,
                                      child: Text(diff.displayName),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      gameNotifier.setDifficulty(val);
                                      quizNotifier.loadNextQuestion();
                                    }
                                  },
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sound Effects:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: gameNotifier.soundEnabled,
                                  activeColor: Colors.cyanAccent,
                                  activeTrackColor: Colors.cyan.withOpacity(0.3),
                                  onChanged: (val) {
                                    gameNotifier.toggleSound();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Game Modes Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          _buildModeCard(
                            context: context,
                            title: 'Analog ➔ Digital',
                            icon: Icons.hourglass_top,
                            color: Colors.pinkAccent,
                            onTap: () {
                              quizNotifier.loadNextQuestion();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizScreen(
                                    quizNotifier: quizNotifier,
                                    isAnalogToDigital: true,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildModeCard(
                            context: context,
                            title: 'Digital ➔ Analog',
                            icon: Icons.hourglass_bottom,
                            color: Colors.purpleAccent,
                            onTap: () {
                              quizNotifier.loadNextQuestion();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizScreen(
                                    quizNotifier: quizNotifier,
                                    isAnalogToDigital: false,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildModeCard(
                            context: context,
                            title: 'Sandbox Mode',
                            icon: Icons.gesture,
                            color: Colors.cyanAccent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SandboxScreen(
                                    sandboxNotifier: sandboxNotifier,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildModeCard(
                            context: context,
                            title: 'Safe Lock',
                            icon: Icons.lock_open,
                            color: Colors.amberAccent,
                            onTap: () {
                              safeLockNotifier.resetLock();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SafeLockScreen(
                                    safeLockNotifier: safeLockNotifier,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Total Score: ${gameNotifier.score}  🏆',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/clock_time.dart';
import '../../models/time_question.dart';
import '../../state/quiz_notifier.dart';
import '../widgets/analog_clock.dart';
import '../widgets/glass_card.dart';
import '../widgets/segment_display.dart';

class QuizScreen extends StatelessWidget {
  final QuizNotifier quizNotifier;
  final bool isAnalogToDigital;

  const QuizScreen({
    super.key,
    required this.quizNotifier,
    required this.isAnalogToDigital,
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
            listenable: quizNotifier,
            builder: (context, _) {
              final status = quizNotifier.status;
              final question = quizNotifier.currentQuestion;
              final game = quizNotifier.gameNotifier;

              if (game.isGameOver) {
                return _buildGameOverScreen(context);
              }

              return Column(
                children: [
                  _buildHeader(context, game),

                  Expanded(
                    child: status == QuizStatus.loading || question == null
                        ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isAnalogToDigital ? 'What is this time?' : 'Which clock is correct?',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                if (isAnalogToDigital)
                                  Container(
                                    height: 200,
                                    width: 200,
                                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: AnalogClock(
                                      time: question.targetTime,
                                    ),
                                  )
                                else
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 12.0),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: SevenSegmentDisplay(
                                      time: question.targetTime,
                                      digitWidth: 26,
                                      digitHeight: 52,
                                    ),
                                  ),

                                const SizedBox(height: 12),
                                _buildFeedbackText(status),
                                const SizedBox(height: 8),

                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 450),
                                    child: isAnalogToDigital
                                        ? _buildDigitalOptions(context, question, status)
                                        : _buildAnalogOptions(context, question, status),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                if (status == QuizStatus.answeredCorrect || status == QuizStatus.answeredIncorrect)
                                  ElevatedButton(
                                    onPressed: () {
                                      quizNotifier.loadNextQuestion(game.difficulty);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyanAccent,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      'Next Level ➔',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic game) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: 12,
            child: Text(
              'Score: ${game.score}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Row(
            children: List.generate(3, (index) {
              return Icon(
                index < game.lives ? Icons.favorite : Icons.favorite_border,
                color: Colors.pinkAccent,
                size: 28,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackText(QuizStatus status) {
    if (status == QuizStatus.answeredCorrect) {
      return const Text(
        'SUPER! 🎉 Correct!',
        style: TextStyle(
          color: Colors.greenAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (status == QuizStatus.answeredIncorrect) {
      return const Text(
        'OH NO! 😢 Try again!',
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return const SizedBox(height: 8);
  }

  Widget _buildDigitalOptions(BuildContext context, TimeQuestion question, QuizStatus status) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = quizNotifier.selectedOption == option;
        final isCorrect = question.targetTime == option;

        Color cardColor = Colors.white.withOpacity(0.08);
        Color borderColor = Colors.white24;

        if (status == QuizStatus.answeredCorrect || status == QuizStatus.answeredIncorrect) {
          if (isCorrect) {
            cardColor = Colors.green.withOpacity(0.25);
            borderColor = Colors.greenAccent;
          } else if (isSelected) {
            cardColor = Colors.red.withOpacity(0.25);
            borderColor = Colors.redAccent;
          }
        }

        return GestureDetector(
          onTap: status == QuizStatus.active ? () => quizNotifier.checkAnswer(option) : null,
          child: GlassCard(
            color: cardColor,
            borderRadius: 16,
            padding: EdgeInsets.zero,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Text(
                option.toFormattedString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalogOptions(BuildContext context, TimeQuestion question, QuizStatus status) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = quizNotifier.selectedOption == option;
        final isCorrect = question.targetTime == option;

        Color borderColor = Colors.white24;

        if (status == QuizStatus.answeredCorrect || status == QuizStatus.answeredIncorrect) {
          if (isCorrect) {
            borderColor = Colors.greenAccent;
          } else if (isSelected) {
            borderColor = Colors.redAccent;
          }
        }

        return GestureDetector(
          onTap: status == QuizStatus.active ? () => quizNotifier.checkAnswer(option) : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: isSelected || isCorrect ? 3.0 : 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12.0),
            child: AnalogClock(
              time: option,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameOverScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videogame_asset_off,
                size: 72,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'GAME OVER! 👾',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Final Score: ${quizNotifier.gameNotifier.score} points',
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  quizNotifier.restartQuiz();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Play Again 🔄',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back to Main Menu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

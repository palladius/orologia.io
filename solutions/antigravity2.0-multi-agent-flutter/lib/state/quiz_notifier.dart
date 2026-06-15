import 'package:flutter/material.dart';
import '../models/clock_time.dart';
import '../models/difficulty.dart';
import '../models/time_question.dart';
import '../services/time_generator.dart';
import '../services/audio_service.dart';
import 'game_notifier.dart';

enum QuizStatus { loading, active, answeredCorrect, answeredIncorrect }

class QuizNotifier extends ChangeNotifier {
  final GameNotifier gameNotifier;
  final TimeGenerator _generator = TimeGenerator();

  TimeQuestion? _currentQuestion;
  ClockTime? _selectedOption;
  int? _selectedAnswerIndex;
  QuizStatus _status = QuizStatus.loading;

  QuizNotifier({required this.gameNotifier}) {
    loadNextQuestion(gameNotifier.difficulty);
  }

  TimeQuestion? get currentQuestion => _currentQuestion;
  ClockTime? get selectedOption => _selectedOption;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  QuizStatus get status => _status;

  void loadNextQuestion([Difficulty? difficulty]) {
    final diff = difficulty ?? gameNotifier.difficulty;
    _status = QuizStatus.loading;
    notifyListeners();

    _currentQuestion = _generator.generateQuestion(diff);
    _selectedOption = null;
    _selectedAnswerIndex = null;
    _status = QuizStatus.active;
    notifyListeners();
  }

  void submitAnswer(int index) {
    if (_status != QuizStatus.active || _currentQuestion == null) return;
    if (index < 0 || index >= _currentQuestion!.options.length) return;

    _selectedAnswerIndex = index;
    final option = _currentQuestion!.options[index];
    _selectedOption = option;

    _evaluateAnswer(option);
  }

  void checkAnswer(ClockTime option) {
    if (_status != QuizStatus.active || _currentQuestion == null) return;

    _selectedOption = option;
    _selectedAnswerIndex = _currentQuestion!.options.indexOf(option);

    _evaluateAnswer(option);
  }

  void _evaluateAnswer(ClockTime option) {
    if (option == _currentQuestion!.targetTime) {
      _status = QuizStatus.answeredCorrect;
      int reward = 10;
      if (gameNotifier.difficulty == Difficulty.medium) {
        reward = 15;
      } else if (gameNotifier.difficulty == Difficulty.hard) {
        reward = 20;
      }
      gameNotifier.incrementScore(amount: reward);
      AudioService.playSuccess();
    } else {
      _status = QuizStatus.answeredIncorrect;
      gameNotifier.decrementLife();
      AudioService.playFailure();
    }
    notifyListeners();
  }

  void restartQuiz() {
    gameNotifier.reset();
    loadNextQuestion(gameNotifier.difficulty);
  }
}

import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../services/audio_service.dart';

class GameNotifier extends ChangeNotifier {
  int _score = 0;
  int _lives = 3;
  Difficulty _difficulty = Difficulty.easy;
  bool _soundEnabled = true;

  int get score => _score;
  int get lives => _lives;
  Difficulty get difficulty => _difficulty;
  bool get soundEnabled => _soundEnabled;

  bool get isGameOver => _lives <= 0;

  void setDifficulty(Difficulty diff) {
    _difficulty = diff;
    notifyListeners();
  }

  void incrementScore({int amount = 10}) {
    if (isGameOver) return;
    _score += amount;
    notifyListeners();
  }

  void decrementScore({int amount = 10}) {
    _score -= amount;
    if (_score < 0) _score = 0;
    notifyListeners();
  }

  void decrementLife() {
    if (_lives > 0) {
      _lives--;
      notifyListeners();
    }
  }

  void reset() {
    _score = 0;
    _lives = 3;
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    AudioService.enableSound = _soundEnabled;
    notifyListeners();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    AudioService.enableSound = enabled;
    notifyListeners();
  }
}

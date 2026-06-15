import 'package:flutter/material.dart';
import '../models/safe_step.dart';
import '../services/audio_service.dart';

enum SafeStatus { locked, rotating, unlocked }

class SafeLockNotifier extends ChangeNotifier {
  final List<SafeStep> _steps = [
    SafeStep(targetMinute: 20, direction: RotationDirection.cw),
    SafeStep(targetMinute: 40, direction: RotationDirection.ccw),
    SafeStep(targetMinute: 10, direction: RotationDirection.cw),
  ];

  int _currentStepIndex = 0;
  int _dialMinute = 0;
  SafeStatus _status = SafeStatus.locked;
  String _message = 'Rotate Right to 20';

  RotationDirection? _lastDragDirection;

  List<SafeStep> get steps => _steps;
  int get currentStepIndex => _currentStepIndex;
  int get dialMinute => _dialMinute;
  SafeStatus get status => _status;
  String get message => _message;

  void resetLock() {
    _currentStepIndex = 0;
    _dialMinute = 0;
    _status = SafeStatus.locked;
    _lastDragDirection = null;
    _message = 'Rotate Right to 20';
    notifyListeners();
  }

  int getDistanceToTarget(int target, int current) {
    int diff = (current - target).abs();
    return diff > 30 ? 60 - diff : diff;
  }

  void rotateTo(int minute) {
    if (_status == SafeStatus.unlocked) return;
    if (minute == _dialMinute) return;

    int prevMinute = _dialMinute;
    _dialMinute = minute;
    _status = SafeStatus.rotating;

    RotationDirection dir;
    int diff = _dialMinute - prevMinute;
    if (diff == 1 || diff == -59) {
      dir = RotationDirection.cw;
    } else if (diff == -1 || diff == 59) {
      dir = RotationDirection.ccw;
    } else {
      notifyListeners();
      return;
    }

    final targetStep = _steps[_currentStepIndex];
    int dist = getDistanceToTarget(targetStep.targetMinute, _dialMinute);

    if (dist <= 3) {
      // Silence click within error margin
    } else {
      AudioService.playClick();
    }

    if (_lastDragDirection != null && _lastDragDirection != dir) {
      if (getDistanceToTarget(targetStep.targetMinute, prevMinute) <= 3) {
        _completeStep();
      } else {
        _resetCombination();
      }
    } else {
      int prevDist = getDistanceToTarget(targetStep.targetMinute, prevMinute);
      if (prevDist <= 3 && dist > 3) {
        _resetCombination();
      }
    }

    _lastDragDirection = dir;
    notifyListeners();
  }

  void releaseDial() {
    if (_status == SafeStatus.unlocked) return;

    final targetStep = _steps[_currentStepIndex];
    int dist = getDistanceToTarget(targetStep.targetMinute, _dialMinute);

    if (dist <= 3) {
      _completeStep();
    } else {
      _lastDragDirection = null;
    }
    notifyListeners();
  }

  void _completeStep() {
    _currentStepIndex++;
    _lastDragDirection = null;

    if (_currentStepIndex >= _steps.length) {
      _status = SafeStatus.unlocked;
      _message = 'OPENED 🔓';
      AudioService.playCelebration();
    } else {
      final nextStep = _steps[_currentStepIndex];
      _message = 'Step ${_currentStepIndex + 1}: ${nextStep.toString()}';
      AudioService.playSuccess();
    }
  }

  void _resetCombination() {
    _currentStepIndex = 0;
    _lastDragDirection = null;
    _status = SafeStatus.locked;
    _message = 'Reset! Rotate Right to ${_steps[0].targetMinute}';
    AudioService.playFailure();
  }
}

import 'package:flutter/material.dart';
import '../models/clock_time.dart';

class SandboxNotifier extends ChangeNotifier {
  ClockTime _currentTime;

  SandboxNotifier({ClockTime initialTime = const ClockTime(10, 10)})
      : _currentTime = initialTime;

  ClockTime get currentTime => _currentTime;

  set currentTime(ClockTime val) {
    _currentTime = val;
    notifyListeners();
  }

  void add15Minutes() {
    int totalMins = _currentTime.hour * 60 + _currentTime.minute + 15;
    _currentTime = ClockTime((totalMins ~/ 60) % 24, totalMins % 60);
    notifyListeners();
  }

  void subtract15Minutes() {
    int totalMins = _currentTime.hour * 60 + _currentTime.minute - 15;
    if (totalMins < 0) totalMins += 24 * 60;
    _currentTime = ClockTime((totalMins ~/ 60) % 24, totalMins % 60);
    notifyListeners();
  }

  void addHour() {
    _currentTime = ClockTime((_currentTime.hour + 1) % 24, _currentTime.minute);
    notifyListeners();
  }

  void subtractHour() {
    _currentTime = ClockTime((_currentTime.hour - 1 + 24) % 24, _currentTime.minute);
    notifyListeners();
  }

  void add1Minute() {
    int totalMins = _currentTime.hour * 60 + _currentTime.minute + 1;
    _currentTime = ClockTime((totalMins ~/ 60) % 24, totalMins % 60);
    notifyListeners();
  }

  void subtract1Minute() {
    int totalMins = _currentTime.hour * 60 + _currentTime.minute - 1;
    if (totalMins < 0) totalMins += 24 * 60;
    _currentTime = ClockTime((totalMins ~/ 60) % 24, totalMins % 60);
    notifyListeners();
  }

  void addMinutes(int mins) {
    int totalMins = _currentTime.hour * 60 + _currentTime.minute + mins;
    while (totalMins < 0) {
      totalMins += 24 * 60;
    }
    _currentTime = ClockTime((totalMins ~/ 60) % 24, totalMins % 60);
    notifyListeners();
  }

  void updateTimeFromMinuteAngle(double angle) {
    double normAngle = angle % 360.0;
    if (normAngle < 0) normAngle += 360.0;
    int minute = (normAngle / 6.0).round() % 60;
    _currentTime = ClockTime(_currentTime.hour, minute);
    notifyListeners();
  }

  void updateTimeFromHourAngle(double angle) {
    double normAngle = angle % 360.0;
    if (normAngle < 0) normAngle += 360.0;
    int hr12 = (normAngle / 30.0).round() % 12;
    if (hr12 == 0) hr12 = 12;
    int isPm = _currentTime.hour >= 12 ? 12 : 0;
    int targetHour = hr12;
    if (isPm == 12 && hr12 != 12) {
      targetHour += 12;
    } else if (isPm == 0 && hr12 == 12) {
      targetHour = 0;
    }
    _currentTime = ClockTime(targetHour, _currentTime.minute);
    notifyListeners();
  }
}

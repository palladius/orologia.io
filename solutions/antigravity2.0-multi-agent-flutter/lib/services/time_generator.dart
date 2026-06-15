import 'dart:math';
import '../models/clock_time.dart';
import '../models/difficulty.dart';
import '../models/time_question.dart';

class TimeGenerator {
  final Random _random = Random();

  ClockTime _randomTime(Difficulty difficulty) {
    int hour = _random.nextInt(12) + 1; // 1 to 12
    if (difficulty == Difficulty.hard) {
      hour = _random.nextInt(24);
    } else if (difficulty == Difficulty.medium) {
      hour = _random.nextBool() ? _random.nextInt(12) + 1 : _random.nextInt(12) + 13;
      if (hour == 24) hour = 0;
    } else {
      hour = _random.nextInt(12) + 1;
    }

    int minute = 0;
    switch (difficulty) {
      case Difficulty.easy:
        minute = _random.nextBool() ? 0 : 30;
        break;
      case Difficulty.medium:
        final minutes = [0, 15, 30, 45];
        minute = minutes[_random.nextInt(minutes.length)];
        break;
      case Difficulty.hard:
        minute = _random.nextInt(60);
        break;
    }

    return ClockTime(hour, minute);
  }

  TimeQuestion generateQuestion(Difficulty difficulty) {
    ClockTime target = _randomTime(difficulty);
    Set<ClockTime> uniqueOptions = {target};

    int attempts = 0;
    while (uniqueOptions.length < 4 && attempts < 100) {
      attempts++;
      ClockTime distractor;
      if (difficulty == Difficulty.easy) {
        int dType = _random.nextInt(3);
        if (dType == 0) {
          int hShift = _random.nextBool() ? 1 : -1;
          int h = (target.hour + hShift) % 12;
          if (h == 0) h = 12;
          distractor = ClockTime(h, target.minute);
        } else if (dType == 1) {
          int m = target.minute == 0 ? 30 : 0;
          distractor = ClockTime(target.hour, m);
        } else {
          int hShift = _random.nextBool() ? 1 : -1;
          int h = (target.hour + hShift) % 12;
          if (h == 0) h = 12;
          int m = target.minute == 0 ? 30 : 0;
          distractor = ClockTime(h, m);
        }
      } else if (difficulty == Difficulty.medium) {
        int dType = _random.nextInt(3);
        if (dType == 0) {
          int hShift = _random.nextBool() ? 1 : -1;
          int h = (target.hour + hShift) % 24;
          distractor = ClockTime(h, target.minute);
        } else if (dType == 1) {
          int mShift = _random.nextBool() ? 15 : -15;
          int m = (target.minute + mShift) % 60;
          if (m < 0) m += 60;
          distractor = ClockTime(target.hour, m);
        } else {
          int newHour = (target.minute ~/ 5) % 12;
          if (newHour == 0) newHour = 12;
          int newMin = (target.hour * 5) % 60;
          newMin = ((newMin + 7) ~/ 15) * 15 % 60;
          distractor = ClockTime(newHour, newMin);
        }
      } else {
        int dType = _random.nextInt(3);
        if (dType == 0) {
          int mOffset = _random.nextInt(5) + 1;
          if (_random.nextBool()) mOffset = -mOffset;
          int m = (target.minute + mOffset) % 60;
          if (m < 0) m += 60;
          distractor = ClockTime(target.hour, m);
        } else if (dType == 1) {
          int hShift = _random.nextBool() ? (_random.nextBool() ? 1 : -1) : (_random.nextBool() ? 2 : -2);
          int h = (target.hour + hShift) % 24;
          if (h < 0) h += 24;
          distractor = ClockTime(h, target.minute);
        } else {
          int newHour = (target.minute ~/ 5) % 24;
          int newMin = (target.hour * 5) % 60;
          distractor = ClockTime(newHour, newMin);
        }
      }

      distractor = ClockTime(distractor.hour % 24, distractor.minute % 60);
      if (distractor != target) {
        uniqueOptions.add(distractor);
      }
    }

    while (uniqueOptions.length < 4) {
      ClockTime fallback = _randomTime(difficulty);
      if (fallback != target) {
        uniqueOptions.add(fallback);
      }
    }

    List<ClockTime> optionsList = uniqueOptions.toList();
    optionsList.shuffle(_random);
    int correctIndex = optionsList.indexOf(target);

    return TimeQuestion(
      targetTime: target,
      options: optionsList,
      correctIndex: correctIndex,
    );
  }
}

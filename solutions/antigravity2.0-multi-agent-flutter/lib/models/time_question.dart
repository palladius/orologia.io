import 'clock_time.dart';

class TimeQuestion {
  final ClockTime targetTime;
  final List<ClockTime> options;
  final int correctIndex;

  TimeQuestion({
    required this.targetTime,
    required this.options,
    required this.correctIndex,
  });
}

class ClockTime {
  final int hour;
  final int minute;

  const ClockTime(this.hour, this.minute)
      : assert(hour >= 0 && hour < 24, 'Hour must be between 0 and 23'),
        assert(minute >= 0 && minute < 60, 'Minute must be between 0 and 59');

  /// Formats the time as "HH:mm" (e.g., "03:30" or "15:45").
  String toFormattedString() {
    final hStr = hour.toString().padLeft(2, '0');
    final mStr = minute.toString().padLeft(2, '0');
    return '$hStr:$mStr';
  }

  /// Parses a string formatted as "HH:mm" or "H:mm".
  /// Returns null if format is invalid.
  static ClockTime? fromString(String formattedString) {
    final parts = formattedString.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h >= 24 || m < 0 || m >= 60) return null;
    return ClockTime(h, m);
  }

  /// Normalizes the hour to 12-hour format (1 to 12).
  int get hour12 {
    final h12 = hour % 12;
    return h12 == 0 ? 12 : h12;
  }

  /// Calculates the hour hand angle in degrees (0 to 360).
  /// 12:00 corresponds to 0 degrees.
  /// 3:00 is 90 degrees, 6:00 is 180 degrees, etc.
  double get hourAngleDegrees {
    final hNormal = hour % 12;
    return (hNormal * 30.0) + (minute * 0.5);
  }

  /// Calculates the minute hand angle in degrees (0 to 360).
  /// 12:00 corresponds to 0 degrees.
  double get minuteAngleDegrees {
    return minute * 6.0;
  }

  /// Calculates the hour hand angle in radians.
  double get hourAngleRadians {
    return hourAngleDegrees * (3.141592653589793 / 180.0);
  }

  /// Calculates the minute hand angle in radians.
  double get minuteAngleRadians {
    return minuteAngleDegrees * (3.141592653589793 / 180.0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClockTime && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => toFormattedString();
}

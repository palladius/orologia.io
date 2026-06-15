enum RotationDirection { cw, ccw }

class SafeStep {
  final int targetMinute;
  final RotationDirection direction;

  SafeStep({required this.targetMinute, required this.direction});

  @override
  String toString() {
    final dirStr = direction == RotationDirection.cw ? 'Right' : 'Left';
    return '$dirStr to $targetMinute';
  }
}

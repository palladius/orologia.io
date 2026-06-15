import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/clock_time.dart';

enum DraggingHand { hour, minute }

class AnalogClock extends StatefulWidget {
  final ClockTime time;
  final ValueChanged<ClockTime>? onTimeChanged;
  final VoidCallback? onDragEnd;
  final bool isSafeDial;

  const AnalogClock({
    super.key,
    required this.time,
    this.onTimeChanged,
    this.onDragEnd,
    this.isSafeDial = false,
  });

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  DraggingHand? _draggingHand;
  double? _lastAngle;
  double _accumulatedMinutes = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = min(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanStart: (details) {
            if (widget.onTimeChanged == null) return;

            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final Offset localPos = renderBox.globalToLocal(details.globalPosition);
            final Offset center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
            final Offset offset = localPos - center;
            final double distance = offset.distance;
            final double radius = size / 2;

            if (distance < 15 || distance > radius * 1.1) return;

            double touchAngle = atan2(offset.dx, -offset.dy) * 180 / pi;
            if (touchAngle < 0) touchAngle += 360;

            if (widget.isSafeDial) {
              _draggingHand = DraggingHand.minute;
            } else {
              double hourAngle = widget.time.hourAngleDegrees;
              double minAngle = widget.time.minuteAngleDegrees;

              double diffHour = (touchAngle - hourAngle).abs();
              diffHour = diffHour > 180 ? 360 - diffHour : diffHour;

              double diffMin = (touchAngle - minAngle).abs();
              diffMin = diffMin > 180 ? 360 - diffMin : diffMin;

              if (distance < radius * 0.55 || (diffHour < diffMin && distance < radius * 0.75)) {
                _draggingHand = DraggingHand.hour;
              } else {
                _draggingHand = DraggingHand.minute;
              }
            }

            _lastAngle = touchAngle;
            _accumulatedMinutes = 0;
          },
          onPanUpdate: (details) {
            if (_draggingHand == null || _lastAngle == null || widget.onTimeChanged == null) return;

            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final Offset localPos = renderBox.globalToLocal(details.globalPosition);
            final Offset center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
            final Offset offset = localPos - center;

            double touchAngle = atan2(offset.dx, -offset.dy) * 180 / pi;
            if (touchAngle < 0) touchAngle += 360;

            double deltaAngle = touchAngle - _lastAngle!;
            if (deltaAngle > 180) deltaAngle -= 360;
            if (deltaAngle < -180) deltaAngle += 360;

            double deltaMinutes;
            if (widget.isSafeDial) {
              deltaMinutes = deltaAngle / 6;
            } else {
              if (_draggingHand == DraggingHand.minute) {
                deltaMinutes = deltaAngle / 6;
              } else {
                deltaMinutes = deltaAngle * 2;
              }
            }

            _accumulatedMinutes += deltaMinutes;
            _lastAngle = touchAngle;

            if (_accumulatedMinutes.abs() >= 1) {
              int minsToAdd = _accumulatedMinutes.toInt();
              _accumulatedMinutes -= minsToAdd;

              int totalMins = widget.time.hour * 60 + widget.time.minute + minsToAdd;
              if (totalMins < 0) {
                totalMins = (24 * 60) + (totalMins % (24 * 60));
              }
              int newHour = (totalMins ~/ 60) % 24;
              int newMin = totalMins % 60;

              widget.onTimeChanged!(ClockTime(newHour, newMin));
            }
          },
          onPanEnd: (_) {
            _draggingHand = null;
            _lastAngle = null;
            if (widget.onDragEnd != null) {
              widget.onDragEnd!();
            }
          },
          onPanCancel: () {
            _draggingHand = null;
            _lastAngle = null;
            if (widget.onDragEnd != null) {
              widget.onDragEnd!();
            }
          },
          child: CustomPaint(
            size: Size(size, size),
            painter: ClockPainter(
              time: widget.time,
              isSafeDial: widget.isSafeDial,
            ),
          ),
        );
      },
    );
  }
}

class ClockPainter extends CustomPainter {
  final ClockTime time;
  final bool isSafeDial;

  ClockPainter({required this.time, required this.isSafeDial});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    if (isSafeDial) {
      _paintSafeDial(canvas, size, center, radius);
    } else {
      _paintKidsClock(canvas, size, center, radius);
    }
  }

  void _paintKidsClock(Canvas canvas, Size size, Offset center, double radius) {
    final paintBg = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paintBg);

    final paintBorder = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 1.5, paintBorder);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) {
      double angle = i * 30 * pi / 180;
      Offset bumpPos = Offset(
        center.dx + (radius - 12) * sin(angle),
        center.dy - (radius - 12) * cos(angle),
      );

      final bumpPaint = Paint()
        ..color = Colors.deepPurple.shade200.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(bumpPos, 14, bumpPaint);
      
      final bumpBorder = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(bumpPos, 14, bumpBorder);

      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black38, blurRadius: 2, offset: Offset(0, 1))],
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        bumpPos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    for (int h = 0; h < 12; h++) {
      double baseAngle = h * 30;
      _drawQuarterDot(canvas, center, radius, baseAngle + 7.5, Colors.blueAccent);
      _drawQuarterDot(canvas, center, radius, baseAngle + 15, Colors.amber);
      _drawQuarterDot(canvas, center, radius, baseAngle + 22.5, Colors.redAccent);
    }

    double hourAngle = time.hourAngleDegrees;
    double minAngle = time.minuteAngleDegrees;

    final hourHandPaint = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius * 0.5) * sin(hourAngle * pi / 180),
        center.dy - (radius * 0.5) * cos(hourAngle * pi / 180),
      ),
      hourHandPaint,
    );

    final minHandPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius * 0.75) * sin(minAngle * pi / 180),
        center.dy - (radius * 0.75) * cos(minAngle * pi / 180),
      ),
      minHandPaint,
    );

    final centerPin = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerPin);
    canvas.drawCircle(center, 4, Paint()..color = Colors.deepPurple);
  }

  void _drawQuarterDot(Canvas canvas, Offset center, double radius, double angleDegrees, Color color) {
    double angle = angleDegrees * pi / 180;
    Offset dotPos = Offset(
      center.dx + (radius - 35) * sin(angle),
      center.dy - (radius - 35) * cos(angle),
    );
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotPos, 4, dotPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(dotPos, 4, borderPaint);
  }

  void _paintSafeDial(Canvas canvas, Size size, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final dialPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.grey.shade800,
          Colors.grey.shade400,
          Colors.grey.shade700,
          Colors.grey.shade300,
          Colors.grey.shade800,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, dialPaint);

    final innerCirclePaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius * 0.85, innerCirclePaint..strokeWidth = 3);
    canvas.drawCircle(center, radius * 0.65, innerCirclePaint..strokeWidth = 2);

    final knobPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.grey.shade300,
          Colors.grey.shade700,
          Colors.grey.shade900,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.35))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.35, knobPaint);

    final indicatorPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - radius + 5)
      ..lineTo(center.dx - 8, center.dy - radius + 18)
      ..lineTo(center.dx + 8, center.dy - radius + 18)
      ..close();
    canvas.drawPath(path, indicatorPaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    for (int m = 0; m < 60; m++) {
      double angle = m * 6 * pi / 180;
      
      bool isMajor = (m % 5 == 0);
      double startDist = isMajor ? radius - 15 : radius - 10;
      double endDist = radius - 2;

      Offset pStart = Offset(
        center.dx + startDist * sin(angle),
        center.dy - startDist * cos(angle),
      );
      Offset pEnd = Offset(
        center.dx + endDist * sin(angle),
        center.dy - endDist * cos(angle),
      );

      final tickPaint = Paint()
        ..color = isMajor ? Colors.black : Colors.black45;
      
      if (isMajor) {
        tickPaint.strokeWidth = 2;
      } else {
        tickPaint.strokeWidth = 1;
      }
      canvas.drawLine(pStart, pEnd, tickPaint);

      if (isMajor) {
        double labelDist = radius - 26;
        Offset labelPos = Offset(
          center.dx + labelDist * sin(angle),
          center.dy - labelDist * cos(angle),
        );

        textPainter.text = TextSpan(
          text: '$m',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        canvas.save();
        canvas.translate(labelPos.dx, labelPos.dy);
        textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
        canvas.restore();
      }
    }

    double dialAngle = time.minute * 6 * pi / 180;
    
    final pointerPaint = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(
        center.dx + (radius * 0.35) * sin(dialAngle),
        center.dy - (radius * 0.35) * cos(dialAngle),
      ),
      Offset(
        center.dx + (radius * 0.75) * sin(dialAngle),
        center.dy - (radius * 0.75) * cos(dialAngle),
      ),
      pointerPaint,
    );
    
    canvas.drawCircle(
      Offset(
        center.dx + (radius * 0.5) * sin(dialAngle),
        center.dy - (radius * 0.5) * cos(dialAngle),
      ),
      6,
      Paint()..color = Colors.amber,
    );
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.isSafeDial != isSafeDial;
  }
}

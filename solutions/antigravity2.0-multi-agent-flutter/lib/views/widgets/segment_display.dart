import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/clock_time.dart';

class SevenSegmentDisplay extends StatefulWidget {
  final ClockTime time;
  final Color activeColor;
  final double digitWidth;
  final double digitHeight;

  const SevenSegmentDisplay({
    super.key,
    required this.time,
    this.activeColor = const Color(0xFF00FFCC),
    this.digitWidth = 45,
    this.digitHeight = 90,
  });

  @override
  State<SevenSegmentDisplay> createState() => _SevenSegmentDisplayState();
}

class _SevenSegmentDisplayState extends State<SevenSegmentDisplay> {
  bool _colonVisible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          _colonVisible = !_colonVisible;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int h1 = widget.time.hour ~/ 10;
    final int h2 = widget.time.hour % 10;
    final int m1 = widget.time.minute ~/ 10;
    final int m2 = widget.time.minute % 10;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SevenSegmentDigit(
          digit: h1,
          activeColor: widget.activeColor,
          width: widget.digitWidth,
          height: widget.digitHeight,
        ),
        const SizedBox(width: 8),
        SevenSegmentDigit(
          digit: h2,
          activeColor: widget.activeColor,
          width: widget.digitWidth,
          height: widget.digitHeight,
        ),
        Container(
          width: 20,
          height: widget.digitHeight,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _colonVisible ? 1.0 : 0.08,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.activeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.activeColor.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: _colonVisible ? 1.0 : 0.08,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.activeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.activeColor.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SevenSegmentDigit(
          digit: m1,
          activeColor: widget.activeColor,
          width: widget.digitWidth,
          height: widget.digitHeight,
        ),
        const SizedBox(width: 8),
        SevenSegmentDigit(
          digit: m2,
          activeColor: widget.activeColor,
          width: widget.digitWidth,
          height: widget.digitHeight,
        ),
      ],
    );
  }
}

class SevenSegmentDigit extends StatelessWidget {
  final int digit;
  final Color activeColor;
  final double width;
  final double height;

  const SevenSegmentDigit({
    super.key,
    required this.digit,
    required this.activeColor,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _DigitPainter(
        digit: digit,
        activeColor: activeColor,
      ),
    );
  }
}

class _DigitPainter extends CustomPainter {
  final int digit;
  final Color activeColor;

  static const Map<int, List<bool>> segmentConfigurations = {
    0: [true,  true,  true,  true,  true,  true,  false],
    1: [false, true,  true,  false, false, false, false],
    2: [true,  true,  false, true,  true,  false, true],
    3: [true,  true,  true,  true,  false, false, true],
    4: [false, true,  true,  false, false, true,  true],
    5: [true,  false, true,  true,  false, true,  true],
    6: [true,  false, true,  true,  true,  true,  true],
    7: [true,  true,  true,  false, false, false, false],
    8: [true,  true,  true,  true,  true,  true,  true],
    9: [true,  true,  true,  true,  false, true,  true],
  };

  _DigitPainter({required this.digit, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double W = size.width;
    final double H = size.height;
    final double T = W * 0.12;
    final double s = W * 0.03;

    final config = segmentConfigurations[digit] ?? segmentConfigurations[0]!;

    _drawSegment(canvas, _getPathA(W, H, T, s), config[0]);
    _drawSegment(canvas, _getPathB(W, H, T, s), config[1]);
    _drawSegment(canvas, _getPathC(W, H, T, s), config[2]);
    _drawSegment(canvas, _getPathD(W, H, T, s), config[3]);
    _drawSegment(canvas, _getPathE(W, H, T, s), config[4]);
    _drawSegment(canvas, _getPathF(W, H, T, s), config[5]);
    _drawSegment(canvas, _getPathG(W, H, T, s), config[6]);
  }

  void _drawSegment(Canvas canvas, Path path, bool active) {
    final paint = Paint()
      ..color = active ? activeColor : activeColor.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    if (active) {
      final glowPaint = Paint()
        ..color = activeColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, glowPaint);
    }
  }

  Path _getPathA(double W, double H, double T, double s) {
    return Path()
      ..moveTo(T / 2 + s, s)
      ..lineTo(W - T / 2 - s, s)
      ..lineTo(W - T - s, T + s)
      ..lineTo(T + s, T + s)
      ..close();
  }

  Path _getPathF(double W, double H, double T, double s) {
    return Path()
      ..moveTo(s, T / 2 + s)
      ..lineTo(T + s, T + s)
      ..lineTo(T + s, H / 2 - T / 2 - s)
      ..lineTo(T / 2 + s, H / 2 - s)
      ..lineTo(s, H / 2 - T / 2 - s)
      ..close();
  }

  Path _getPathB(double W, double H, double T, double s) {
    return Path()
      ..moveTo(W - s, T / 2 + s)
      ..lineTo(W - s, H / 2 - T / 2 - s)
      ..lineTo(W - T / 2 - s, H / 2 - s)
      ..lineTo(W - T - s, H / 2 - T / 2 - s)
      ..lineTo(W - T - s, T + s)
      ..close();
  }

  Path _getPathG(double W, double H, double T, double s) {
    return Path()
      ..moveTo(T + s, H / 2)
      ..lineTo(T + 3 / 2 * s, H / 2 - T / 2 + s / 2)
      ..lineTo(W - T - 3 / 2 * s, H / 2 - T / 2 + s / 2)
      ..lineTo(W - T - s, H / 2)
      ..lineTo(W - T - 3 / 2 * s, H / 2 + T / 2 - s / 2)
      ..lineTo(T + 3 / 2 * s, H / 2 + T / 2 - s / 2)
      ..close();
  }

  Path _getPathE(double W, double H, double T, double s) {
    return Path()
      ..moveTo(s, H / 2 + T / 2 + s)
      ..lineTo(T / 2 + s, H / 2 + s)
      ..lineTo(T + s, H / 2 + T / 2 + s)
      ..lineTo(T + s, H - T - s)
      ..lineTo(s, H - T / 2 - s)
      ..close();
  }

  Path _getPathC(double W, double H, double T, double s) {
    return Path()
      ..moveTo(W - s, H / 2 + T / 2 + s)
      ..lineTo(W - s, H - T / 2 - s)
      ..lineTo(W - T - s, H - T - s)
      ..lineTo(W - T - s, H / 2 + T / 2 + s)
      ..lineTo(W - T / 2 - s, H / 2 + s)
      ..close();
  }

  Path _getPathD(double W, double H, double T, double s) {
    return Path()
      ..moveTo(T + s, H - T - s)
      ..lineTo(W - T - s, H - T - s)
      ..lineTo(W - T / 2 - s, H - s)
      ..lineTo(T / 2 + s, H - s)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _DigitPainter oldDelegate) {
    return oldDelegate.digit != digit || oldDelegate.activeColor != activeColor;
  }
}

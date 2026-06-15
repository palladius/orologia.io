import 'package:flutter/material.dart';
import '../../state/sandbox_notifier.dart';
import '../widgets/analog_clock.dart';
import '../widgets/glass_card.dart';
import '../widgets/segment_display.dart';

class SandboxScreen extends StatelessWidget {
  final SandboxNotifier sandboxNotifier;

  const SandboxScreen({
    super.key,
    required this.sandboxNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E0854),
              Color(0xFF180B30),
              Color(0xFF0C1033),
            ],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: sandboxNotifier,
            builder: (context, _) {
              final currentTime = sandboxNotifier.currentTime;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Sandbox Mode 🧪',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Column(
                        children: [
                          const Text(
                            'Drag the hands or press the buttons to learn how time works!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: SevenSegmentDisplay(
                              time: currentTime,
                              activeColor: const Color(0xFF00FFCC),
                              digitWidth: 40,
                              digitHeight: 80,
                            ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 280,
                            width: 280,
                            child: AnalogClock(
                              time: currentTime,
                              onTimeChanged: (newTime) {
                                sandboxNotifier.currentTime = newTime;
                              },
                            ),
                          ),
                          const SizedBox(height: 28),

                          _buildControlPanel(context),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adjust Time:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildOffsetBtn(
                  label: '-1 Hour',
                  icon: Icons.exposure_minus_1,
                  color: Colors.redAccent,
                  onTap: () => sandboxNotifier.subtractHour(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOffsetBtn(
                  label: '+1 Hour',
                  icon: Icons.exposure_plus_1,
                  color: Colors.greenAccent,
                  onTap: () => sandboxNotifier.addHour(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildOffsetBtn(
                  label: '-15 Min',
                  color: Colors.pinkAccent,
                  onTap: () => sandboxNotifier.subtract15Minutes(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOffsetBtn(
                  label: '+15 Min',
                  color: Colors.cyanAccent,
                  onTap: () => sandboxNotifier.add15Minutes(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildOffsetBtn(
                  label: '-5 Min',
                  color: Colors.orangeAccent,
                  onTap: () => sandboxNotifier.addMinutes(-5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOffsetBtn(
                  label: '+5 Min',
                  color: Colors.amberAccent,
                  onTap: () => sandboxNotifier.addMinutes(5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildOffsetBtn(
                  label: '-1 Min',
                  color: Colors.purpleAccent,
                  onTap: () => sandboxNotifier.subtract1Minute(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOffsetBtn(
                  label: '+1 Min',
                  color: Colors.blueAccent,
                  onTap: () => sandboxNotifier.add1Minute(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOffsetBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.4), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/clock_time.dart';
import '../../models/safe_step.dart';
import '../../state/safe_lock_notifier.dart';
import '../widgets/analog_clock.dart';
import '../widgets/glass_card.dart';

class SafeLockScreen extends StatelessWidget {
  final SafeLockNotifier safeLockNotifier;

  const SafeLockScreen({
    super.key,
    required this.safeLockNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: safeLockNotifier,
        builder: (context, _) {
          final status = safeLockNotifier.status;
          final isUnlocked = status == SafeStatus.unlocked;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isUnlocked
                    ? [
                        const Color(0xFF1B4D3E), // Emerald green success gradient
                        const Color(0xFF0F201B),
                      ]
                    : [
                        const Color(0xFF3E4348), // Sleek metal grey
                        const Color(0xFF1E2022),
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom Header Bar
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
                          'Safe Lock 🔐',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () => safeLockNotifier.resetLock(),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: isUnlocked
                          ? _buildUnlockedChestView(context)
                          : _buildLockDialView(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLockDialView(BuildContext context) {
    final curStep = safeLockNotifier.currentStepIndex;
    final message = safeLockNotifier.message;
    final curMinute = safeLockNotifier.dialMinute;

    return Column(
      children: [
        const Text(
          'Solve the Combination to Open the Safe!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),

        // Steps Tracker Card
        GlassCard(
          color: Colors.white.withOpacity(0.05),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Combination Steps:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(safeLockNotifier.steps.length, (index) {
                  final step = safeLockNotifier.steps[index];
                  final isDone = index < curStep;
                  final isCurrent = index == curStep;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.green.withOpacity(0.3)
                          : isCurrent
                              ? Colors.amber.withOpacity(0.3)
                              : Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDone
                            ? Colors.greenAccent
                            : isCurrent
                                ? Colors.amberAccent
                                : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDone
                              ? Icons.check_circle
                              : isCurrent
                                  ? Icons.run_circle_outlined
                                  : Icons.circle_outlined,
                          size: 16,
                          color: isDone
                              ? Colors.greenAccent
                              : isCurrent
                                  ? Colors.amberAccent
                                  : Colors.white38,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          step.toString(),
                          style: TextStyle(
                            color: isDone
                                ? Colors.greenAccent
                                : isCurrent
                                    ? Colors.amberAccent
                                    : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Status Indicator Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Current Dial: $curMinute',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // Metallic Rotary Safe Dial
        SizedBox(
          height: 300,
          width: 300,
          child: AnalogClock(
            time: ClockTime(0, curMinute),
            isSafeDial: true,
            onTimeChanged: (newTime) {
              safeLockNotifier.rotateTo(newTime.minute);
            },
            onDragEnd: () {
              safeLockNotifier.releaseDial();
            },
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildUnlockedChestView(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Icon(
            Icons.stars,
            size: 64,
            color: Colors.amberAccent,
          ),
          const SizedBox(height: 16),
          const Text(
            'COMBINATION UNLOCKED! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'The treasure chest is open!',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          // Glowing Treasure Chest Vector Illustration
          GlassCard(
            color: Colors.black26,
            borderRadius: 24,
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sparkles radial layout
                    for (int i = 0; i < 8; i++)
                      Transform.rotate(
                        angle: i * 45 * 3.14159 / 180,
                        child: Container(
                          width: 160,
                          height: 160,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.star,
                            color: Colors.yellowAccent,
                            size: 14,
                          ),
                        ),
                      ),
                    // Giant Chest Icon
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.amberAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellowAccent.withOpacity(0.3),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        size: 68,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('💎', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 8),
                    Text('👑', style: TextStyle(fontSize: 40)),
                    SizedBox(width: 8),
                    Text('🪙', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 8),
                    Text('💰', style: TextStyle(fontSize: 32)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Alessandro and Sebi are now Time Masters!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          ElevatedButton(
            onPressed: () => safeLockNotifier.resetLock(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 4,
            ),
            child: const Text(
              'Lock Safe & Play Again 🔄',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to Main Menu',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

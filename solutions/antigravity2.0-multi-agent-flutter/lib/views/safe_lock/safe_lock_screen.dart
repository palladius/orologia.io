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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
    final bool isWide = MediaQuery.of(context).size.width > 650;

    if (isWide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Dial
          SizedBox(
            height: 250,
            width: 250,
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
          // Right side: stats & steps
          SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStepsTracker(curStep),
                const SizedBox(height: 12),
                _buildStatusBox(message, curMinute),
              ],
            ),
          ),
        ],
      );
    }

    // Narrow layout
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepsTracker(curStep),
        const SizedBox(height: 10),
        _buildStatusBox(message, curMinute),
        const SizedBox(height: 16),
        SizedBox(
          height: 190,
          width: 190,
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
      ],
    );
  }

  Widget _buildStepsTracker(int curStep) {
    return GlassCard(
      color: Colors.white.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Combination Steps:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(safeLockNotifier.steps.length, (index) {
              final step = safeLockNotifier.steps[index];
              final isDone = index < curStep;
              final isCurrent = index == curStep;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green.withOpacity(0.3)
                      : isCurrent
                          ? Colors.amber.withOpacity(0.3)
                          : Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDone
                        ? Colors.greenAccent
                        : isCurrent
                            ? Colors.amberAccent
                            : Colors.white24,
                    width: 1.0,
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
                      size: 14,
                      color: isDone
                          ? Colors.greenAccent
                          : isCurrent
                              ? Colors.amberAccent
                              : Colors.white38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      step.toString(),
                      style: TextStyle(
                        color: isDone
                            ? Colors.greenAccent
                            : isCurrent
                                ? Colors.amberAccent
                                : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox(String message, int curMinute) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Dial: $curMinute',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedChestView(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 650;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.stars,
              size: 48,
              color: Colors.amberAccent,
            ),
            const SizedBox(height: 10),
            const Text(
              'COMBINATION UNLOCKED! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'The treasure chest is open!',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Glowing Treasure Chest Card
            GlassCard(
              color: Colors.black26,
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      for (int i = 0; i < 8; i++)
                        Transform.rotate(
                          angle: i * 45 * 3.14159 / 180,
                          child: Container(
                            width: 120,
                            height: 120,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.star,
                              color: Colors.yellowAccent,
                              size: 10,
                            ),
                          ),
                        ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.amberAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellowAccent.withOpacity(0.3),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.card_giftcard,
                          size: 48,
                          color: Colors.yellowAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('💎', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Text('👑', style: TextStyle(fontSize: 32)),
                      SizedBox(width: 8),
                      Text('🪙', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Text('💰', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Alessandro and Sebi are now Time Masters!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => safeLockNotifier.resetLock(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 4,
              ),
              child: const Text(
                'Lock Safe & Play Again 🔄',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Back to Main Menu',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

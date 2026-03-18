// lib/components/habit_share_card.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mini_habit_tracker/models/habit.dart';

class HabitShareCard extends StatelessWidget {
  final String habitName;
  final int streak;
  final HabitDifficulty difficulty;
  final Color categoryColor;
  final String categoryEmoji;
  final GlobalKey repaintKey;

  const HabitShareCard({
    super.key,
    required this.habitName,
    required this.streak,
    required this.difficulty,
    required this.categoryColor,
    required this.categoryEmoji,
    required this.repaintKey,
  });

  String get _motivationalMessage {
    if (streak >= 30) return "Absolute legend. 30+ days strong! 👑";
    if (streak >= 21) return "21 days in — this is now a habit for life! 🔥";
    if (streak >= 14) return "Two weeks of pure consistency! 💪";
    if (streak >= 7) return "A full week! The streak is real! ⚡";
    if (streak >= 3) return "3 days in — momentum is building! 🚀";
    return "Every great streak starts with day one! 🌱";
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              categoryColor.withOpacity(0.85),
              const Color(0xFFE6E6FA),
              const Color(0xFFFFFACD).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App branding
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text('🌱', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 5),
                      Text(
                        'Mini Habit Tracker',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Emoji + habit name
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(categoryEmoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    habitName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Streak count — big and bold
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Streak',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$streak',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'days 🔥',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Difficulty badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: difficulty.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: difficulty.color.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Text(difficulty.emoji,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          difficulty.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: difficulty.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Motivational message
            Text(
              _motivationalMessage,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Captures the card as a PNG image in memory
  static Future<Uint8List?> capture(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Share card capture error: $e');
      return null;
    }
  }
}
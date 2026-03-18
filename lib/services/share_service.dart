// lib/services/share_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/components/habit_share_card.dart';
import 'package:mini_habit_tracker/models/habit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Shows the share card preview dialog, then shares on tap
  static Future<void> shareHabitStreak({
    required BuildContext context,
    required String habitName,
    required int streak,
    required HabitDifficulty difficulty,
    required Color categoryColor,
    required String categoryEmoji,
  }) async {
    final repaintKey = GlobalKey();

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card preview
            HabitShareCard(
              habitName: habitName,
              streak: streak,
              difficulty: difficulty,
              categoryColor: categoryColor,
              categoryEmoji: categoryEmoji,
              repaintKey: repaintKey,
            ),

            const SizedBox(height: 20),

            // Share button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Small delay so the widget is fully painted
                  await Future.delayed(const Duration(milliseconds: 100));
                  final bytes = await HabitShareCard.capture(repaintKey);

                  if (bytes == null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('❌ Could not capture card.')),
                    );
                    return;
                  }

                  // Save to temp file
                  final dir = await getTemporaryDirectory();
                  final file =
                      File('${dir.path}/habit_streak_$habitName.png');
                  await file.writeAsBytes(bytes);

                  Navigator.pop(context);

                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text:
                        '🔥 $streak day streak on "$habitName"! Building better habits with Mini Habit Tracker 🌱',
                  );
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share This Card',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9370DB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Cancel
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
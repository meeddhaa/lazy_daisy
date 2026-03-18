import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mini_habit_tracker/models/habit.dart';
import 'package:mini_habit_tracker/services/share_service.dart';

class MyHabitTile extends StatelessWidget {
  final String text;
  final bool isHabitCompletedToday;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  final List<DateTime> completedDays;
  final Color? categoryColor;
  final String? categoryEmoji;
  final TimeOfDay? reminderTime;
  final HabitDifficulty difficulty;

  const MyHabitTile({
    super.key,
    required this.text,
    required this.isHabitCompletedToday,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
    required this.completedDays,
    this.categoryColor,
    this.categoryEmoji,
    this.reminderTime,
    this.difficulty = HabitDifficulty.easy,
  });

  int _calculateStreak() {
    if (completedDays.isEmpty) return 0;
    final sortedDates = completedDays.toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final mostRecent = DateTime(
        sortedDates.first.year, sortedDates.first.month, sortedDates.first.day);
    if (todayDate.difference(mostRecent).inDays > 1) return 0;
    int streak = 0;
    for (int i = 0; i < sortedDates.length; i++) {
      final checkDate = DateTime(
          sortedDates[i].year, sortedDates[i].month, sortedDates[i].day);
      final expectedDate = DateTime(sortedDates.first.year,
              sortedDates.first.month, sortedDates.first.day)
          .subtract(Duration(days: streak));
      if (checkDate.isAtSameMomentAs(expectedDate)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _getHabitEmoji() {
    if (categoryEmoji != null) return categoryEmoji!;
    final t = text.toLowerCase();
    if (t.contains('water') || t.contains('drink')) return '💧';
    if (t.contains('sleep') || t.contains('bed')) return '🛏️';
    if (t.contains('exercise') || t.contains('workout')) return '🧘';
    if (t.contains('walk') || t.contains('run')) return '🚶';
    if (t.contains('read') || t.contains('book')) return '📚';
    if (t.contains('meal') || t.contains('food')) return '🥑';
    if (t.contains('code') || t.contains('programming')) return '✨';
    if (t.contains('meditate')) return '🧘';
    if (t.contains('stretch')) return '🤸';
    if (t.contains('coffee')) return '☕';
    return '⭐';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _handleShare(BuildContext context) {
    final streak = _calculateStreak();
    ShareService.shareHabitStreak(
      context: context,
      habitName: text,
      streak: streak,
      difficulty: difficulty,
      categoryColor: categoryColor ?? const Color(0xFFE6E6FA),
      categoryEmoji: _getHabitEmoji(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streak = _calculateStreak();
    final emoji = _getHabitEmoji();
    final gradientStart =
        (categoryColor ?? const Color(0xFFFFB6C1)).withOpacity(0.3);
    final gradientEnd = const Color(0xFFE6E6FA).withOpacity(0.3);

    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: editHabit,
            backgroundColor: const Color(0xFFE6E6FA),
            icon: Icons.edit,
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: deleteHabit,
            backgroundColor: Colors.red,
            icon: Icons.delete,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHabitCompletedToday
                ? const Color(0xFF4CAF50)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: categoryColor?.withOpacity(0.2) ?? Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: difficulty.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: difficulty.color.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(difficulty.emoji,
                                style: const TextStyle(fontSize: 10)),
                            const SizedBox(width: 3),
                            Text(
                              '+${difficulty.xp}XP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: difficulty.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (streak > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '$streak ${streak == 1 ? 'Day' : 'Days'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ✅ NEW: Share button — only shows when streak > 0
                        GestureDetector(
                          onTap: () => _handleShare(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9370DB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFF9370DB)
                                      .withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.share_rounded,
                                    size: 11, color: Color(0xFF9370DB)),
                                SizedBox(width: 3),
                                Text(
                                  'Share',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF9370DB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (reminderTime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.alarm,
                            size: 13, color: Color(0xFF9370DB)),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(reminderTime!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9370DB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (onChanged != null) onChanged!(!isHabitCompletedToday);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHabitCompletedToday
                      ? const Color(0xFF4CAF50)
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isHabitCompletedToday
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isHabitCompletedToday ? Icons.check : Icons.circle_outlined,
                  color: isHabitCompletedToday
                      ? Colors.white
                      : Colors.grey.shade400,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
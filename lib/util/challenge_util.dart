// lib/util/challenge_util.dart
import 'package:mini_habit_tracker/models/challenge.dart';
import 'package:mini_habit_tracker/models/habit.dart';

class ChallengeProgress {
  final ChallengeDefinition definition;
  final int current;
  final bool isCompleted;

  ChallengeProgress({
    required this.definition,
    required this.current,
    required this.isCompleted,
  });

  int get target => definition.target;
  double get percent => (current / target).clamp(0.0, 1.0);
}

class ChallengeUtil {
  /// Returns a DateTime range for the current week (Mon–Sun) or month
  static (DateTime, DateTime) _getRange(ChallengePeriod period) {
    final now = DateTime.now();
    if (period == ChallengePeriod.weekly) {
      final startOfWeek = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return (startOfWeek, endOfWeek);
    } else {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);
      return (start, end);
    }
  }

  static bool _isInRange(DateTime date, DateTime start, DateTime end) {
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  static ChallengeProgress calculate(
      ChallengeDefinition def, List<Habit> habits) {
    final (start, end) = _getRange(def.period);

    switch (def.type) {
      case ChallengeType.totalCompletions:
        int count = 0;
        for (final habit in habits) {
          for (final ms in habit.completedDays) {
            final d = DateTime.fromMillisecondsSinceEpoch(ms);
            if (_isInRange(d, start, end)) count++;
          }
        }
        return ChallengeProgress(
          definition: def,
          current: count,
          isCompleted: count >= def.target,
        );

      case ChallengeType.completionStreak:
        // Count distinct days in the range where at least one habit was completed
        final Set<String> activeDays = {};
        for (final habit in habits) {
          for (final ms in habit.completedDays) {
            final d = DateTime.fromMillisecondsSinceEpoch(ms);
            if (_isInRange(d, start, end)) {
              activeDays.add('${d.year}-${d.month}-${d.day}');
            }
          }
        }
        // Find max consecutive streak within the range
        int maxStreak = 0;
        int currentStreak = 0;
        DateTime cursor = start;
        while (!cursor.isAfter(end)) {
          final key = '${cursor.year}-${cursor.month}-${cursor.day}';
          if (activeDays.contains(key)) {
            currentStreak++;
            if (currentStreak > maxStreak) maxStreak = currentStreak;
          } else {
            // Only break streak for past days
            if (cursor.isBefore(DateTime.now())) currentStreak = 0;
          }
          cursor = cursor.add(const Duration(days: 1));
        }
        return ChallengeProgress(
          definition: def,
          current: maxStreak,
          isCompleted: maxStreak >= def.target,
        );

      case ChallengeType.allHabitsDay:
        if (habits.isEmpty) {
          return ChallengeProgress(
              definition: def, current: 0, isCompleted: false);
        }
        // Count days where ALL habits were completed
        int perfectDays = 0;
        DateTime cursor = start;
        final today = DateTime.now();
        while (!cursor.isAfter(end) && !cursor.isAfter(today)) {
          bool allDone = habits.every((h) => h.completedDays.any((ms) {
                final d = DateTime.fromMillisecondsSinceEpoch(ms);
                return d.year == cursor.year &&
                    d.month == cursor.month &&
                    d.day == cursor.day;
              }));
          if (allDone) perfectDays++;
          cursor = cursor.add(const Duration(days: 1));
        }
        return ChallengeProgress(
          definition: def,
          current: perfectDays,
          isCompleted: perfectDays >= def.target,
        );

      case ChallengeType.categoryFocus:
        int count = 0;
        final filtered = def.categoryFilter == null
            ? habits
            : habits
                .where((h) => h.getCategory() == def.categoryFilter)
                .toList();
        for (final habit in filtered) {
          for (final ms in habit.completedDays) {
            final d = DateTime.fromMillisecondsSinceEpoch(ms);
            if (_isInRange(d, start, end)) count++;
          }
        }
        return ChallengeProgress(
          definition: def,
          current: count,
          isCompleted: count >= def.target,
        );
    }
  }

  static List<ChallengeProgress> calculateAll(List<Habit> habits) {
    return allChallenges
        .map((def) => calculate(def, habits))
        .toList();
  }
}
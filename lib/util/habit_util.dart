import 'package:mini_habit_tracker/models/habit.dart';

///  Check if the habit is completed today
bool isHabitCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any(
    (date) =>
        date.day == today.day &&
        date.month == today.month &&
        date.year == today.year,
  );
}

///  Prepare heatma data from habitlist
Map<DateTime, int> prepHeatmapDataset(
  List<Habit> habits, {
  int maxIntensity = 5,
}) {
  Map<DateTime, int> dataset = {};

  for (var habit in habits) {
    for (var ms in habit.completedDays) {
      final date = DateTime.fromMillisecondsSinceEpoch(ms);
      // Normalize to local date (midnight)
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Increment count and clamp to maxIntensity
      dataset[normalizedDate] = ((dataset[normalizedDate] ?? 0) + 1).clamp(
        1,
        maxIntensity,
      );
    }
  }

  return dataset;
}

/// Calculate daily streak for a habit
int calculateStreak(List<DateTime> completedDays) {
  if (completedDays.isEmpty) return 0;

  // Sort dates newest first
  completedDays.sort((a, b) => b.compareTo(a));
  int streak = 1;

  for (int i = 0; i < completedDays.length - 1; i++) {
    final current = completedDays[i];
    final next = completedDays[i + 1];
    final diff = current.difference(next).inDays;

    if (diff == 1) {
      streak++;
    } else if (diff > 1) {
      break; // streak broken
    }
  }

  // Check if today's habit completed; if not, reduce streak by 1
  final today = DateTime.now();
  bool doneToday = completedDays.any(
    (d) => d.year == today.year && d.month == today.month && d.day == today.day,
  );

  if (!doneToday) streak--;

  return streak < 0 ? 0 : streak;
}

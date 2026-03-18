import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
part 'habit.g.dart';

// ─────────────────────────────────────────────
// Category Enum
// ─────────────────────────────────────────────
enum HabitCategory {
  health,
  work,
  personal,
  finance,
  social,
  learning,
  fitness,
  mindfulness,
}

extension HabitCategoryExtension on HabitCategory {
  String get label {
    switch (this) {
      case HabitCategory.health: return 'Health';
      case HabitCategory.work: return 'Work';
      case HabitCategory.personal: return 'Personal';
      case HabitCategory.finance: return 'Finance';
      case HabitCategory.social: return 'Social';
      case HabitCategory.learning: return 'Learning';
      case HabitCategory.fitness: return 'Fitness';
      case HabitCategory.mindfulness: return 'Mindfulness';
    }
  }

  String get emoji {
    switch (this) {
      case HabitCategory.health: return '💪';
      case HabitCategory.work: return '💼';
      case HabitCategory.personal: return '🌱';
      case HabitCategory.finance: return '💰';
      case HabitCategory.social: return '🤝';
      case HabitCategory.learning: return '📚';
      case HabitCategory.fitness: return '🏃';
      case HabitCategory.mindfulness: return '🧘';
    }
  }

  Color get color {
    switch (this) {
      case HabitCategory.health: return const Color(0xFFFFB6C1);
      case HabitCategory.work: return const Color(0xFFB0C4DE);
      case HabitCategory.personal: return const Color(0xFFB4E7CE);
      case HabitCategory.finance: return const Color(0xFFFFD700);
      case HabitCategory.social: return const Color(0xFFFFDAB9);
      case HabitCategory.learning: return const Color(0xFFE6E6FA);
      case HabitCategory.fitness: return const Color(0xFFFFA07A);
      case HabitCategory.mindfulness: return const Color(0xFFAFEEEE);
    }
  }
}

// ─────────────────────────────────────────────
// ✅ NEW: Difficulty Enum
// ─────────────────────────────────────────────
enum HabitDifficulty { easy, medium, hard }

extension HabitDifficultyExtension on HabitDifficulty {
  String get label {
    switch (this) {
      case HabitDifficulty.easy: return 'Easy';
      case HabitDifficulty.medium: return 'Medium';
      case HabitDifficulty.hard: return 'Hard';
    }
  }

  String get emoji {
    switch (this) {
      case HabitDifficulty.easy: return '🟢';
      case HabitDifficulty.medium: return '🟡';
      case HabitDifficulty.hard: return '🔴';
    }
  }

  int get xp {
    switch (this) {
      case HabitDifficulty.easy: return 10;
      case HabitDifficulty.medium: return 25;
      case HabitDifficulty.hard: return 50;
    }
  }

  Color get color {
    switch (this) {
      case HabitDifficulty.easy: return const Color(0xFF4CAF50);
      case HabitDifficulty.medium: return const Color(0xFFFFC107);
      case HabitDifficulty.hard: return const Color(0xFFFF5252);
    }
  }
}

// ─────────────────────────────────────────────
// ✅ NEW: XP / Level System
// ─────────────────────────────────────────────
class XPSystem {
  static int xpForLevel(int level) => level * 100;

  static int getLevel(int totalXP) {
    int level = 1;
    int xpNeeded = xpForLevel(level);
    while (totalXP >= xpNeeded) {
      totalXP -= xpNeeded;
      level++;
      xpNeeded = xpForLevel(level);
    }
    return level;
  }

  static int getXPInCurrentLevel(int totalXP) {
    int level = 1;
    int xpNeeded = xpForLevel(level);
    while (totalXP >= xpNeeded) {
      totalXP -= xpNeeded;
      level++;
      xpNeeded = xpForLevel(level);
    }
    return totalXP;
  }

  static int getXPForNextLevel(int totalXP) {
    int level = getLevel(totalXP);
    return xpForLevel(level);
  }

  static String getLevelTitle(int level) {
    if (level < 3) return 'Beginner 🌱';
    if (level < 6) return 'Explorer 🚀';
    if (level < 10) return 'Achiever ⭐';
    if (level < 15) return 'Champion 🏆';
    if (level < 20) return 'Legend 👑';
    return 'Master 🔥';
  }
}

// ─────────────────────────────────────────────
// Habit Model
// ─────────────────────────────────────────────
@Collection()
class Habit {
  Id id = Isar.autoIncrement;

  late String name;

  // Category stored as int index (default: 2 = personal)
  int categoryIndex = 2;

  // Reminder time (-1 = no reminder)
  int reminderHour = -1;
  int reminderMinute = -1;

  // ✅ NEW: Difficulty stored as int index (default: 0 = easy)
  int difficultyIndex = 0;

  late List<int> completedDays = [];

  Habit({
    required this.name,
    List<int>? completedDaysParam,
    int categoryIdx = 2,
    int reminderHour = -1,
    int reminderMinute = -1,
    int difficultyIdx = 0,
  }) {
    if (completedDaysParam != null) {
      completedDays = completedDaysParam;
    }
    categoryIndex = categoryIdx;
    this.reminderHour = reminderHour;
    this.reminderMinute = reminderMinute;
    difficultyIndex = difficultyIdx;
  }

  bool get hasReminder => reminderHour != -1 && reminderMinute != -1;

  TimeOfDay? getReminderTime() {
    if (!hasReminder) return null;
    return TimeOfDay(hour: reminderHour, minute: reminderMinute);
  }

  void setReminderTime(TimeOfDay? time) {
    if (time == null) {
      reminderHour = -1;
      reminderMinute = -1;
    } else {
      reminderHour = time.hour;
      reminderMinute = time.minute;
    }
  }

  HabitCategory getCategory() {
    if (categoryIndex >= 0 && categoryIndex < HabitCategory.values.length) {
      return HabitCategory.values[categoryIndex];
    }
    return HabitCategory.personal;
  }

  void setCategory(HabitCategory cat) {
    categoryIndex = cat.index;
  }

  // ✅ NEW: Difficulty helpers
  HabitDifficulty getDifficulty() {
    if (difficultyIndex >= 0 &&
        difficultyIndex < HabitDifficulty.values.length) {
      return HabitDifficulty.values[difficultyIndex];
    }
    return HabitDifficulty.easy;
  }

  void setDifficulty(HabitDifficulty d) {
    difficultyIndex = d.index;
  }

  // ✅ NEW: XP earned by this habit (completions × difficulty XP)
  int getTotalXP() {
    return completedDays.length * getDifficulty().xp;
  }

  void addCompletedDay(DateTime day) {
    completedDays.add(day.millisecondsSinceEpoch);
  }

  List<DateTime> getCompletedDays() {
    return completedDays
        .map((ms) => DateTime.fromMillisecondsSinceEpoch(ms))
        .toList();
  }
}
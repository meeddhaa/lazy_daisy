import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:mini_habit_tracker/models/app_settings.dart';
import 'package:mini_habit_tracker/models/habit.dart';
import 'package:mini_habit_tracker/util/notification_helper.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;
  final NotificationHelper _notificationHelper = NotificationHelper();

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      HabitSchema,
      AppSettingsSchema,
    ], directory: dir.path);
  }

  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  final List<Habit> currentHabits = [];

  // Get total XP across all habits
  int get totalXP =>
      currentHabits.fold<int>(0, (sum, h) => sum + h.getTotalXP());

  // CREATE
  Future<void> addHabit(
    String habitName, {
    HabitCategory category = HabitCategory.personal,
    int reminderHour = -1,
    int reminderMinute = -1,
    HabitDifficulty difficulty = HabitDifficulty.easy,
  }) async {
    final newHabit = Habit(
      name: habitName,
      categoryIdx: category.index,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      difficultyIdx: difficulty.index,
    )..completedDays = [];

    await isar.writeTxn(() async {
      await isar.habits.put(newHabit);
    });

    if (reminderHour != -1 && reminderMinute != -1) {
      await _notificationHelper.scheduleHabitReminder(
        habitId: newHabit.id,
        habitName: habitName,
        hour: reminderHour,
        minute: reminderMinute,
      );
    }

    await readHabits();
    notifyListeners();
  }

  // ✅ NEW: CREATE with full history (used by backup restore)
  Future<void> addHabitWithHistory(
    String habitName, {
    HabitCategory category = HabitCategory.personal,
    int reminderHour = -1,
    int reminderMinute = -1,
    HabitDifficulty difficulty = HabitDifficulty.easy,
    List<int> completedDays = const [],
  }) async {
    final newHabit = Habit(
      name: habitName,
      categoryIdx: category.index,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      difficultyIdx: difficulty.index,
    )..completedDays = List<int>.from(completedDays);

    await isar.writeTxn(() async {
      await isar.habits.put(newHabit);
    });

    if (reminderHour != -1 && reminderMinute != -1) {
      await _notificationHelper.scheduleHabitReminder(
        habitId: newHabit.id,
        habitName: habitName,
        hour: reminderHour,
        minute: reminderMinute,
      );
    }

    await readHabits();
    notifyListeners();
  }

  // READ
  Future<void> readHabits() async {
    final fetchedHabits = await isar.habits.where().findAll();
    currentHabits
      ..clear()
      ..addAll(fetchedHabits);
    notifyListeners();
  }

  // UPDATE - completion
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);
    if (habit == null) return;
    await isar.writeTxn(() async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayMs = today.millisecondsSinceEpoch;
      if (isCompleted) {
        if (!habit.completedDays.contains(todayMs)) {
          habit.completedDays = List<int>.from(habit.completedDays)
            ..add(todayMs);
        }
      } else {
        habit.completedDays = List<int>.from(habit.completedDays)
          ..removeWhere((ms) {
            final date = DateTime.fromMillisecondsSinceEpoch(ms);
            return date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
          });
      }
      await isar.habits.put(habit);
    });
    await readHabits();
  }

  // UPDATE - name, category, reminder, difficulty
  Future<void> updateHabitName(
    int id,
    String newName, {
    HabitCategory? category,
    int? reminderHour,
    int? reminderMinute,
    HabitDifficulty? difficulty,
  }) async {
    final habit = await isar.habits.get(id);
    if (habit == null) return;

    await isar.writeTxn(() async {
      habit.name = newName;
      if (category != null) habit.setCategory(category);
      if (reminderHour != null) habit.reminderHour = reminderHour;
      if (reminderMinute != null) habit.reminderMinute = reminderMinute;
      if (difficulty != null) habit.setDifficulty(difficulty);
      await isar.habits.put(habit);
    });

    if (habit.hasReminder) {
      await _notificationHelper.scheduleHabitReminder(
        habitId: id,
        habitName: newName,
        hour: habit.reminderHour,
        minute: habit.reminderMinute,
      );
    } else {
      await _notificationHelper.cancelHabitReminder(id);
    }

    await readHabits();
  }

  // DELETE
  Future<void> deleteHabit(int id) async {
    await _notificationHelper.cancelHabitReminder(id);
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    await readHabits();
  }
}
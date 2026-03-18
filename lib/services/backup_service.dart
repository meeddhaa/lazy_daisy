// lib/services/backup_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/database/habit_database.dart';
import 'package:mini_habit_tracker/models/habit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  // ─── EXPORT ─────────────────────────────────────────────────────────────────

  static Future<bool> exportBackup(
      BuildContext context, HabitDatabase db) async {
    try {
      final habits = db.currentHabits;

      final List<Map<String, dynamic>> habitList = habits.map((h) {
        return {
          'name': h.name,
          'categoryIndex': h.categoryIndex,
          'reminderHour': h.reminderHour,
          'reminderMinute': h.reminderMinute,
          'difficultyIndex': h.difficultyIndex,
          'completedDays': h.completedDays,
        };
      }).toList();

      final backup = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'habitCount': habits.length,
        'habits': habitList,
      };

      final jsonString =
          const JsonEncoder.withIndent('  ').convert(backup);

      // Write to temp file
      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName =
          'habit_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Mini Habit Tracker Backup',
        text:
            'My habit backup — ${habits.length} habit${habits.length == 1 ? '' : 's'}',
      );

      return true;
    } catch (e) {
      debugPrint('Backup export error: $e');
      return false;
    }
  }

  // ─── IMPORT ─────────────────────────────────────────────────────────────────

  static Future<int?> importBackup(
      BuildContext context, HabitDatabase db) async {
    try {
      // Pick the file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final path = result.files.single.path;
      if (path == null) return null;

      final file = File(path);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate format
      if (!data.containsKey('habits') || data['habits'] is! List) {
        throw const FormatException('Invalid backup file format');
      }

      final habitList = data['habits'] as List<dynamic>;
      int imported = 0;

      for (final item in habitList) {
        final map = item as Map<String, dynamic>;
        final name = map['name'] as String? ?? '';
        if (name.isEmpty) continue;

        final categoryIdx = map['categoryIndex'] as int? ?? 2;
        final reminderHour = map['reminderHour'] as int? ?? -1;
        final reminderMinute = map['reminderMinute'] as int? ?? -1;
        final difficultyIdx = map['difficultyIndex'] as int? ?? 0;
        final completedRaw = map['completedDays'] as List<dynamic>? ?? [];
        final completedDays =
            completedRaw.map((e) => e as int).toList();

        final category = categoryIdx >= 0 &&
                categoryIdx < HabitCategory.values.length
            ? HabitCategory.values[categoryIdx]
            : HabitCategory.personal;

        final difficulty = difficultyIdx >= 0 &&
                difficultyIdx < HabitDifficulty.values.length
            ? HabitDifficulty.values[difficultyIdx]
            : HabitDifficulty.easy;

        await db.addHabitWithHistory(
          name,
          category: category,
          reminderHour: reminderHour,
          reminderMinute: reminderMinute,
          difficulty: difficulty,
          completedDays: completedDays,
        );

        imported++;
      }

      return imported;
    } on FormatException catch (e) {
      debugPrint('Backup format error: $e');
      rethrow;
    } catch (e) {
      debugPrint('Backup import error: $e');
      return null;
    }
  }
}
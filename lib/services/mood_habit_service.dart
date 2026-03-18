import 'dart:convert';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared ChangeNotifier consumed by MoodTrackerPage (write) and ProgressPage (read).
/// Stores mood entries enriched with the habit-completion snapshot at log time.
/// SharedPreferences only — no Isar schema changes, no build_runner needed.
class MoodHabitService extends ChangeNotifier {
  static const _key = 'mood_habit_entries_v1';

  List<MoodEntry> _entries = [];
  List<MoodEntry> get entries => List.unmodifiable(_entries);

  MoodHabitService() {
    _load();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      _entries = list
          .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _entries.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  // ── Write ────────────────────────────────────────────────────────────────

  Future<void> addEntry({
    required String emoji,
    required String name,
    required int colorValue,
    required int intensity,
    required String note,
    // Names of habits completed today — snapshot captured at log time
    required List<String> completedHabitNames,
    // Total habit count at log time
    required int totalHabits,
  }) async {
    _entries.insert(
      0,
      MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        emoji: emoji,
        name: name,
        colorValue: colorValue,
        intensity: intensity,
        note: note,
        completedHabitNames: completedHabitNames,
        totalHabits: totalHabits,
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  // ── Analytics ────────────────────────────────────────────────────────────

  /// Today's mood entry, or null if not logged yet
  MoodEntry? get todaysMood {
    final now = DateTime.now();
    for (final e in _entries) {
      if (e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day) return e;
    }
    return null;
  }

  /// Index 0 = 6 days ago … index 6 = today
  List<MoodEntry?> get last7Days {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      for (final e in _entries) {
        if (e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day) return e;
      }
      return null;
    });
  }

  /// Consecutive days the user has logged a mood (streak)
  int get logStreak {
    if (_entries.isEmpty) return 0;
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final now = DateTime.now();
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final found = _entries.any((e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day);
      if (found) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  /// Average habit completion rate per mood name
  /// e.g. { 'Happy': 0.85, 'Tired': 0.30 }
  Map<String, double> get completionRateByMood {
    final Map<String, List<double>> grouped = {};
    for (final e in _entries) {
      if (e.totalHabits == 0) continue;
      grouped
          .putIfAbsent(e.name, () => [])
          .add(e.completedHabitNames.length / e.totalHabits);
    }
    return grouped.map(
        (k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length));
  }

  /// Mood with highest average habit completion rate
  String? get bestMoodForHabits {
    final r = completionRateByMood;
    if (r.isEmpty) return null;
    return r.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Human-readable correlation insight, or null if not enough data
  String? get correlationInsight {
    final rates = completionRateByMood;
    if (rates.length < 2) return null;
    final sorted = rates.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final best = sorted.first;
    final worst = sorted.last;
    if (worst.value == 0) return null;
    final mult = best.value / worst.value;
    if (mult < 1.3) return null;
    return 'You complete ${mult.toStringAsFixed(1)}× more habits when feeling ${best.key}';
  }

  /// Most frequently logged mood name
  String? get dominantMood {
    if (_entries.isEmpty) return null;
    final freq = <String, int>{};
    for (final e in _entries) {
      freq[e.name] = (freq[e.name] ?? 0) + 1;
    }
    return freq.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Average intensity of entries within the last [days] days
  double avgIntensityLast(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = _entries.where((e) => e.date.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0;
    return recent.map((e) => e.intensity).reduce((a, b) => a + b) /
        recent.length;
  }

  /// Mood name → how many times logged
  Map<String, int> get moodFrequency {
    final freq = <String, int>{};
    for (final e in _entries) {
      freq[e.name] = (freq[e.name] ?? 0) + 1;
    }
    return freq;
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────

class MoodEntry {
  final String id;
  final DateTime date;
  final String emoji;
  final String name;
  final int colorValue;
  final int intensity;
  final String note;
  final List<String> completedHabitNames;
  final int totalHabits;

  const MoodEntry({
    required this.id,
    required this.date,
    required this.emoji,
    required this.name,
    required this.colorValue,
    required this.intensity,
    required this.note,
    required this.completedHabitNames,
    required this.totalHabits,
  });

  double get completionRate =>
      totalHabits == 0 ? 0 : completedHabitNames.length / totalHabits;

  Color get color => Color(colorValue);

  factory MoodEntry.fromJson(Map<String, dynamic> j) => MoodEntry(
        id: (j['id'] as String?) ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.parse(j['date'] as String),
        emoji: j['emoji'] as String,
        name: j['name'] as String,
        colorValue: j['colorValue'] as int,
        intensity: j['intensity'] as int,
        note: (j['note'] as String?) ?? '',
        completedHabitNames:
            List<String>.from((j['completedHabitNames'] as List?) ?? []),
        totalHabits: (j['totalHabits'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'emoji': emoji,
        'name': name,
        'colorValue': colorValue,
        'intensity': intensity,
        'note': note,
        'completedHabitNames': completedHabitNames,
        'totalHabits': totalHabits,
      };
}
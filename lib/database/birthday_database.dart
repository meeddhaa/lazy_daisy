import 'package:flutter/foundation.dart';
import 'package:mini_habit_tracker/models/birthday.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BirthdayDatabase extends ChangeNotifier {
  static const _key = 'birthdays';
  List<Birthday> _birthdays = [];

  List<Birthday> get birthdays => List.unmodifiable(_birthdays);

  // Sorted by next upcoming
  List<Birthday> get sorted {
    final list = [..._birthdays];
    list.sort((a, b) => a.daysUntil().compareTo(b.daysUntil()));
    return list;
  }

  // Birthdays in next 7 days
  List<Birthday> get upcoming =>
      sorted.where((b) => b.daysUntil() <= 7).toList();

  // Today's birthdays 🎉
  List<Birthday> get today =>
      _birthdays.where((b) => b.daysUntil() == 0).toList();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        _birthdays = Birthday.decodeList(raw);
      } catch (_) {
        _birthdays = [];
      }
    }
    notifyListeners();
  }

  Future<void> add(Birthday b) async {
    _birthdays.add(b);
    await _save();
    notifyListeners();
  }

  Future<void> update(Birthday b) async {
    final idx = _birthdays.indexWhere((e) => e.id == b.id);
    if (idx != -1) {
      _birthdays[idx] = b;
      await _save();
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    _birthdays.removeWhere((b) => b.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Birthday.encodeList(_birthdays));
  }
}
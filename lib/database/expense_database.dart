import 'package:flutter/foundation.dart';
import 'package:mini_habit_tracker/models/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseDatabase extends ChangeNotifier {
  static const _entriesKey = 'expense_entries';
  static const _profileKey = 'expense_profile';
  static const _currencyKey = 'expense_currency';

  List<ExpenseEntry> _entries = [];
  ExpenseProfile? _profile;
  ExpenseCurrency _currency = ExpenseCurrency.bdt;

  List<ExpenseEntry> get entries => List.unmodifiable(_entries);
  ExpenseProfile? get profile => _profile;
  ExpenseCurrency get currency => _currency;
  bool get hasProfile => _profile != null;

  // ─── Load ──────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final profileStr = prefs.getString(_profileKey);
    if (profileStr != null) {
      _profile = ExpenseProfile.values.firstWhere(
        (p) => p.name == profileStr,
        orElse: () => ExpenseProfile.student,
      );
    }

    final currencyStr = prefs.getString(_currencyKey);
    if (currencyStr != null) {
      _currency = ExpenseCurrency.values.firstWhere(
        (c) => c.name == currencyStr,
        orElse: () => ExpenseCurrency.bdt,
      );
    }

    final raw = prefs.getString(_entriesKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _entries = ExpenseEntry.decodeList(raw);
      } catch (_) {
        _entries = [];
      }
    }
    notifyListeners();
  }

  // ─── Set profile ───────────────────────────
  Future<void> setProfile(ExpenseProfile p) async {
    _profile = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, p.name);
    notifyListeners();
  }

  // ─── Set currency ──────────────────────────
  Future<void> setCurrency(ExpenseCurrency c) async {
    _currency = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, c.name);
    notifyListeners();
  }

  // ─── Add entry ─────────────────────────────
  Future<void> addEntry(ExpenseEntry entry) async {
    _entries.insert(0, entry);
    await _save();
    notifyListeners();
  }

  // ─── Delete entry ──────────────────────────
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_entriesKey, ExpenseEntry.encodeList(_entries));
  }

  // ─── Computed helpers ──────────────────────
  List<ExpenseEntry> get thisMonthEntries {
    final now = DateTime.now();
    return _entries
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
  }

  double get totalIncome => thisMonthEntries
      .where((e) => e.type == EntryType.income)
      .fold(0, (s, e) => s + e.amount);

  double get totalExpense => thisMonthEntries
      .where((e) => e.type == EntryType.expense)
      .fold(0, (s, e) => s + e.amount);

  double get balance => totalIncome - totalExpense;

  Map<ExpenseCategory, double> get categoryTotals {
    final map = <ExpenseCategory, double>{};
    for (final e
        in thisMonthEntries.where((e) => e.type == EntryType.expense)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}
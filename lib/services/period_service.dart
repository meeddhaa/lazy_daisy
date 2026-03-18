import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Models ────────────────────────────────────────────────────────────────────

enum FlowIntensity { spotting, light, medium, heavy }

enum PeriodSymptom {
  cramps,
  headache,
  bloating,
  backPain,
  moodSwings,
  fatigue,
  acne,
  breastTenderness,
  nausea,
  insomnia,
}

extension PeriodSymptomExt on PeriodSymptom {
  String get label {
    switch (this) {
      case PeriodSymptom.cramps:         return 'Cramps';
      case PeriodSymptom.headache:       return 'Headache';
      case PeriodSymptom.bloating:       return 'Bloating';
      case PeriodSymptom.backPain:       return 'Back Pain';
      case PeriodSymptom.moodSwings:     return 'Mood Swings';
      case PeriodSymptom.fatigue:        return 'Fatigue';
      case PeriodSymptom.acne:           return 'Acne';
      case PeriodSymptom.breastTenderness: return 'Tenderness';
      case PeriodSymptom.nausea:         return 'Nausea';
      case PeriodSymptom.insomnia:       return 'Insomnia';
    }
  }

  String get emoji {
    switch (this) {
      case PeriodSymptom.cramps:           return '🤕';
      case PeriodSymptom.headache:         return '🤯';
      case PeriodSymptom.bloating:         return '🫃';
      case PeriodSymptom.backPain:         return '🔙';
      case PeriodSymptom.moodSwings:       return '🌊';
      case PeriodSymptom.fatigue:          return '😴';
      case PeriodSymptom.acne:             return '😖';
      case PeriodSymptom.breastTenderness: return '💗';
      case PeriodSymptom.nausea:           return '🤢';
      case PeriodSymptom.insomnia:         return '🌙';
    }
  }
}

class DayLog {
  final DateTime date;
  final FlowIntensity? flow;
  final List<PeriodSymptom> symptoms;
  final String note;

  DayLog({
    required this.date,
    this.flow,
    this.symptoms = const [],
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'date': date.millisecondsSinceEpoch,
        'flow': flow?.name,
        'symptoms': symptoms.map((s) => s.name).toList(),
        'note': note,
      };

  factory DayLog.fromJson(Map<String, dynamic> j) => DayLog(
        date: DateTime.fromMillisecondsSinceEpoch(j['date'] as int),
        flow: j['flow'] != null
            ? FlowIntensity.values.firstWhere((e) => e.name == j['flow'],
                orElse: () => FlowIntensity.light)
            : null,
        symptoms: (j['symptoms'] as List<dynamic>)
            .map((s) => PeriodSymptom.values
                .firstWhere((e) => e.name == s, orElse: () => PeriodSymptom.cramps))
            .toList(),
        note: j['note'] as String? ?? '',
      );
}

class CycleRecord {
  final DateTime startDate;
  final DateTime? endDate;

  CycleRecord({required this.startDate, this.endDate});

  int get length {
    if (endDate == null) return 0;
    return endDate!.difference(startDate).inDays + 1;
  }

  Map<String, dynamic> toJson() => {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate?.millisecondsSinceEpoch,
      };

  factory CycleRecord.fromJson(Map<String, dynamic> j) => CycleRecord(
        startDate: DateTime.fromMillisecondsSinceEpoch(j['startDate'] as int),
        endDate: j['endDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(j['endDate'] as int)
            : null,
      );
}

// ── Service ───────────────────────────────────────────────────────────────────

class PeriodService extends ChangeNotifier {
  static const _keyCycles   = 'period_cycles_v1';
  static const _keyDayLogs  = 'period_day_logs_v1';
  static const _keyCycleLen = 'period_avg_cycle_len';

  List<CycleRecord> _cycles = [];
  List<DayLog> _dayLogs = [];
  int _avgCycleLength = 28;

  List<CycleRecord> get cycles => List.unmodifiable(_cycles);
  List<DayLog> get dayLogs => List.unmodifiable(_dayLogs);
  int get avgCycleLength => _avgCycleLength;

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cyclesRaw = prefs.getString(_keyCycles);
      final logsRaw = prefs.getString(_keyDayLogs);
      _avgCycleLength = prefs.getInt(_keyCycleLen) ?? 28;

      if (cyclesRaw != null) {
        final List decoded = jsonDecode(cyclesRaw);
        _cycles = decoded
            .map((e) => CycleRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (logsRaw != null) {
        final List decoded = jsonDecode(logsRaw);
        _dayLogs = decoded
            .map((e) => DayLog.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyCycles, jsonEncode(_cycles.map((c) => c.toJson()).toList()));
    await prefs.setString(
        _keyDayLogs, jsonEncode(_dayLogs.map((l) => l.toJson()).toList()));
    await prefs.setInt(_keyCycleLen, _avgCycleLength);
  }

  // ── Cycle management ──────────────────────────────────────────────────────

  bool get hasCycleInProgress =>
      _cycles.isNotEmpty && _cycles.last.endDate == null;

  CycleRecord? get currentCycle =>
      hasCycleInProgress ? _cycles.last : null;

  Future<void> startPeriod(DateTime date) async {
    // Close any open cycle first
    if (hasCycleInProgress) {
      final last = _cycles.removeLast();
      _cycles.add(CycleRecord(
          startDate: last.startDate,
          endDate: date.subtract(const Duration(days: 1))));
    }
    _cycles.add(CycleRecord(startDate: date));
    _recalcAvgCycle();
    await _save();
    notifyListeners();
  }

  Future<void> endPeriod(DateTime date) async {
    if (!hasCycleInProgress) return;
    final last = _cycles.removeLast();
    _cycles.add(CycleRecord(startDate: last.startDate, endDate: date));
    _recalcAvgCycle();
    await _save();
    notifyListeners();
  }

  void _recalcAvgCycle() {
    final completed = _cycles.where((c) => c.endDate != null).toList();
    if (completed.length < 2) return;
    // Average gap between start dates
    int totalGap = 0;
    for (int i = 1; i < completed.length; i++) {
      totalGap += completed[i]
          .startDate
          .difference(completed[i - 1].startDate)
          .inDays;
    }
    _avgCycleLength =
        (totalGap / (completed.length - 1)).round().clamp(21, 35);
  }

  // ── Day logging ──────────────────────────────────────────────────────────

  DayLog? logForDate(DateTime date) {
    try {
      return _dayLogs.firstWhere((l) =>
          l.date.year == date.year &&
          l.date.month == date.month &&
          l.date.day == date.day);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLog(DayLog log) async {
    _dayLogs.removeWhere((l) =>
        l.date.year == log.date.year &&
        l.date.month == log.date.month &&
        l.date.day == log.date.day);
    _dayLogs.add(log);
    await _save();
    notifyListeners();
  }

  Future<void> deleteLog(DateTime date) async {
    _dayLogs.removeWhere((l) =>
        l.date.year == date.year &&
        l.date.month == date.month &&
        l.date.day == date.day);
    await _save();
    notifyListeners();
  }

  // ── Predictions ───────────────────────────────────────────────────────────

  /// Next predicted period start
  DateTime? get nextPeriodDate {
    if (_cycles.isEmpty) return null;
    final lastStart = _cycles.last.startDate;
    return lastStart.add(Duration(days: _avgCycleLength));
  }

  /// Days until next period (negative = overdue)
  int? get daysUntilNextPeriod {
    final next = nextPeriodDate;
    if (next == null) return null;
    return next.difference(_today).inDays;
  }

  /// Fertile window: ovulation ≈ cycle day 14, fertile days 10–17
  DateTimeRange? get fertileWindow {
    if (_cycles.isEmpty) return null;
    final lastStart = _cycles.last.startDate;
    final nextStart = lastStart.add(Duration(days: _avgCycleLength));
    final ovulation = nextStart.subtract(const Duration(days: 14));
    return DateTimeRange(
      start: ovulation.subtract(const Duration(days: 4)),
      end: ovulation.add(const Duration(days: 3)),
    );
  }

  DateTime? get ovulationDate {
    final fw = fertileWindow;
    if (fw == null) return null;
    return fw.start.add(const Duration(days: 4));
  }

  /// Phase for a given date
  CyclePhase phaseFor(DateTime date) {
    if (_cycles.isEmpty) return CyclePhase.unknown;
    final lastStart = _cycles.last.startDate;

    // Is it a period day?
    for (final cycle in _cycles) {
      final end = cycle.endDate ?? cycle.startDate.add(const Duration(days: 5));
      if (!date.isBefore(cycle.startDate) && !date.isAfter(end)) {
        return CyclePhase.menstrual;
      }
    }

    // Compute predicted phases from last start
    final cycleDay = date.difference(lastStart).inDays % _avgCycleLength;
    final periodLen = _estimatedPeriodLength;

    if (cycleDay < periodLen) return CyclePhase.menstrual;
    if (cycleDay < 10) return CyclePhase.follicular;
    if (cycleDay < 17) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  int get _estimatedPeriodLength {
    final completed = _cycles.where((c) => c.endDate != null);
    if (completed.isEmpty) return 5;
    final avg = completed.map((c) => c.length).reduce((a, b) => a + b) /
        completed.length;
    return avg.round().clamp(3, 7);
  }

  bool isPeriodDay(DateTime date) {
    for (final cycle in _cycles) {
      final end = cycle.endDate ?? cycle.startDate.add(const Duration(days: 5));
      if (!date.isBefore(cycle.startDate) && !date.isAfter(end)) return true;
    }
    return false;
  }

  bool isFertileDay(DateTime date) {
    final fw = fertileWindow;
    if (fw == null) return false;
    return !date.isBefore(fw.start) && !date.isAfter(fw.end);
  }

  bool isOvulationDay(DateTime date) {
    final ov = ovulationDate;
    if (ov == null) return false;
    return date.year == ov.year &&
        date.month == ov.month &&
        date.day == ov.day;
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  /// Most logged symptom
  PeriodSymptom? get topSymptom {
    final freq = <PeriodSymptom, int>{};
    for (final log in _dayLogs) {
      for (final s in log.symptoms) {
        freq[s] = (freq[s] ?? 0) + 1;
      }
    }
    if (freq.isEmpty) return null;
    return freq.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int get totalCycles => _cycles.where((c) => c.endDate != null).length;
}

enum CyclePhase { menstrual, follicular, ovulation, luteal, unknown }

extension CyclePhaseExt on CyclePhase {
  String get label {
    switch (this) {
      case CyclePhase.menstrual:  return 'Menstrual';
      case CyclePhase.follicular: return 'Follicular';
      case CyclePhase.ovulation:  return 'Ovulation';
      case CyclePhase.luteal:     return 'Luteal';
      case CyclePhase.unknown:    return 'Unknown';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Your period. Rest & be gentle with yourself.';
      case CyclePhase.follicular:
        return 'Energy rising. Great time for new habits!';
      case CyclePhase.ovulation:
        return 'Peak energy & confidence. You\'re glowing!';
      case CyclePhase.luteal:
        return 'Winding down. Focus on calm habits.';
      case CyclePhase.unknown:
        return 'Log your first period to unlock insights.';
    }
  }

  int get color {
    switch (this) {
      case CyclePhase.menstrual:  return 0xFFEF5350;
      case CyclePhase.follicular: return 0xFF42A5F5;
      case CyclePhase.ovulation:  return 0xFF66BB6A;
      case CyclePhase.luteal:     return 0xFFAB47BC;
      case CyclePhase.unknown:    return 0xFF78909C;
    }
  }

  String get emoji {
    switch (this) {
      case CyclePhase.menstrual:  return '🌸';
      case CyclePhase.follicular: return '🌱';
      case CyclePhase.ovulation:  return '🌟';
      case CyclePhase.luteal:     return '🍂';
      case CyclePhase.unknown:    return '🌙';
    }
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});
}

import 'dart:convert';

class Birthday {
  final String id;
  final String name;
  final int day;
  final int month;
  final int? year; // optional — if null, age won't be shown
  final String emoji; // user picks a fun emoji
  final bool reminderEnabled;

  Birthday({
    required this.id,
    required this.name,
    required this.day,
    required this.month,
    this.year,
    this.emoji = '🎂',
    this.reminderEnabled = true,
  });

  // Next upcoming birthday (this year or next)
  DateTime nextBirthday() {
    final now = DateTime.now();
    final thisYear = DateTime(now.year, month, day);
    if (thisYear.isAfter(now) ||
        (thisYear.day == now.day && thisYear.month == now.month)) {
      return thisYear;
    }
    return DateTime(now.year + 1, month, day);
  }

  int daysUntil() {
    final now = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return nextBirthday().difference(now).inDays;
  }

  int? age() {
    if (year == null) return null;
    final next = nextBirthday();
    return next.year - year!;
  }

  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'day': day,
        'month': month,
        'year': year,
        'emoji': emoji,
        'reminderEnabled': reminderEnabled,
      };

  factory Birthday.fromJson(Map<String, dynamic> json) => Birthday(
        id: json['id'] as String,
        name: json['name'] as String,
        day: json['day'] as int,
        month: json['month'] as int,
        year: json['year'] as int?,
        emoji: json['emoji'] as String? ?? '🎂',
        reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      );

  Birthday copyWith({
    String? name,
    int? day,
    int? month,
    int? year,
    String? emoji,
    bool? reminderEnabled,
  }) =>
      Birthday(
        id: id,
        name: name ?? this.name,
        day: day ?? this.day,
        month: month ?? this.month,
        year: year ?? this.year,
        emoji: emoji ?? this.emoji,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      );

  static String encodeList(List<Birthday> list) =>
      jsonEncode(list.map((b) => b.toJson()).toList());

  static List<Birthday> decodeList(String source) {
    final List<dynamic> list = jsonDecode(source);
    return list
        .map((e) => Birthday.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
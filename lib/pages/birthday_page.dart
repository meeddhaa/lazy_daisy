import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/database/birthday_database.dart';
import 'package:mini_habit_tracker/models/birthday.dart';
import 'package:provider/provider.dart';

class BirthdayPage extends StatefulWidget {
  const BirthdayPage({super.key});

  @override
  State<BirthdayPage> createState() => _BirthdayPageState();
}

class _BirthdayPageState extends State<BirthdayPage> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int? _selectedDay;

  static const List<String> _emojiOptions = [
    '🎂', '🎁', '🎉', '🥳', '🌸', '⭐', '🌈', '🦋',
    '🌺', '💖', '🎀', '🐣', '🍰', '🎈', '✨', '🌙',
  ];

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _selectedDay = null;
    });
  }

  // Birthdays in the focused month
  List<Birthday> _birthdaysInMonth(List<Birthday> all) =>
      all.where((b) => b.month == _focusedMonth.month).toList()
        ..sort((a, b) => a.day.compareTo(b.day));

  // Birthdays on a specific day of focused month
  List<Birthday> _birthdaysOnDay(List<Birthday> all, int day) =>
      all.where((b) => b.month == _focusedMonth.month && b.day == day).toList();

  void _openAddSheet({Birthday? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    int selectedDay = existing?.day ?? (_selectedDay ?? 1);
    int selectedMonth = existing?.month ?? _focusedMonth.month;
    int? selectedYear = existing?.year;
    String selectedEmoji = existing?.emoji ?? '🎂';
    bool reminderEnabled = existing?.reminderEnabled ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 24,
            left: 22,
            right: 22,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  existing == null ? '🎉 Add Birthday' : '✏️ Edit Birthday',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // Emoji picker
                const Text('Choose an emoji',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _emojiOptions.map((e) {
                    final isSelected = e == selectedEmoji;
                    return GestureDetector(
                      onTap: () => setS(() => selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE6E6FA)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF9370DB)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                            child:
                                Text(e, style: const TextStyle(fontSize: 22))),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Name
                const Text('Name',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(14)),
                  child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Mum, Best Friend, Grandpa',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Date
                const Text('Birthday Date',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DateDropdown(
                        label: 'Day',
                        value: selectedDay,
                        items: List.generate(31, (i) => i + 1),
                        onChanged: (v) => setS(() => selectedDay = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _DateDropdown(
                        label: 'Month',
                        value: selectedMonth,
                        items: List.generate(12, (i) => i + 1),
                        itemLabels: _monthNames,
                        onChanged: (v) => setS(() => selectedMonth = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateDropdown<int?>(
                        label: 'Year',
                        value: selectedYear,
                        items: [
                          null,
                          ...List.generate(100, (i) => DateTime.now().year - i)
                        ],
                        itemLabels: [
                          'N/A',
                          ...List.generate(
                              100, (i) => (DateTime.now().year - i).toString())
                        ],
                        onChanged: (v) => setS(() => selectedYear = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reminder
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Text('🔔', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Remind me',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                            Text('1 day before',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black45)),
                          ],
                        ),
                      ),
                      Switch(
                        value: reminderEnabled,
                        onChanged: (v) => setS(() => reminderEnabled = v),
                        activeColor: const Color(0xFF9370DB),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      final db = context.read<BirthdayDatabase>();
                      if (existing == null) {
                        db.add(Birthday(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          name: name,
                          day: selectedDay,
                          month: selectedMonth,
                          year: selectedYear,
                          emoji: selectedEmoji,
                          reminderEnabled: reminderEnabled,
                        ));
                      } else {
                        db.update(existing.copyWith(
                          name: name,
                          day: selectedDay,
                          month: selectedMonth,
                          year: selectedYear,
                          emoji: selectedEmoji,
                          reminderEnabled: reminderEnabled,
                        ));
                      }
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9370DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      existing == null ? '🎉 Save Birthday' : '✅ Update',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayDatabase>(
      builder: (context, db, _) {
        final allBirthdays = db.birthdays;
        final monthBirthdays = _birthdaysInMonth(allBirthdays.toList());
        final selectedDayBirthdays = _selectedDay != null
            ? _birthdaysOnDay(allBirthdays.toList(), _selectedDay!)
            : <Birthday>[];
        final todayList = db.today;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
            title: const Text('🎂 Birthdays',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black87)),
            centerTitle: false,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddSheet(),
            backgroundColor: const Color(0xFF9370DB),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: [
              // 🎉 Today banner
              if (todayList.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTodayBanner(todayList),
              ],

              const SizedBox(height: 16),

              // ─── Calendar Card ───────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    // Month navigation header
                    _buildMonthHeader(),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    const SizedBox(height: 8),
                    // Weekday labels
                    _buildWeekdayRow(),
                    const SizedBox(height: 4),
                    // Calendar grid
                    _buildCalendarGrid(allBirthdays.toList()),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Selected day birthdays ──────
              if (_selectedDay != null && selectedDayBirthdays.isNotEmpty) ...[
                _buildSectionHeader(
                    '🎯 ${_selectedDay} ${_monthNames[_focusedMonth.month - 1]}'),
                const SizedBox(height: 10),
                ...selectedDayBirthdays.map((b) => _BirthdayTile(
                      birthday: b,
                      onEdit: () => _openAddSheet(existing: b),
                      onDelete: () =>
                          context.read<BirthdayDatabase>().delete(b.id),
                    )),
                const SizedBox(height: 16),
              ],

              // ─── This month's birthdays ──────
              if (monthBirthdays.isNotEmpty) ...[
                _buildSectionHeader(
                    '🎈 ${_monthNames[_focusedMonth.month - 1]}\'s Birthdays'),
                const SizedBox(height: 10),
                ...monthBirthdays.map((b) => _BirthdayTile(
                      birthday: b,
                      onEdit: () => _openAddSheet(existing: b),
                      onDelete: () =>
                          context.read<BirthdayDatabase>().delete(b.id),
                    )),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    children: [
                      const Text('🌸',
                          style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(
                        'No birthdays in ${_monthNames[_focusedMonth.month - 1]}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black45),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ─── Month Header ──────────────────────────
  Widget _buildMonthHeader() {
    final now = DateTime.now();
    final isCurrentMonth = _focusedMonth.year == now.year &&
        _focusedMonth.month == now.month;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _prevMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_left,
                  color: Colors.black54, size: 22),
            ),
          ),
          Column(
            children: [
              Text(
                _monthNames[_focusedMonth.month - 1],
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Text(
                _focusedMonth.year.toString(),
                style: TextStyle(
                    fontSize: 13,
                    color: isCurrentMonth
                        ? const Color(0xFF9370DB)
                        : Colors.black38,
                    fontWeight: isCurrentMonth
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
            ],
          ),
          GestureDetector(
            onTap: _nextMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_right,
                  color: Colors.black54, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Weekday row ───────────────────────────
  Widget _buildWeekdayRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _weekDays
            .map((d) => SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(d,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: (d == 'Sat' || d == 'Sun')
                                ? const Color(0xFF9370DB).withOpacity(0.6)
                                : Colors.black38)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ─── Calendar Grid ─────────────────────────
  Widget _buildCalendarGrid(List<Birthday> allBirthdays) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    // weekday: Mon=1 ... Sun=7, we want Mon=0 offset
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final today = DateTime.now();
    final isCurrentMonth = _focusedMonth.year == today.year &&
        _focusedMonth.month == today.month;

    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final day = cellIndex - startOffset + 1;

              if (day < 1 || day > daysInMonth) {
                return const SizedBox(width: 36, height: 44);
              }

              final birthdaysOnDay = _birthdaysOnDay(allBirthdays, day);
              final hasBirthday = birthdaysOnDay.isNotEmpty;
              final isToday = isCurrentMonth && day == today.day;
              final isSelected = _selectedDay == day;
              final isWeekend = col >= 5; // Sat=5, Sun=6

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = isSelected ? null : day;
                  });
                },
                child: SizedBox(
                  width: 36,
                  height: 44,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF9370DB)
                              : isToday
                                  ? const Color(0xFFE6E6FA)
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isToday && !isSelected
                              ? Border.all(
                                  color: const Color(0xFF9370DB), width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: (isToday || isSelected || hasBirthday)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? const Color(0xFF9370DB)
                                      : isWeekend
                                          ? const Color(0xFF9370DB)
                                              .withOpacity(0.7)
                                          : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      // Birthday dots
                      if (hasBirthday)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...birthdaysOnDay.take(3).map((b) => Container(
                                  width: 5,
                                  height: 5,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFFFF80AB),
                                    shape: BoxShape.circle,
                                  ),
                                )),
                          ],
                        )
                      else
                        const SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  // ─── Today banner ──────────────────────────
  Widget _buildTodayBanner(List<Birthday> todayList) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9370DB), Color(0xFFB39DDB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF9370DB).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎉 Today\'s Birthdays!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...todayList.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(b.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        if (b.age() != null)
                          Text('Turning ${b.age()} today! 🥳',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black54));
  }
}

// ─────────────────────────────────────────────
// Birthday Tile
// ─────────────────────────────────────────────
class _BirthdayTile extends StatelessWidget {
  final Birthday birthday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BirthdayTile({
    required this.birthday,
    required this.onEdit,
    required this.onDelete,
  });

  String _daysLabel() {
    final d = birthday.daysUntil();
    if (d == 0) return '🎉 Today!';
    if (d == 1) return '⏰ Tomorrow!';
    if (d <= 7) return 'In $d days';
    return 'In $d days';
  }

  Color _daysColor() {
    final d = birthday.daysUntil();
    if (d == 0) return const Color(0xFF9370DB);
    if (d == 1) return const Color(0xFFFF7043);
    if (d <= 7) return const Color(0xFFFFB300);
    return Colors.black45;
  }

  @override
  Widget build(BuildContext context) {
    final isClose = birthday.daysUntil() <= 7;

    return Dismissible(
      key: Key(birthday.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Remove Birthday?'),
          content: Text('Remove ${birthday.name}\'s birthday?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.black54))),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0),
                child: const Text('Remove')),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: isClose
                ? Border.all(
                    color: const Color(0xFF9370DB).withOpacity(0.25),
                    width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(
            children: [
              // Emoji + day number stacked
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E6FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                        child: Text(birthday.emoji,
                            style: const TextStyle(fontSize: 26))),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9370DB),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '${birthday.day}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(birthday.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.cake,
                            size: 12, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(
                          '${birthday.day} ${birthday.monthName}' +
                              (birthday.year != null
                                  ? ', ${birthday.year}'
                                  : ''),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black45),
                        ),
                        if (birthday.age() != null) ...[
                          const Text(' · ',
                              style:
                                  TextStyle(color: Colors.black26)),
                          Text('Turns ${birthday.age()}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black38)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _daysColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _daysLabel(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _daysColor()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Date Dropdown helper
// ─────────────────────────────────────────────
class _DateDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final List<String>? itemLabels;
  final ValueChanged<T?> onChanged;

  const _DateDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(label,
              style:
                  const TextStyle(fontSize: 13, color: Colors.black45)),
          items: items.asMap().entries.map((entry) {
            final lbl = itemLabels != null
                ? itemLabels![entry.key]
                : entry.value.toString();
            return DropdownMenuItem<T>(
              value: entry.value,
              child: Text(lbl,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
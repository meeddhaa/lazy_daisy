import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Event types (Birthday removed)
  static const List<Map<String, dynamic>> _eventTypes = [
    {'label': 'Event', 'icon': Icons.event_rounded, 'color': Color(0xFF7C6FF7)},
    {'label': 'Schedule', 'icon': Icons.schedule_rounded, 'color': Color(0xFFFF7BAC)},
    {'label': 'Reminder', 'icon': Icons.notifications_rounded, 'color': Color(0xFFFFB347)},
    {'label': 'Goal', 'icon': Icons.flag_rounded, 'color': Color(0xFF4FC3A1)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString('calendar_events_v2');
    if (eventsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(eventsJson);
      setState(() {
        _events = decoded.map((key, value) {
          return MapEntry(
            DateTime.parse(key),
            List<Map<String, dynamic>>.from(value),
          );
        });
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> eventsToSave = _events.map((key, value) {
      return MapEntry(key.toIso8601String(), value);
    });
    await prefs.setString('calendar_events_v2', jsonEncode(eventsToSave));
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Map<String, dynamic> _getTypeInfo(String type) {
    return _eventTypes.firstWhere(
      (t) => t['label'] == type,
      orElse: () => _eventTypes[0],
    );
  }

  void _showEventSheet({
    int? editIndex,
    String? initialTitle,
    String? initialType,
    String? initialNote,
  }) {
    final titleController = TextEditingController(text: initialTitle ?? '');
    final noteController = TextEditingController(text: initialNote ?? '');
    String selectedType = initialType ?? 'Event';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final typeInfo = _getTypeInfo(selectedType);
            final Color accentColor = typeInfo['color'];

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1B2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    editIndex == null ? 'New Event' : 'Edit Event',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    _formatHeaderDate(_selectedDay!),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'What\'s happening?',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: Icon(typeInfo['icon'], color: accentColor, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Note field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: noteController,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Add a note (optional)...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Type chips
                  const Text(
                    'TYPE',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: _eventTypes.map((type) {
                      final isSelected = selectedType == type['label'];
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedType = type['label']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (type['color'] as Color).withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? type['color'] as Color
                                  : Colors.white12,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                size: 14,
                                color: isSelected ? type['color'] as Color : Colors.white38,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                type['label'] as String,
                                style: TextStyle(
                                  color: isSelected ? type['color'] as Color : Colors.white38,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            if (titleController.text.trim().isNotEmpty) {
                              final selectedDate = DateTime(
                                _selectedDay!.year,
                                _selectedDay!.month,
                                _selectedDay!.day,
                              );
                              setState(() {
                                if (_events[selectedDate] == null) {
                                  _events[selectedDate] = [];
                                }
                                final entry = {
                                  'title': titleController.text.trim(),
                                  'type': selectedType,
                                  'note': noteController.text.trim(),
                                };
                                if (editIndex == null) {
                                  _events[selectedDate]!.add(entry);
                                } else {
                                  _events[selectedDate]![editIndex] = entry;
                                }
                              });
                              _saveEvents();
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accentColor, accentColor.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                editIndex == null ? 'Add Event' : 'Save Changes',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteEvent(int index) {
    final selectedDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('This event will be permanently removed.', style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _events[selectedDate]!.removeAt(index);
                if (_events[selectedDate]!.isEmpty) {
                  _events.remove(selectedDate);
                }
              });
              _saveEvents();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatHeaderDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekday = days[date.weekday - 1];
    return '$weekday, ${months[date.month - 1]} ${date.day}';
  }

  int _getTotalEventsThisMonth() {
    int count = 0;
    for (final entry in _events.entries) {
      if (entry.key.year == _focusedDay.year && entry.key.month == _focusedDay.month) {
        count += entry.value.length;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final todayEvents = _getEventsForDay(_selectedDay!);
    final isToday = _selectedDay != null &&
        _selectedDay!.year == DateTime.now().year &&
        _selectedDay!.month == DateTime.now().month &&
        _selectedDay!.day == DateTime.now().day;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1A),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 24,
                  right: 24,
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Calendar',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${_getTotalEventsThisMonth()} events this month',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Legend dots
                    Row(
                      children: _eventTypes.take(3).map((t) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: t['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Calendar
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B2E),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: const TextStyle(color: Colors.white70),
                    weekendTextStyle: TextStyle(color: const Color(0xFF7C6FF7).withOpacity(0.8)),
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF7C6FF7).withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF7C6FF7), width: 1.5),
                    ),
                    todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF7C6FF7),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFFFF7BAC),
                      shape: BoxShape.circle,
                    ),
                    markerSize: 5,
                    markerMargin: const EdgeInsets.only(top: 1),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      color: const Color(0xFF7C6FF7).withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonDecoration: BoxDecoration(
                      color: const Color(0xFF7C6FF7).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF7C6FF7).withOpacity(0.4)),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Color(0xFF7C6FF7), fontSize: 12),
                    titleTextStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white54),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white54),
                  ),
                ),
              ),
            ),

            // Selected day header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isToday ? 'Today' : _formatHeaderDate(_selectedDay!),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            todayEvents.isEmpty
                                ? 'Nothing scheduled'
                                : '${todayEvents.length} event${todayEvents.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Type summary dots
                    if (todayEvents.isNotEmpty)
                      ...todayEvents.map((e) {
                        final info = _getTypeInfo(e['type']);
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: info['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            // Events list
            if (todayEvents.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 40,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No events here',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + to add something',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = todayEvents[index];
                    final typeInfo = _getTypeInfo(event['type']);
                    final Color accentColor = typeInfo['color'];

                    return Slidable(
                      key: ValueKey('${_selectedDay}_$index'),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _showEventSheet(
                              editIndex: index,
                              initialTitle: event['title'],
                              initialType: event['type'],
                              initialNote: event['note'],
                            ),
                            backgroundColor: const Color(0xFF7C6FF7),
                            foregroundColor: Colors.white,
                            icon: Icons.edit_rounded,
                            label: 'Edit',
                            borderRadius: BorderRadius.circular(16),
                          ),
                          SlidableAction(
                            onPressed: (_) => _deleteEvent(index),
                            backgroundColor: const Color(0xFFFF4757),
                            foregroundColor: Colors.white,
                            icon: Icons.delete_rounded,
                            label: 'Delete',
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B2E),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: accentColor.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(typeInfo['icon'], color: accentColor, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (event['note'] != null && (event['note'] as String).isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      event['note'],
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.45),
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event['type'],
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: todayEvents.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventSheet(),
        backgroundColor: const Color(0xFF7C6FF7),
        elevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Event',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
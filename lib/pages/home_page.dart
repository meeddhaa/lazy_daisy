import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mini_habit_tracker/components/category_filter_bar.dart';
import 'package:mini_habit_tracker/components/category_picker.dart';
import 'package:mini_habit_tracker/components/difficulty_picker.dart';
import 'package:mini_habit_tracker/components/my_habit_tile.dart';
import 'package:mini_habit_tracker/components/reminder_time_picker.dart';
import 'package:mini_habit_tracker/components/xp_level_bar.dart';
import 'package:mini_habit_tracker/database/birthday_database.dart';
import 'package:mini_habit_tracker/database/habit_database.dart';
import 'package:mini_habit_tracker/models/habit.dart';
import 'package:mini_habit_tracker/pages/ai_suggestions_page.dart';
import 'package:mini_habit_tracker/pages/birthday_page.dart';
import 'package:mini_habit_tracker/pages/calendar_page.dart';
import 'package:mini_habit_tracker/pages/challenges_page.dart';
import 'package:mini_habit_tracker/pages/expense_page.dart';
import 'package:mini_habit_tracker/pages/habit_templates_page.dart';
import 'package:mini_habit_tracker/pages/notepad_page.dart';
import 'package:mini_habit_tracker/pages/period_tracker_page.dart';
import 'package:mini_habit_tracker/pages/progress_page.dart';
import 'package:mini_habit_tracker/pages/settings_page.dart';
import 'package:mini_habit_tracker/pages/mood_tracker_page.dart';
import 'package:mini_habit_tracker/services/user_service.dart';
import 'package:mini_habit_tracker/util/habit_util.dart';
import 'package:mini_habit_tracker/util/notification_helper.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController();
  final NotificationHelper notificationHelper = NotificationHelper();
  DateTime selectedDate = DateTime.now();

  HabitCategory? selectedCategory;
  HabitCategory _newHabitCategory = HabitCategory.personal;
  TimeOfDay? _newHabitReminder;
  HabitDifficulty _newHabitDifficulty = HabitDifficulty.easy;

  @override
  void initState() {
    super.initState();
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    Provider.of<BirthdayDatabase>(context, listen: false).load();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final now = DateTime.now();
      int testMinute = now.minute + 1;
      int testHour = now.hour;
      if (testMinute >= 60) {
        testMinute = 0;
        testHour = (testHour + 1) % 24;
      }
      await notificationHelper.showDailyReminder(testHour, testMinute, context);
    });
  }

  void _clearController() {
    textController.clear();
    _newHabitCategory = HabitCategory.personal;
    _newHabitReminder = null;
    _newHabitDifficulty = HabitDifficulty.easy;
  }

  void openTemplates() async {
    final selected = await Navigator.push<List<HabitTemplate>>(
      context,
      MaterialPageRoute(builder: (_) => const HabitTemplatesPage()),
    );
    if (selected != null && selected.isNotEmpty) {
      for (final template in selected) {
        await context.read<HabitDatabase>().addHabit(
              template.name,
              category: template.category,
            );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '✅ Added ${selected.length} habit${selected.length > 1 ? 's' : ''}!'),
          backgroundColor: const Color(0xFF9370DB),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void createNewHabit(BuildContext context) {
    _newHabitCategory = HabitCategory.personal;
    _newHabitReminder = null;
    _newHabitDifficulty = HabitDifficulty.easy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add New Habit",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: "Create a new Habit",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CategoryPicker(
                      selected: _newHabitCategory,
                      onSelected: (cat) =>
                          setModalState(() => _newHabitCategory = cat),
                    ),
                    const SizedBox(height: 20),
                    DifficultyPicker(
                      selected: _newHabitDifficulty,
                      onSelected: (d) =>
                          setModalState(() => _newHabitDifficulty = d),
                    ),
                    const SizedBox(height: 20),
                    ReminderTimePicker(
                      selectedTime: _newHabitReminder,
                      onTimeSelected: (time) =>
                          setModalState(() => _newHabitReminder = time),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearController();
                          },
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.black54)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final newHabitName = textController.text.trim();
                            if (newHabitName.isNotEmpty) {
                              context.read<HabitDatabase>().addHabit(
                                    newHabitName,
                                    category: _newHabitCategory,
                                    reminderHour:
                                        _newHabitReminder?.hour ?? -1,
                                    reminderMinute:
                                        _newHabitReminder?.minute ?? -1,
                                    difficulty: _newHabitDifficulty,
                                  );
                            }
                            Navigator.pop(context);
                            _clearController();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFACD),
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabitBox(Habit habit) {
    textController.text = habit.name;
    HabitCategory editCategory = habit.getCategory();
    TimeOfDay? editReminder = habit.getReminderTime();
    HabitDifficulty editDifficulty = habit.getDifficulty();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Habit",
              style: TextStyle(color: Colors.black87)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: "Edit Habit Name",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CategoryPicker(
                  selected: editCategory,
                  onSelected: (cat) =>
                      setDialogState(() => editCategory = cat),
                ),
                const SizedBox(height: 16),
                DifficultyPicker(
                  selected: editDifficulty,
                  onSelected: (d) => setDialogState(() => editDifficulty = d),
                ),
                const SizedBox(height: 16),
                ReminderTimePicker(
                  selectedTime: editReminder,
                  onTimeSelected: (time) =>
                      setDialogState(() => editReminder = time),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearController();
              },
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedName = textController.text.trim();
                if (updatedName.isNotEmpty) {
                  context.read<HabitDatabase>().updateHabitName(
                        habit.id,
                        updatedName,
                        category: editCategory,
                        reminderHour: editReminder?.hour ?? -1,
                        reminderMinute: editReminder?.minute ?? -1,
                        difficulty: editDifficulty,
                      );
                }
                Navigator.pop(context);
                _clearController();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFACD),
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Habit',
            style: TextStyle(color: Colors.black87)),
        content: const Text('Are you sure you want to remove this habit?',
            style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<HabitDatabase>().deleteHabit(habit.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;
          final isToday = date.day == today.day &&
              date.month == today.month &&
              date.year == today.year;
          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE6E6FA)
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: isToday
                    ? Border.all(color: const Color(0xFFFFFACD), width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_getDayName(date.weekday),
                      style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(date.day.toString(),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87)),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFFFFACD),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[weekday - 1];
  }

  Widget _buildBirthdayBanner() {
    return Consumer<BirthdayDatabase>(
      builder: (context, db, _) {
        final upcoming = db.upcoming;
        if (upcoming.isEmpty) return const SizedBox.shrink();
        final todayBirthdays =
            upcoming.where((b) => b.daysUntil() == 0).toList();
        final soonBirthdays =
            upcoming.where((b) => b.daysUntil() > 0).toList();
        final showList =
            [...todayBirthdays, ...soonBirthdays].take(3).toList();

        return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BirthdayPage())),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0F5), Color(0xFFE6E6FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: const Color(0xFF9370DB).withOpacity(0.2), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🎂 Upcoming Birthdays',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: Colors.black38),
                  ],
                ),
                const SizedBox(height: 10),
                ...showList.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(b.emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(b.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: b.daysUntil() == 0
                                  ? const Color(0xFF9370DB).withOpacity(0.15)
                                  : b.daysUntil() == 1
                                      ? const Color(0xFFFF7043)
                                          .withOpacity(0.12)
                                      : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              b.daysUntil() == 0
                                  ? '🎉 Today!'
                                  : b.daysUntil() == 1
                                      ? '⏰ Tomorrow'
                                      : 'In ${b.daysUntil()}d',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: b.daysUntil() == 0
                                      ? const Color(0xFF9370DB)
                                      : b.daysUntil() == 1
                                          ? const Color(0xFFFF7043)
                                          : Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitList() {
    return Consumer<HabitDatabase>(
      builder: (context, db, _) {
        final allHabits = db.currentHabits;
        final habits = selectedCategory == null
            ? allHabits
            : allHabits
                .where((h) => h.getCategory() == selectedCategory)
                .toList();

        if (habits.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(
                    selectedCategory == null
                        ? Icons.playlist_add_check
                        : Icons.filter_list_off,
                    size: 60,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedCategory == null
                        ? "No habits yet? Add one!"
                        : "No ${selectedCategory!.label} habits yet!",
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: habits.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final habit = habits[index];
            final completedDates = habit.completedDays
                .map((ms) => DateTime.fromMillisecondsSinceEpoch(ms))
                .toList();
            final isCompletedToday = isHabitCompletedToday(completedDates);

            return MyHabitTile(
              text: habit.name,
              isHabitCompletedToday: isCompletedToday,
              onChanged: (value) => checkHabitOnOff(value, habit),
              editHabit: (context) => editHabitBox(habit),
              deleteHabit: (context) => deleteHabitBox(habit),
              completedDays: completedDates,
              categoryColor: habit.getCategory().color,
              categoryEmoji: habit.getCategory().emoji,
              reminderTime: habit.getReminderTime(),
              difficulty: habit.getDifficulty(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text('Today',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 28)),
        centerTitle: false,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE6E6FA), Color(0xFFFFFACD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FaIcon(FontAwesomeIcons.seedling,
                      size: 40, color: Color(0xFF9370DB)),
                  SizedBox(height: 10),
                  Text('Mini Habit Tracker',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.calendarDays,
                  color: Color(0xFFFFFACD)),
              title: const Text('Calendar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CalendarPage()));
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.chartLine,
                  color: Color(0xFFE6E6FA)),
              title: const Text('Progress Analytics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProgressPage()));
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.trophy,
                  color: Color(0xFFFFD700)),
              title: const Text('Challenges'),
              subtitle: const Text('Weekly & monthly goals',
                  style: TextStyle(fontSize: 11, color: Colors.black45)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const ChallengesPage()));
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.wandMagicSparkles,
                  color: Color(0xFF9370DB)),
              title: const Text('AI Habit Coach'),
              subtitle: const Text('Get personalised suggestions',
                  style: TextStyle(fontSize: 11, color: Colors.black45)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const AISuggestionsPage()));
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.moneyBillWave,
                  color: Color(0xFF4CAF50)),
              title: const Text('Expense Sheet'),
              subtitle: const Text('Track income & spending',
                  style: TextStyle(fontSize: 11, color: Colors.black45)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ExpensePage()));
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.cakeCandles,
                  color: Color(0xFFFF80AB)),
              title: const Text('Birthdays'),
              subtitle: const Text('Never forget a birthday 🎂',
                  style: TextStyle(fontSize: 11, color: Colors.black45)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const BirthdayPage()));
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.noteSticky,
                  color: Color(0xFFB4E7CE)),
              title: const Text('Notepad'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotepadPage()));
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.layerGroup,
                  color: Color(0xFF9370DB)),
              title: const Text('Habit Templates'),
              subtitle: const Text('Quick-start packs',
                  style: TextStyle(fontSize: 11, color: Colors.black45)),
              onTap: () {
                Navigator.pop(context);
                openTemplates();
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.faceSmile,
                  color: Color(0xFFFFB6C1)),
              title: const Text('Mood Tracker'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const MoodTrackerPage()));
              },
            ),

            // ✅ Cycle Tracker — only visible for female users
            Consumer<UserService>(
              builder: (ctx, userSvc, _) {
                if (!userSvc.isFemale) return const SizedBox.shrink();
                return ListTile(
                  leading: const FaIcon(FontAwesomeIcons.droplet,
                      color: Color(0xFFFF6B9D)),
                  title: const Text('Cycle Tracker'),
                  subtitle: const Text('Period & fertility tracking',
                      style: TextStyle(fontSize: 11, color: Colors.black45)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PeriodTrackerPage()));
                  },
                );
              },
            ),

            ListTile(
              leading: const FaIcon(FontAwesomeIcons.gear,
                  color: Color(0xFFE6E6FA)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.rightFromBracket,
                  color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error logging out: $e')));
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createNewHabit(context),
        elevation: 3,
        backgroundColor: const Color(0xFFFFFACD),
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDatePicker(),
          Consumer<HabitDatabase>(
            builder: (context, db, _) =>
                XPLevelBar(habits: db.currentHabits),
          ),
          _buildBirthdayBanner(),
          CategoryFilterBar(
            selectedCategory: selectedCategory,
            onCategorySelected: (cat) =>
                setState(() => selectedCategory = cat),
          ),
          const SizedBox(height: 16),
          _buildHabitList(),
        ],
      ),
    );
  }
}
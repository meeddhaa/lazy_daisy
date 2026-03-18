// lib/pages/ai_suggestions_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_tracker/database/habit_database.dart';
import 'package:mini_habit_tracker/models/habit.dart';
import 'package:mini_habit_tracker/services/ai_habit_service.dart';

class AISuggestionsPage extends StatefulWidget {
  const AISuggestionsPage({super.key});

  @override
  State<AISuggestionsPage> createState() => _AISuggestionsPageState();
}

class _AISuggestionsPageState extends State<AISuggestionsPage> {
  final TextEditingController _goalController = TextEditingController();
  List<AISuggestedHabit> _suggestions = [];
  final Set<int> _selectedIndexes = {};
  final Set<int> _addedIndexes = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Quick goal chips for faster input
  final List<String> _quickGoals = [
    'Get fit and healthy 💪',
    'Be more productive 🚀',
    'Reduce stress & anxiety 🧘',
    'Learn new skills 📚',
    'Sleep better 😴',
    'Save more money 💰',
    'Be more social 🤝',
    'Build a morning routine ☀️',
  ];

  Future<void> _getSuggestions() async {
    final goal = _goalController.text.trim();
    if (goal.isEmpty) {
      setState(() => _errorMessage = 'Please enter your goal first!');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _suggestions = [];
      _selectedIndexes.clear();
      _addedIndexes.clear();
    });

    try {
      final db = context.read<HabitDatabase>();
      final existingNames =
          db.currentHabits.map((h) => h.name).toList();

      final suggestions = await AIHabitService.getSuggestions(
        userGoal: goal,
        existingHabits: existingNames,
      );

      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not get suggestions. Check your API key and internet connection.';
      });
    }
  }

  Future<void> _addSelected() async {
    if (_selectedIndexes.isEmpty) return;
    final db = context.read<HabitDatabase>();

    for (final index in _selectedIndexes) {
      final habit = _suggestions[index];
      await db.addHabit(
        habit.name,
        category: habit.category,
        difficulty: habit.difficulty,
      );
      _addedIndexes.add(index);
    }

    setState(() => _selectedIndexes.clear());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '✅ Added ${_addedIndexes.length} habit${_addedIndexes.length == 1 ? '' : 's'}!'),
        backgroundColor: const Color(0xFF9370DB),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'AI Habit Coach 🤖',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE6E6FA), Color(0xFFFFFACD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✨ Tell me your goal',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 6),
                Text(
                  'I\'ll suggest personalised habits based on what you want to achieve.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Goal input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: TextField(
              controller: _goalController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText:
                    'e.g. "I want to get fit and have more energy"',
                hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick goal chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickGoals.map((goal) {
              return GestureDetector(
                onTap: () {
                  _goalController.text = goal;
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _goalController.text == goal
                          ? const Color(0xFF9370DB)
                          : Colors.black12,
                      width: _goalController.text == goal ? 1.5 : 1,
                    ),
                  ),
                  child: Text(goal,
                      style: TextStyle(
                        fontSize: 12,
                        color: _goalController.text == goal
                            ? const Color(0xFF9370DB)
                            : Colors.black54,
                        fontWeight: _goalController.text == goal
                            ? FontWeight.bold
                            : FontWeight.normal,
                      )),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _getSuggestions,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isLoading ? 'Thinking...' : 'Generate My Habits',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9370DB),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF9370DB).withOpacity(0.5),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMessage!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],

          // Suggestions list
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Suggested Habits',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Text('${_suggestions.length} suggestions',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black45)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Tap cards to select, then add them all at once',
                style: TextStyle(fontSize: 12, color: Colors.black38)),
            const SizedBox(height: 16),
            ..._suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final habit = entry.value;
              final isSelected = _selectedIndexes.contains(index);
              final isAdded = _addedIndexes.contains(index);
              return _SuggestionCard(
                habit: habit,
                isSelected: isSelected,
                isAdded: isAdded,
                onTap: isAdded
                    ? null
                    : () {
                        setState(() {
                          if (isSelected) {
                            _selectedIndexes.remove(index);
                          } else {
                            _selectedIndexes.add(index);
                          }
                        });
                      },
              );
            }),

            // Add selected button
            if (_selectedIndexes.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addSelected,
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(
                    'Add ${_selectedIndexes.length} Selected Habit${_selectedIndexes.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }
}

// ─── Suggestion Card ─────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  final AISuggestedHabit habit;
  final bool isSelected;
  final bool isAdded;
  final VoidCallback? onTap;

  const _SuggestionCard({
    required this.habit,
    required this.isSelected,
    required this.isAdded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = habit.category.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAdded
                ? Colors.green
                : isSelected
                    ? const Color(0xFF9370DB)
                    : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF9370DB).withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category color dot + emoji
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(habit.category.emoji,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),

            // Name + reason + badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          habit.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isAdded)
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20)
                      else if (isSelected)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF9370DB), size: 20)
                      else
                        Icon(Icons.add_circle_outline,
                            color: Colors.black26, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.reason,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${habit.category.emoji} ${habit.category.label}',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color.withOpacity(0.8)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: habit.difficulty.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${habit.difficulty.emoji} ${habit.difficulty.label} · +${habit.difficulty.xp}XP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: habit.difficulty.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
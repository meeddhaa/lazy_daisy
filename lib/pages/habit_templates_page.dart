import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/models/habit.dart';

// ─────────────────────────────────────────────
// Template Model
// ─────────────────────────────────────────────
class HabitTemplate {
  final String name;
  final HabitCategory category;
  final String emoji;
  final String description;

  const HabitTemplate({
    required this.name,
    required this.category,
    required this.emoji,
    required this.description,
  });
}

class HabitTemplatePack {
  final String title;
  final String emoji;
  final String description;
  final Color color;
  final List<HabitTemplate> habits;

  const HabitTemplatePack({
    required this.title,
    required this.emoji,
    required this.description,
    required this.color,
    required this.habits,
  });
}

// ─────────────────────────────────────────────
// Template Data
// ─────────────────────────────────────────────
final List<HabitTemplatePack> habitTemplatePacks = [
  HabitTemplatePack(
    title: 'Morning Routine',
    emoji: '🌅',
    description: 'Start every day with intention and energy',
    color: const Color(0xFFFFD700),
    habits: [
      HabitTemplate(
          name: 'Wake up early',
          category: HabitCategory.health,
          emoji: '⏰',
          description: 'Rise before 7am'),
      HabitTemplate(
          name: 'Drink water',
          category: HabitCategory.health,
          emoji: '💧',
          description: 'Start with a glass of water'),
      HabitTemplate(
          name: 'Morning stretch',
          category: HabitCategory.fitness,
          emoji: '🤸',
          description: '10 minutes of stretching'),
      HabitTemplate(
          name: 'Meditation',
          category: HabitCategory.mindfulness,
          emoji: '🧘',
          description: '5 minutes of mindfulness'),
      HabitTemplate(
          name: 'Journal',
          category: HabitCategory.personal,
          emoji: '📓',
          description: 'Write 3 things you\'re grateful for'),
    ],
  ),
  HabitTemplatePack(
    title: 'Fitness & Health',
    emoji: '💪',
    description: 'Build a stronger, healthier body',
    color: const Color(0xFFFFB6C1),
    habits: [
      HabitTemplate(
          name: 'Exercise',
          category: HabitCategory.fitness,
          emoji: '🏋️',
          description: '30 minutes of workout'),
      HabitTemplate(
          name: 'Drink 8 glasses of water',
          category: HabitCategory.health,
          emoji: '💧',
          description: 'Stay hydrated all day'),
      HabitTemplate(
          name: 'Eat vegetables',
          category: HabitCategory.health,
          emoji: '🥗',
          description: 'Include veggies in every meal'),
      HabitTemplate(
          name: 'Sleep 8 hours',
          category: HabitCategory.health,
          emoji: '🛏️',
          description: 'Get quality sleep'),
      HabitTemplate(
          name: 'No junk food',
          category: HabitCategory.health,
          emoji: '🚫',
          description: 'Avoid processed food'),
      HabitTemplate(
          name: 'Walk 10k steps',
          category: HabitCategory.fitness,
          emoji: '🚶',
          description: 'Stay active throughout the day'),
    ],
  ),
  HabitTemplatePack(
    title: 'Study & Learning',
    emoji: '📚',
    description: 'Grow your mind every single day',
    color: const Color(0xFFE6E6FA),
    habits: [
      HabitTemplate(
          name: 'Read 20 pages',
          category: HabitCategory.learning,
          emoji: '📖',
          description: 'Read a book daily'),
      HabitTemplate(
          name: 'Study session',
          category: HabitCategory.learning,
          emoji: '📝',
          description: '1 hour of focused study'),
      HabitTemplate(
          name: 'Learn new word',
          category: HabitCategory.learning,
          emoji: '🔤',
          description: 'Expand your vocabulary'),
      HabitTemplate(
          name: 'Watch educational video',
          category: HabitCategory.learning,
          emoji: '🎥',
          description: '15 minutes of learning content'),
      HabitTemplate(
          name: 'Practice flashcards',
          category: HabitCategory.learning,
          emoji: '🃏',
          description: 'Review what you\'ve learned'),
    ],
  ),
  HabitTemplatePack(
    title: 'Work & Productivity',
    emoji: '💼',
    description: 'Get more done with less stress',
    color: const Color(0xFFB0C4DE),
    habits: [
      HabitTemplate(
          name: 'Plan the day',
          category: HabitCategory.work,
          emoji: '📋',
          description: 'Write your top 3 priorities'),
      HabitTemplate(
          name: 'Deep work block',
          category: HabitCategory.work,
          emoji: '🎯',
          description: '2 hours of focused work'),
      HabitTemplate(
          name: 'Clear inbox',
          category: HabitCategory.work,
          emoji: '📧',
          description: 'Reach inbox zero'),
      HabitTemplate(
          name: 'No phone in meetings',
          category: HabitCategory.work,
          emoji: '📵',
          description: 'Be fully present'),
      HabitTemplate(
          name: 'End-of-day review',
          category: HabitCategory.work,
          emoji: '✅',
          description: 'Reflect on what you accomplished'),
    ],
  ),
  HabitTemplatePack(
    title: 'Mindfulness & Mental Health',
    emoji: '🧘',
    description: 'Nurture your inner peace daily',
    color: const Color(0xFFAFEEEE),
    habits: [
      HabitTemplate(
          name: 'Meditate',
          category: HabitCategory.mindfulness,
          emoji: '🧘',
          description: '10 minutes of meditation'),
      HabitTemplate(
          name: 'Gratitude journal',
          category: HabitCategory.mindfulness,
          emoji: '🙏',
          description: 'Write 3 things you\'re grateful for'),
      HabitTemplate(
          name: 'Digital detox hour',
          category: HabitCategory.mindfulness,
          emoji: '📵',
          description: '1 hour without screens'),
      HabitTemplate(
          name: 'Deep breathing',
          category: HabitCategory.mindfulness,
          emoji: '🌬️',
          description: '5 minutes of breathing exercises'),
      HabitTemplate(
          name: 'Nature walk',
          category: HabitCategory.mindfulness,
          emoji: '🌿',
          description: 'Spend time outdoors'),
    ],
  ),
  HabitTemplatePack(
    title: 'Finance & Saving',
    emoji: '💰',
    description: 'Build wealth one habit at a time',
    color: const Color(0xFFFFD700),
    habits: [
      HabitTemplate(
          name: 'Track expenses',
          category: HabitCategory.finance,
          emoji: '💸',
          description: 'Log every purchase'),
      HabitTemplate(
          name: 'No impulse buying',
          category: HabitCategory.finance,
          emoji: '🛑',
          description: 'Think before you spend'),
      HabitTemplate(
          name: 'Save daily',
          category: HabitCategory.finance,
          emoji: '🏦',
          description: 'Put aside a small amount'),
      HabitTemplate(
          name: 'Review budget',
          category: HabitCategory.finance,
          emoji: '📊',
          description: 'Check your weekly spending'),
      HabitTemplate(
          name: 'Cook at home',
          category: HabitCategory.finance,
          emoji: '🍳',
          description: 'Avoid eating out'),
    ],
  ),
  HabitTemplatePack(
    title: 'Social & Relationships',
    emoji: '🤝',
    description: 'Strengthen your connections with others',
    color: const Color(0xFFFFDAB9),
    habits: [
      HabitTemplate(
          name: 'Call a friend',
          category: HabitCategory.social,
          emoji: '📞',
          description: 'Reach out to someone you care about'),
      HabitTemplate(
          name: 'Acts of kindness',
          category: HabitCategory.social,
          emoji: '💝',
          description: 'Do something nice for someone'),
      HabitTemplate(
          name: 'Family time',
          category: HabitCategory.social,
          emoji: '👨‍👩‍👧',
          description: 'Spend quality time with family'),
      HabitTemplate(
          name: 'No gossip',
          category: HabitCategory.social,
          emoji: '🤐',
          description: 'Speak kindly about others'),
    ],
  ),
];

// ─────────────────────────────────────────────
// Templates Page UI
// ─────────────────────────────────────────────
class HabitTemplatesPage extends StatefulWidget {
  const HabitTemplatesPage({super.key});

  @override
  State<HabitTemplatesPage> createState() => _HabitTemplatesPageState();
}

class _HabitTemplatesPageState extends State<HabitTemplatesPage> {
  final Set<String> _selectedHabits = {};

  void _toggleHabit(String habitKey) {
    setState(() {
      if (_selectedHabits.contains(habitKey)) {
        _selectedHabits.remove(habitKey);
      } else {
        _selectedHabits.add(habitKey);
      }
    });
  }

  void _addSelectedHabits() {
    final List<HabitTemplate> toAdd = [];

    for (final pack in habitTemplatePacks) {
      for (final habit in pack.habits) {
        final key = '${pack.title}::${habit.name}';
        if (_selectedHabits.contains(key)) {
          toAdd.add(habit);
        }
      }
    }

    Navigator.pop(context, toAdd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Habit Templates',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          if (_selectedHabits.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: _addSelectedHabits,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9370DB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Add ${_selectedHabits.length}'),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE6E6FA), Color(0xFFFFFACD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Text('✨', style: TextStyle(fontSize: 28)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick your habits',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Select any habits to add them instantly',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Packs
          ...habitTemplatePacks.map((pack) => _buildPackCard(pack)),
        ],
      ),
    );
  }

  Widget _buildPackCard(HabitTemplatePack pack) {
    final selectedCount = pack.habits
        .where((h) => _selectedHabits.contains('${pack.title}::${h.name}'))
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pack header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pack.color.withOpacity(0.3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(pack.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        pack.description,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                if (selectedCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9370DB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$selectedCount selected',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),

          // Habit list
          ...pack.habits.map((habit) {
            final key = '${pack.title}::${habit.name}';
            final isSelected = _selectedHabits.contains(key);

            return InkWell(
              onTap: () => _toggleHabit(key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? pack.color.withOpacity(0.15)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(habit.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            habit.description,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF9370DB)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF9370DB)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

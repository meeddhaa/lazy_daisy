// lib/pages/challenges_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_tracker/database/habit_database.dart';
import 'package:mini_habit_tracker/models/challenge.dart';
import 'package:mini_habit_tracker/util/challenge_util.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          'Challenges 🏆',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF9370DB),
          unselectedLabelColor: Colors.black45,
          indicatorColor: const Color(0xFF9370DB),
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: Consumer<HabitDatabase>(
        builder: (context, db, _) {
          final allProgress = ChallengeUtil.calculateAll(db.currentHabits);
          final weekly = allProgress
              .where((p) => p.definition.period == ChallengePeriod.weekly)
              .toList();
          final monthly = allProgress
              .where((p) => p.definition.period == ChallengePeriod.monthly)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildChallengeList(weekly, db.currentHabits.isEmpty),
              _buildChallengeList(monthly, db.currentHabits.isEmpty),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChallengeList(
      List<ChallengeProgress> progresses, bool noHabits) {
    if (noHabits) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              'Add some habits first\nto start challenges!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black45),
            ),
          ],
        ),
      );
    }

    final completed = progresses.where((p) => p.isCompleted).toList();
    final inProgress = progresses.where((p) => !p.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (completed.isNotEmpty) ...[
          _sectionHeader('✅ Completed', Colors.green),
          ...completed.map((p) => _ChallengeCard(progress: p)),
          const SizedBox(height: 8),
        ],
        _sectionHeader('🔥 In Progress', const Color(0xFF9370DB)),
        ...inProgress.map((p) => _ChallengeCard(progress: p)),
      ],
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// ─── Challenge Card ──────────────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  final ChallengeProgress progress;

  const _ChallengeCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final def = progress.definition;
    final isCompleted = progress.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(color: Colors.green.withOpacity(0.4), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: def.color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: def.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(def.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              def.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Done ✅',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        def.description,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.percent,
                minHeight: 8,
                backgroundColor: def.color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : def.color),
              ),
            ),
            const SizedBox(height: 8),

            // Progress text + XP reward
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.current} / ${progress.target}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green : Colors.black54,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9370DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${def.xpReward} XP',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9370DB),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
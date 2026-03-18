// lib/models/challenge.dart
import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/models/habit.dart';

enum ChallengePeriod { weekly, monthly }

enum ChallengeType {
  completionStreak,   // Complete any habit X days in a row
  totalCompletions,   // Complete habits X times total
  allHabitsDay,       // Complete ALL habits on a single day
  categoryFocus,      // Complete habits of a specific category X times
}

class ChallengeDefinition {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final ChallengePeriod period;
  final ChallengeType type;
  final int target;
  final int xpReward;
  final Color color;
  final HabitCategory? categoryFilter;

  const ChallengeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.period,
    required this.type,
    required this.target,
    required this.xpReward,
    required this.color,
    this.categoryFilter,
  });
}

// ─── All Available Challenges ───────────────────────────────────────────────

final List<ChallengeDefinition> allChallenges = [
  // WEEKLY
  const ChallengeDefinition(
    id: 'weekly_streak_5',
    title: '5-Day Warrior',
    description: 'Complete at least one habit every day for 5 days this week',
    emoji: '⚔️',
    period: ChallengePeriod.weekly,
    type: ChallengeType.completionStreak,
    target: 5,
    xpReward: 150,
    color: Color(0xFF9370DB),
  ),
  const ChallengeDefinition(
    id: 'weekly_total_20',
    title: 'Habit Machine',
    description: 'Complete 20 habit check-ins this week',
    emoji: '⚙️',
    period: ChallengePeriod.weekly,
    type: ChallengeType.totalCompletions,
    target: 20,
    xpReward: 200,
    color: Color(0xFF4CAF50),
  ),
  const ChallengeDefinition(
    id: 'weekly_allday_3',
    title: 'Perfect Day x3',
    description: 'Complete ALL your habits on 3 different days this week',
    emoji: '🌟',
    period: ChallengePeriod.weekly,
    type: ChallengeType.allHabitsDay,
    target: 3,
    xpReward: 250,
    color: Color(0xFFFFB300),
  ),
  const ChallengeDefinition(
    id: 'weekly_health_7',
    title: 'Health Week',
    description: 'Complete health habits 7 times this week',
    emoji: '💪',
    period: ChallengePeriod.weekly,
    type: ChallengeType.categoryFocus,
    target: 7,
    xpReward: 175,
    color: Color(0xFFFFB6C1),
    categoryFilter: HabitCategory.health,
  ),
  const ChallengeDefinition(
    id: 'weekly_mindfulness_5',
    title: 'Mindful Week',
    description: 'Complete mindfulness habits 5 times this week',
    emoji: '🧘',
    period: ChallengePeriod.weekly,
    type: ChallengeType.categoryFocus,
    target: 5,
    xpReward: 150,
    color: Color(0xFFAFEEEE),
    categoryFilter: HabitCategory.mindfulness,
  ),

  // MONTHLY
  const ChallengeDefinition(
    id: 'monthly_streak_21',
    title: '21-Day Legend',
    description: 'Complete at least one habit every day for 21 days this month',
    emoji: '👑',
    period: ChallengePeriod.monthly,
    type: ChallengeType.completionStreak,
    target: 21,
    xpReward: 500,
    color: Color(0xFFFFD700),
  ),
  const ChallengeDefinition(
    id: 'monthly_total_100',
    title: 'Century Club',
    description: 'Complete 100 habit check-ins this month',
    emoji: '💯',
    period: ChallengePeriod.monthly,
    type: ChallengeType.totalCompletions,
    target: 100,
    xpReward: 600,
    color: Color(0xFF2196F3),
  ),
  const ChallengeDefinition(
    id: 'monthly_allday_10',
    title: 'Perfect 10',
    description: 'Complete ALL your habits on 10 different days this month',
    emoji: '🔟',
    period: ChallengePeriod.monthly,
    type: ChallengeType.allHabitsDay,
    target: 10,
    xpReward: 700,
    color: Color(0xFFFF5722),
  ),
  const ChallengeDefinition(
    id: 'monthly_learning_20',
    title: 'Scholar',
    description: 'Complete learning habits 20 times this month',
    emoji: '📚',
    period: ChallengePeriod.monthly,
    type: ChallengeType.categoryFocus,
    target: 20,
    xpReward: 450,
    color: Color(0xFFE6E6FA),
    categoryFilter: HabitCategory.learning,
  ),
  const ChallengeDefinition(
    id: 'monthly_fitness_15',
    title: 'Fitness Freak',
    description: 'Complete fitness habits 15 times this month',
    emoji: '🏃',
    period: ChallengePeriod.monthly,
    type: ChallengeType.categoryFocus,
    target: 15,
    xpReward: 400,
    color: Color(0xFFFFA07A),
    categoryFilter: HabitCategory.fitness,
  ),
];
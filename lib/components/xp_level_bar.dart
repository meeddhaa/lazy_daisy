import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/models/habit.dart';

class XPLevelBar extends StatelessWidget {
  final List<Habit> habits;

  const XPLevelBar({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final totalXP = habits.fold<int>(0, (sum, h) => sum + h.getTotalXP());
    final level = XPSystem.getLevel(totalXP);
    final xpInLevel = XPSystem.getXPInCurrentLevel(totalXP);
    final xpNeeded = XPSystem.getXPForNextLevel(totalXP);
    final progress = xpNeeded > 0 ? xpInLevel / xpNeeded : 0.0;
    final title = XPSystem.getLevelTitle(level);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6E6FA), Color(0xFFFFFACD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level $level — $title',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '$totalXP XP total',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF9370DB).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$xpInLevel / $xpNeeded XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9370DB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // XP Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF9370DB),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${xpNeeded - xpInLevel} XP to Level ${level + 1}',
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
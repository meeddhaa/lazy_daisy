import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/models/habit.dart';

class DifficultyPicker extends StatelessWidget {
  final HabitDifficulty selected;
  final ValueChanged<HabitDifficulty> onSelected;

  const DifficultyPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: HabitDifficulty.values.map((difficulty) {
            final isSelected = difficulty == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(difficulty),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? difficulty.color.withOpacity(0.2)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? difficulty.color
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(difficulty.emoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(
                        difficulty.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? difficulty.color
                              : Colors.black54,
                        ),
                      ),
                      Text(
                        '+${difficulty.xp} XP',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? difficulty.color
                              : Colors.black38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
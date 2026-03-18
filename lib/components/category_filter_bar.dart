import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/models/habit.dart';

class CategoryFilterBar extends StatelessWidget {
  final HabitCategory? selectedCategory; // null = show all
  final ValueChanged<HabitCategory?> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip
          _buildChip(
            label: 'All',
            emoji: '✨',
            isSelected: selectedCategory == null,
            color: const Color(0xFFE6E6FA),
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: 8),
          ...HabitCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: category.label,
                emoji: category.emoji,
                isSelected: selectedCategory == category,
                color: category.color,
                onTap: () => onCategorySelected(
                  selectedCategory == category ? null : category,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
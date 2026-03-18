import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/models/habit.dart';

class CategoryPicker extends StatelessWidget {
  final HabitCategory selected;
  final ValueChanged<HabitCategory> onSelected;

  const CategoryPicker({
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
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HabitCategory.values.map((category) {
            final isSelected = category == selected;
            return GestureDetector(
              onTap: () => onSelected(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? category.color
                      : category.color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: category.color.withOpacity(0.8), width: 2)
                      : Border.all(color: Colors.transparent),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: category.color.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      category.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.black87 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
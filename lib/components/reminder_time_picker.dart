import 'package:flutter/material.dart';

class ReminderTimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onTimeSelected;

  const ReminderTimePicker({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9370DB),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Reminder',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Time picker button
            Expanded(
              child: GestureDetector(
                onTap: () => _pickTime(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selectedTime != null
                        ? const Color(0xFFE6E6FA)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedTime != null
                          ? const Color(0xFF9370DB).withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.alarm,
                        size: 20,
                        color: selectedTime != null
                            ? const Color(0xFF9370DB)
                            : Colors.black38,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : 'Set reminder time',
                        style: TextStyle(
                          fontSize: 15,
                          color: selectedTime != null
                              ? const Color(0xFF9370DB)
                              : Colors.black38,
                          fontWeight: selectedTime != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Clear button (only shown if time is set)
            if (selectedTime != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onTimeSelected(null),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.alarm_off,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (selectedTime != null) ...[
          const SizedBox(height: 6),
          Text(
            '🔔 You\'ll be reminded daily at ${selectedTime!.format(context)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
            ),
          ),
        ],
      ],
    );
  }
}
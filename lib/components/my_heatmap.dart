import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class MyHeatMap extends StatelessWidget {
  final Map<DateTime, int> datasets;
  final DateTime startDate;

  const MyHeatMap({super.key, required this.startDate, required this.datasets});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: HeatMap(
        startDate: startDate,
        endDate: DateTime.now(),
        datasets: datasets,
        colorMode: ColorMode.color,
        defaultColor: const Color(0xFFF5F5F5),
        textColor: Colors.black54,
        showColorTip: false,
        showText: true,
        scrollable: true,
        size: 30,
        colorsets: {
          1: const Color(0xFFFFFACD).withOpacity(0.3), // Light yellow
          2: const Color(0xFFFFFACD).withOpacity(0.5),
          3: const Color(0xFFFFFACD).withOpacity(0.7),
          4: const Color(0xFFE6E6FA).withOpacity(0.7), // Lavender
          5: const Color(0xFFE6E6FA), // Full lavender
        },
      ),
    );
  }
}

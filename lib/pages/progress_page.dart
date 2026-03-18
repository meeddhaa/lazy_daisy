import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/database/habit_database.dart';
import 'package:mini_habit_tracker/services/mood_habit_service.dart';
import 'package:provider/provider.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  int _selectedPeriod = 0; // 0 = week, 1 = month

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Real data helpers (unchanged from your original) ─────────────────────

  List<double> _getWeeklyData(List habits) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final normalized = DateTime(day.year, day.month, day.day);
      int count = 0;
      for (final habit in habits) {
        for (final ms in habit.completedDays) {
          final d = DateTime.fromMillisecondsSinceEpoch(ms);
          if (DateTime(d.year, d.month, d.day) == normalized) {
            count++;
            break;
          }
        }
      }
      return count.toDouble();
    });
  }

  List<double> _getMonthlyData(List habits) {
    final now = DateTime.now();
    return List.generate(4, (week) {
      final weekStart = now.subtract(
          Duration(days: now.weekday - 1 + (3 - week) * 7));
      int total = 0;
      for (int d = 0; d < 7; d++) {
        final day = weekStart.add(Duration(days: d));
        final normalized = DateTime(day.year, day.month, day.day);
        for (final habit in habits) {
          for (final ms in habit.completedDays) {
            final date = DateTime.fromMillisecondsSinceEpoch(ms);
            if (DateTime(date.year, date.month, date.day) ==
                normalized) {
              total++;
              break;
            }
          }
        }
      }
      return total.toDouble();
    });
  }

  int _getLongestStreak(List habits) {
    if (habits.isEmpty) return 0;
    int max = 0;
    for (final habit in habits) {
      final days = (habit.completedDays as List)
          .map((ms) {
            final d = DateTime.fromMillisecondsSinceEpoch(ms as int);
            return DateTime(d.year, d.month, d.day);
          })
          .toSet()
          .toList()
        ..sort();
      if (days.isEmpty) continue;
      int streak = 1, current = 1;
      for (int i = 1; i < days.length; i++) {
        if (days[i].difference(days[i - 1]).inDays == 1) {
          current++;
          if (current > streak) streak = current;
        } else {
          current = 1;
        }
      }
      if (streak > max) max = streak;
    }
    return max;
  }

  int _getActiveDaysThisMonth(List habits) {
    final now = DateTime.now();
    final Set<int> activeDays = {};
    for (final habit in habits) {
      for (final ms in habit.completedDays) {
        final d = DateTime.fromMillisecondsSinceEpoch(ms as int);
        if (d.year == now.year && d.month == now.month) {
          activeDays.add(d.day);
        }
      }
    }
    return activeDays.length;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Consumer2 so we get both habit data AND mood data
    return Consumer2<HabitDatabase, MoodHabitService>(
      builder: (context, db, moodSvc, _) {
        final habits = db.currentHabits;
        final total = habits.length;
        final now = DateTime.now();

        final completedToday = habits.where((h) {
          return h.completedDays.any((ms) {
            final d = DateTime.fromMillisecondsSinceEpoch(ms);
            return d.year == now.year &&
                d.month == now.month &&
                d.day == now.day;
          });
        }).length;

        final rate =
            total > 0 ? (completedToday / total * 100).round() : 0;
        final longestStreak = _getLongestStreak(habits);
        final activeDays = _getActiveDaysThisMonth(habits);
        final weekData = _getWeeklyData(habits);
        final monthData = _getMonthlyData(habits);
        final chartData =
            _selectedPeriod == 0 ? weekData : monthData;
        final maxY = (chartData.reduce((a, b) => a > b ? a : b) + 2)
            .clamp(5.0, 999.0);

        // Mood intelligence data
        final hasMoodData = moodSvc.entries.isNotEmpty;
        final moodRates = moodSvc.completionRateByMood;
        final bestMood = moodSvc.bestMoodForHabits;
        final insight = moodSvc.correlationInsight;
        final todayMood = moodSvc.todaysMood;
        final moodFreq = moodSvc.moodFrequency;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A14),
          body: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Header ─────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 20,
                        left: 24,
                        right: 24,
                        bottom: 16,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1A0A2E),
                            Color(0xFF0A0A14)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Text('Analytics',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -1)),
                            const Spacer(),
                            // Today's mood badge (shows when logged)
                            if (todayMood != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color(todayMood.colorValue)
                                      .withOpacity(0.18),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Color(todayMood.colorValue)
                                          .withOpacity(0.4)),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(todayMood.emoji,
                                          style: const TextStyle(
                                              fontSize: 13)),
                                      const SizedBox(width: 5),
                                      Text(todayMood.name,
                                          style: TextStyle(
                                              color: Color(
                                                  todayMood.colorValue),
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w700)),
                                    ]),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C6FF7)
                                      .withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFF7C6FF7)
                                          .withOpacity(0.4)),
                                ),
                                child: Text('$rate% today',
                                    style: const TextStyle(
                                        color: Color(0xFF7C6FF7),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              ),
                          ]),
                          const SizedBox(height: 4),
                          Text('Your habit journey at a glance',
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Colors.white.withOpacity(0.4))),
                        ],
                      ),
                    ),
                  ),

                  // ── Stat cards ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(children: [
                        _StatCard(
                            value: total.toString(),
                            label: 'Habits',
                            icon:
                                Icons.check_circle_outline_rounded,
                            color: const Color(0xFF7C6FF7)),
                        const SizedBox(width: 12),
                        _StatCard(
                            value: '$completedToday',
                            label: 'Done Today',
                            icon: Icons.today_rounded,
                            color: const Color(0xFF4FC3A1)),
                        const SizedBox(width: 12),
                        _StatCard(
                            value: '${longestStreak}d',
                            label: 'Best Streak',
                            icon: Icons
                                .local_fire_department_rounded,
                            color: const Color(0xFFFF7BAC)),
                        const SizedBox(width: 12),
                        _StatCard(
                            value: '$activeDays',
                            label: 'Active Days',
                            icon: Icons.calendar_month_rounded,
                            color: const Color(0xFFFFB347)),
                      ]),
                    ),
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: 28)),

                  // ── Bar chart ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Text('Completions',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.3)),
                            const Spacer(),
                            _PeriodToggle(
                                selected: _selectedPeriod,
                                onChanged: (v) => setState(
                                    () => _selectedPeriod = v)),
                          ]),
                          const SizedBox(height: 20),
                          Container(
                            height: 220,
                            padding: const EdgeInsets.fromLTRB(
                                16, 20, 16, 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12101E),
                              borderRadius:
                                  BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white
                                      .withOpacity(0.06)),
                            ),
                            child: BarChart(
                              BarChartData(
                                maxY: maxY,
                                barTouchData: BarTouchData(
                                  touchTooltipData:
                                      BarTouchTooltipData(
                                    tooltipBgColor:
                                        const Color(0xFF1E1B2E),
                                    tooltipRoundedRadius: 10,
                                    getTooltipItem: (group, _, rod,
                                            __) =>
                                        BarTooltipItem(
                                      '${rod.toY.toInt()}',
                                      const TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.bold),
                                    ),
                                  ),
                                ),
                                borderData:
                                    FlBorderData(show: false),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: maxY / 4,
                                  getDrawingHorizontalLine: (_) =>
                                      FlLine(
                                    color: Colors.white
                                        .withOpacity(0.05),
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, _) {
                                        final labels =
                                            _selectedPeriod == 0
                                                ? [
                                                    'M',
                                                    'T',
                                                    'W',
                                                    'T',
                                                    'F',
                                                    'S',
                                                    'S'
                                                  ]
                                                : [
                                                    'W1',
                                                    'W2',
                                                    'W3',
                                                    'W4'
                                                  ];
                                        final i = value.toInt();
                                        if (i < 0 ||
                                            i >= labels.length)
                                          return const SizedBox();
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(
                                                  top: 8),
                                          child: Text(labels[i],
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(
                                                          0.4),
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600)),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      interval: maxY / 4,
                                      getTitlesWidget: (value, _) =>
                                          Text(
                                              value.toInt().toString(),
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(
                                                          0.3),
                                                  fontSize: 11)),
                                    ),
                                  ),
                                ),
                                barGroups: List.generate(
                                    chartData.length, (i) {
                                  final isHighest = chartData[i] ==
                                      chartData.reduce(
                                          (a, b) => a > b ? a : b);
                                  return BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: chartData[i] == 0
                                            ? 0.3
                                            : chartData[i],
                                        gradient: LinearGradient(
                                          colors: isHighest
                                              ? [
                                                  const Color(
                                                      0xFF7C6FF7),
                                                  const Color(
                                                      0xFFFF7BAC)
                                                ]
                                              : [
                                                  const Color(
                                                          0xFF7C6FF7)
                                                      .withOpacity(
                                                          0.6),
                                                  const Color(
                                                          0xFF7C6FF7)
                                                      .withOpacity(
                                                          0.3),
                                                ],
                                          begin:
                                              Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        width:
                                            _selectedPeriod == 0
                                                ? 28
                                                : 40,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top:
                                                    Radius.circular(8)),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: 28)),

                  // ── Today's ring ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Today's Progress",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12101E),
                              borderRadius:
                                  BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white
                                      .withOpacity(0.06)),
                            ),
                            child: Row(children: [
                              // Ring
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      PieChart(PieChartData(
                                        sectionsSpace: 3,
                                        centerSpaceRadius: 34,
                                        sections: [
                                          PieChartSectionData(
                                            value: rate
                                                .toDouble()
                                                .clamp(1, 100),
                                            color: todayMood != null
                                                ? Color(todayMood
                                                    .colorValue)
                                                : const Color(
                                                    0xFF7C6FF7),
                                            radius: 16,
                                            showTitle: false,
                                          ),
                                          PieChartSectionData(
                                            value: (100 - rate)
                                                .toDouble()
                                                .clamp(0, 99),
                                            color: Colors.white
                                                .withOpacity(0.06),
                                            radius: 14,
                                            showTitle: false,
                                          ),
                                        ],
                                      )),
                                      Column(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          children: [
                                            Text('$rate%',
                                                style: const TextStyle(
                                                    color:
                                                        Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight
                                                            .w800)),
                                            if (todayMood != null)
                                              Text(
                                                  todayMood.emoji,
                                                  style:
                                                      const TextStyle(
                                                          fontSize:
                                                              12)),
                                          ]),
                                    ]),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _RingLegend(
                                          color: todayMood != null
                                              ? Color(todayMood
                                                  .colorValue)
                                              : const Color(
                                                  0xFF7C6FF7),
                                          label: 'Completed',
                                          value:
                                              '$completedToday of $total'),
                                      const SizedBox(height: 10),
                                      _RingLegend(
                                          color: Colors.white
                                              .withOpacity(0.15),
                                          label: 'Remaining',
                                          value:
                                              '${total - completedToday} left'),
                                      const SizedBox(height: 14),
                                      Text(
                                          rate >= 100
                                              ? '🎉 Perfect day!'
                                              : rate >= 50
                                                  ? '💪 Keep going!'
                                                  : '🌱 Just starting!',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w700)),
                                    ]),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: 28)),

                  // ── Mood Intelligence (unlocks with mood data) ─────────
                  if (hasMoodData)
                    SliverToBoxAdapter(
                      child: _MoodIntelligenceSection(
                        moodSvc: moodSvc,
                        moodRates: moodRates,
                        bestMood: bestMood,
                        insight: insight,
                        moodFreq: moodFreq,
                      ),
                    ),

                  if (hasMoodData)
                    const SliverToBoxAdapter(
                        child: SizedBox(height: 28)),

                  // ── Per-habit breakdown ────────────────────────────────
                  if (habits.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Habit Breakdown',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.3)),
                            const SizedBox(height: 16),
                            ...habits.asMap().entries.map((entry) {
                              final i = entry.key;
                              final habit = entry.value;
                              final total30 =
                                  habit.completedDays.where((ms) {
                                final d =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        ms);
                                return now.difference(d).inDays <=
                                    30;
                              }).length;
                              final pct =
                                  (total30 / 30).clamp(0.0, 1.0);
                              const colors = [
                                Color(0xFF7C6FF7),
                                Color(0xFFFF7BAC),
                                Color(0xFF4FC3A1),
                                Color(0xFFFFB347),
                                Color(0xFF64B5F6),
                              ];
                              final color =
                                  colors[i % colors.length];
                              return Container(
                                margin: const EdgeInsets.only(
                                    bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF12101E),
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  border: Border.all(
                                      color: color.withOpacity(0.2)),
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Expanded(
                                            child: Text(habit.name,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight
                                                            .w600))),
                                        Text('$total30/30 days',
                                            style: TextStyle(
                                                color: color,
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w700)),
                                      ]),
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: pct,
                                          backgroundColor:
                                              Colors.white
                                                  .withOpacity(0.06),
                                          valueColor:
                                              AlwaysStoppedAnimation<
                                                  Color>(color),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ]),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Mood Intelligence section ─────────────────────────────────────────────────

class _MoodIntelligenceSection extends StatelessWidget {
  final MoodHabitService moodSvc;
  final Map<String, double> moodRates;
  final String? bestMood;
  final String? insight;
  final Map<String, int> moodFreq;

  const _MoodIntelligenceSection({
    required this.moodSvc,
    required this.moodRates,
    required this.bestMood,
    required this.insight,
    required this.moodFreq,
  });

  @override
  Widget build(BuildContext context) {
    final sortedRates = moodRates.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(children: [
            const Text('Mood Intelligence',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFF7C6FF7),
                    Color(0xFFFF7BAC)
                  ]),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('NEW',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
            ),
          ]),
          const SizedBox(height: 16),

          // Insight banner
          if (insight != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFF7C6FF7).withOpacity(0.15),
                  const Color(0xFF4FC3A1).withOpacity(0.08),
                ]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color:
                        const Color(0xFF7C6FF7).withOpacity(0.3)),
              ),
              child: Row(children: [
                const Text('💡',
                    style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(insight!,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4))),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          // Habit completion rate by mood
          if (sortedRates.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF12101E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('Habit Rate by Mood',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (bestMood != null)
                      Text('👑 $bestMood',
                          style: const TextStyle(
                              color: Color(0xFFFFB347),
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 14),
                  ...sortedRates.take(5).map((e) {
                    final pct = e.value;
                    final isBest = e.key == bestMood;
                    // Find color from mood catalogue
                    const moodColors = <String, int>{
                      'Happy': 0xFF4CAF50,
                      'Calm': 0xFF2196F3,
                      'Loved': 0xFFEC407A,
                      'Excited': 0xFFAB47BC,
                      'Focused': 0xFF26A69A,
                      'Grateful': 0xFFFFB74D,
                      'Sad': 0xFF78909C,
                      'Anxious': 0xFFFF9800,
                      'Frustrated': 0xFFEF5350,
                      'Tired': 0xFF5C6BC0,
                    };
                    final c = Color(
                        moodColors[e.key] ?? 0xFF7C6FF7);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        SizedBox(
                          width: 72,
                          child: Text(e.key,
                              style: TextStyle(
                                  color: isBest
                                      ? c
                                      : Colors.white
                                          .withOpacity(0.55),
                                  fontSize: 12,
                                  fontWeight: isBest
                                      ? FontWeight.w700
                                      : FontWeight.normal)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor:
                                  Colors.white.withOpacity(0.06),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      c),
                              minHeight: isBest ? 8 : 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('${(pct * 100).round()}%',
                            style: TextStyle(
                                color: isBest
                                    ? c
                                    : Colors.white
                                        .withOpacity(0.45),
                                fontSize: 12,
                                fontWeight: isBest
                                    ? FontWeight.w700
                                    : FontWeight.normal)),
                        if (isBest) ...[
                          const SizedBox(width: 4),
                          const Text('👑',
                              style: TextStyle(fontSize: 11)),
                        ],
                      ]),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Mood stats row: streak, entries, dominant
          Row(children: [
            _MoodStatTile(
                emoji: '🔥',
                label: 'Log Streak',
                value: '${moodSvc.logStreak}d',
                color: const Color(0xFFFF9800)),
            const SizedBox(width: 10),
            _MoodStatTile(
                emoji: '📓',
                label: 'Total Logs',
                value: '${moodSvc.entries.length}',
                color: const Color(0xFF7C6FF7)),
            const SizedBox(width: 10),
            _MoodStatTile(
                emoji: '😊',
                label: 'Most Felt',
                value: moodSvc.dominantMood ?? '—',
                color: const Color(0xFF4CAF50),
                small: true),
          ]),
        ],
      ),
    );
  }
}

class _MoodStatTile extends StatelessWidget {
  final String emoji, label, value;
  final Color color;
  final bool small;
  const _MoodStatTile(
      {required this.emoji,
      required this.label,
      required this.value,
      required this.color,
      this.small = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji,
                    style:
                        TextStyle(fontSize: small ? 13 : 16)),
                const SizedBox(height: 5),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: small ? 12 : 19,
                        fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 9,
                        fontWeight: FontWeight.w600)),
              ]),
        ),
      );
}

// ── Shared stat widgets (same as your original) ───────────────────────────────

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 8),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ]),
        ),
      );
}

class _PeriodToggle extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _PeriodToggle(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ['Week', 'Month'].asMap().entries.map((e) {
            final isSelected = selected == e.key;
            return GestureDetector(
              onTap: () => onChanged(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF7C6FF7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(e.value,
                    style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      );
}

class _RingLegend extends StatelessWidget {
  final Color color;
  final String label, value;
  const _RingLegend(
      {required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ]);
}
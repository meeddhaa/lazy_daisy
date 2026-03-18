import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_habit_tracker/database/habit_database.dart';
import 'package:mini_habit_tracker/services/mood_habit_service.dart';
import 'package:provider/provider.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage>
    with TickerProviderStateMixin {
  late AnimationController _pageAnim;
  late AnimationController _pulseAnim;
  late AnimationController _gridAnim;
  late Animation<double> _pageFade;
  late Animation<double> _pulseScale;

  String _selectedFilter = 'All';
  int _tappedIndex = -1;

  static const List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'name': 'Happy',      'color': 0xFF4CAF50, 'sub': 'Joyful & bright'},
    {'emoji': '😌', 'name': 'Calm',       'color': 0xFF2196F3, 'sub': 'Peaceful & still'},
    {'emoji': '🥰', 'name': 'Loved',      'color': 0xFFEC407A, 'sub': 'Warm & connected'},
    {'emoji': '🤩', 'name': 'Excited',    'color': 0xFFAB47BC, 'sub': 'Full of energy'},
    {'emoji': '🤔', 'name': 'Focused',    'color': 0xFF26A69A, 'sub': 'Sharp & present'},
    {'emoji': '🥺', 'name': 'Grateful',   'color': 0xFFFFB74D, 'sub': 'Counting blessings'},
    {'emoji': '😔', 'name': 'Sad',        'color': 0xFF78909C, 'sub': 'Heavy & low'},
    {'emoji': '😰', 'name': 'Anxious',    'color': 0xFFFF9800, 'sub': 'Worried & tense'},
    {'emoji': '😤', 'name': 'Frustrated', 'color': 0xFFEF5350, 'sub': 'Blocked & tense'},
    {'emoji': '😴', 'name': 'Tired',      'color': 0xFF5C6BC0, 'sub': 'Drained & slow'},
  ];

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _pageAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _pulseAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _gridAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pageFade =
        CurvedAnimation(parent: _pageAnim, curve: Curves.easeOut);
    _pulseScale = Tween<double>(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));
    _pageAnim.forward();
    Future.delayed(const Duration(milliseconds: 200),
        () => _gridAnim.forward());
  }

  @override
  void dispose() {
    _pageAnim.dispose();
    _pulseAnim.dispose();
    _gridAnim.dispose();
    super.dispose();
  }

  // ── Mood logger bottom sheet ───────────────────────────────────────────────
  void _openLogger(BuildContext ctx, int moodIndex) {
    final mood = _moods[moodIndex];
    final Color moodColor = Color(mood['color'] as int);
    final noteCtrl = TextEditingController();
    int intensity = 3;

    final habitDb = ctx.read<HabitDatabase>();
    final moodSvc = ctx.read<MoodHabitService>();
    final now = DateTime.now();
    final completedToday = habitDb.currentHabits.where((h) {
      return h.completedDays.any((ms) {
        final d = DateTime.fromMillisecondsSinceEpoch(ms);
        return d.year == now.year &&
            d.month == now.month &&
            d.day == now.day;
      });
    }).toList();

    showGeneralDialog(
      context: ctx,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.82),
      transitionDuration: const Duration(milliseconds: 380),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(builder: (dialogCtx, setS) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(dialogCtx).size.height * 0.9),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0C1C),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32)),
                  border: Border.all(
                      color: moodColor.withOpacity(0.4), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                        color: moodColor.withOpacity(0.12),
                        blurRadius: 40,
                        offset: const Offset(0, -10)),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(dialogCtx).viewInsets.bottom +
                            36,
                    top: 14,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Orb
                      Center(
                        child: Stack(
                            alignment: Alignment.center,
                            children: [
                              for (int r = 0; r < 3; r++)
                                Container(
                                  width: 90.0 + r * 28,
                                  height: 90.0 + r * 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: moodColor.withOpacity(
                                          0.10 - r * 0.025),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(colors: [
                                    moodColor.withOpacity(0.9),
                                    moodColor.withOpacity(0.4),
                                  ]),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            moodColor.withOpacity(0.5),
                                        blurRadius: 32,
                                        spreadRadius: 4)
                                  ],
                                ),
                                child: Center(
                                  child: Text(mood['emoji'],
                                      style: const TextStyle(
                                          fontSize: 46)),
                                ),
                              ),
                            ]),
                      ),
                      const SizedBox(height: 16),
                      Center(
                          child: Text(mood['name'],
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: moodColor,
                                  letterSpacing: -0.8))),
                      Center(
                          child: Text(mood['sub'],
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 13))),
                      Center(
                          child: Text(
                              DateFormat('EEEE, MMMM d')
                                  .format(DateTime.now()),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.2),
                                  fontSize: 12))),
                      const SizedBox(height: 28),

                      // Intensity
                      _Label(text: 'INTENSITY', color: moodColor),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(5, (i) {
                          final filled = i < intensity;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setS(() => intensity = i + 1),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 180),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3),
                                height: filled ? 12 : 7,
                                decoration: BoxDecoration(
                                  gradient: filled
                                      ? LinearGradient(colors: [
                                          moodColor,
                                          moodColor.withOpacity(0.55)
                                        ])
                                      : null,
                                  color: filled
                                      ? null
                                      : Colors.white.withOpacity(0.08),
                                  borderRadius:
                                      BorderRadius.circular(6),
                                  boxShadow: filled
                                      ? [
                                          BoxShadow(
                                              color: moodColor
                                                  .withOpacity(0.4),
                                              blurRadius: 8)
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Barely',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.2),
                                    fontSize: 10)),
                            Text('Intensely',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.2),
                                    fontSize: 10)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Habits
                      _Label(
                          text: 'HABITS DONE TODAY', color: moodColor),
                      const SizedBox(height: 10),
                      completedToday.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white
                                        .withOpacity(0.07)),
                              ),
                              child: Row(children: [
                                const Text('📋',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 10),
                                Text(
                                    'No habits completed yet today',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.35),
                                        fontSize: 13)),
                              ]))
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: completedToday
                                  .map((h) => Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6),
                                        decoration: BoxDecoration(
                                          color: moodColor
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: moodColor
                                                  .withOpacity(0.35)),
                                        ),
                                        child: Row(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          children: [
                                            Icon(
                                                Icons
                                                    .check_circle_rounded,
                                                size: 12,
                                                color: moodColor),
                                            const SizedBox(width: 5),
                                            Text(h.name,
                                                style: TextStyle(
                                                    color: moodColor,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight
                                                            .w600)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                      const SizedBox(height: 24),

                      // Note
                      _Label(text: 'ADD A NOTE', color: moodColor),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: moodColor.withOpacity(0.22)),
                        ),
                        child: TextField(
                          controller: noteCtrl,
                          maxLines: 3,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.5),
                          decoration: InputDecoration(
                            hintText:
                                'Did something happen? Add a note...',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.22),
                                fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Save
                      GestureDetector(
                        onTap: () async {
                          await moodSvc.addEntry(
                            emoji: mood['emoji'],
                            name: mood['name'],
                            colorValue: mood['color'] as int,
                            intensity: intensity,
                            note: noteCtrl.text.trim(),
                            completedHabitNames: completedToday
                                .map((h) => h.name)
                                .toList(),
                            totalHabits:
                                habitDb.currentHabits.length,
                          );
                          if (mounted) Navigator.pop(dialogCtx);
                          setState(() => _tappedIndex = -1);
                        },
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 17),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              moodColor,
                              moodColor.withOpacity(0.7)
                            ]),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                  color: moodColor.withOpacity(0.45),
                                  blurRadius: 22,
                                  offset: const Offset(0, 6))
                            ],
                          ),
                          child: const Center(
                            child: Text('Save Mood',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer2<MoodHabitService, HabitDatabase>(
      builder: (context, moodSvc, habitDb, _) {
        final today = moodSvc.todaysMood;
        final week = moodSvc.last7Days;
        final entries = moodSvc.entries;
        final streak = moodSvc.logStreak;
        final insight = moodSvc.correlationInsight;
        final filtered = _selectedFilter == 'All'
            ? entries
            : entries
                .where((e) => e.name == _selectedFilter)
                .toList();

        return Scaffold(
          backgroundColor: const Color(0xFF08060F),
          body: FadeTransition(
            opacity: _pageFade,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                    child: _buildHeader(context, today, streak)),
                if (insight != null)
                  SliverToBoxAdapter(
                      child: _InsightBanner(text: insight)),
                SliverToBoxAdapter(
                    child: _buildWeekHeatmap(week)),
                SliverToBoxAdapter(
                    child: _buildMoodGrid(context)),
                if (entries.isNotEmpty)
                  SliverToBoxAdapter(
                      child: _buildStatsRow(moodSvc)),
                if (entries.isNotEmpty)
                  SliverToBoxAdapter(
                      child: _buildHistoryHeader()),
                entries.isEmpty
                    ? SliverToBoxAdapter(child: _EmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _EntryCard(
                            entry: filtered[i],
                            onDelete: () => moodSvc
                                .deleteEntry(filtered[i].id),
                          ),
                          childCount: filtered.length,
                        ),
                      ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Builders ──────────────────────────────────────────────────────────────

  Widget _buildHeader(
      BuildContext ctx, MoodEntry? today, int streak) {
    final Color accent = today != null
        ? Color(today.colorValue)
        : const Color(0xFF7C6FF7);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(ctx).padding.top + 22,
        left: 22,
        right: 22,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D0B1A),
            Color.lerp(const Color(0xFF0D0B1A), accent, 0.06)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mood Journal',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.1)),
                  const SizedBox(height: 3),
                  Text(
                      DateFormat('EEEE, MMMM d')
                          .format(DateTime.now()),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 13)),
                ],
              ),
            ),
            if (streak > 1)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFFF9800)
                          .withOpacity(0.35)),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥',
                          style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text('$streak day streak',
                          style: const TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.w700,
                              fontSize: 11)),
                    ]),
              ),
          ]),
          const SizedBox(height: 18),

          // Today card
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: today == null ? _pulseScale.value : 1.0,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: today != null
                      ? [
                          accent.withOpacity(0.22),
                          accent.withOpacity(0.07),
                        ]
                      : [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: today != null
                      ? accent.withOpacity(0.35)
                      : Colors.white.withOpacity(0.08),
                  width: 1.4,
                ),
              ),
              child:
                  today != null ? _TodayFilled(entry: today) : _TodayEmpty(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeatmap(List<MoodEntry?> week) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionLabel(label: 'THIS WEEK'),
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF11101D),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final entry = week[i];
              final day = now.subtract(Duration(days: 6 - i));
              final isToday = i == 6;
              final dayLabel = _dayLabels[day.weekday - 1];
              final Color dotColor = entry != null
                  ? Color(entry.colorValue)
                  : Colors.transparent;

              return Column(children: [
                AnimatedContainer(
                  duration:
                      Duration(milliseconds: 180 + i * 30),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: entry != null
                        ? Color(entry.colorValue).withOpacity(0.18)
                        : Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isToday
                          ? const Color(0xFF7C6FF7)
                          : entry != null
                              ? Color(entry.colorValue)
                                  .withOpacity(0.45)
                              : Colors.white.withOpacity(0.07),
                      width: isToday ? 2 : 1,
                    ),
                    boxShadow: entry != null
                        ? [
                            BoxShadow(
                                color: Color(entry.colorValue)
                                    .withOpacity(0.28),
                                blurRadius: 10)
                          ]
                        : null,
                  ),
                  child: Center(
                    child: entry != null
                        ? Text(entry.emoji,
                            style: const TextStyle(fontSize: 19))
                        : Text('·',
                            style: TextStyle(
                                color:
                                    Colors.white.withOpacity(0.18),
                                fontSize: 22,
                                fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 5),
                Text(dayLabel,
                    style: TextStyle(
                        color: isToday
                            ? const Color(0xFF7C6FF7)
                            : Colors.white.withOpacity(0.3),
                        fontSize: 11,
                        fontWeight: isToday
                            ? FontWeight.w700
                            : FontWeight.normal)),
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry != null && entry.completionRate > 0
                        ? dotColor.withOpacity(
                            0.4 + entry.completionRate * 0.6)
                        : Colors.transparent,
                  ),
                ),
              ]);
            }),
          ),
        ),
      ]),
    );
  }

  Widget _buildMoodGrid(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionLabel(label: 'HOW ARE YOU FEELING?'),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: _moods.length,
          itemBuilder: (_, i) {
            final mood = _moods[i];
            final Color c = Color(mood['color'] as int);
            final bool tapped = _tappedIndex == i;
            return GestureDetector(
              onTap: () {
                setState(() => _tappedIndex = i);
                _openLogger(ctx, i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: tapped
                      ? c.withOpacity(0.22)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: tapped
                        ? c
                        : Colors.white.withOpacity(0.07),
                    width: tapped ? 1.5 : 1,
                  ),
                  boxShadow: tapped
                      ? [
                          BoxShadow(
                              color: c.withOpacity(0.35),
                              blurRadius: 14)
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: tapped ? 1.18 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(mood['emoji'],
                          style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(height: 4),
                    Text(mood['name'],
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: tapped
                                ? c
                                : Colors.white.withOpacity(0.4)),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  /// ── FIXED: Stats row now uses Column layout to prevent overflow ───────────
  Widget _buildStatsRow(MoodHabitService svc) {
    final best = svc.bestMoodForHabits;
    final avg = svc.avgIntensityLast(30);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: 'Entries',
              value: '${svc.entries.length}',
              icon: '📓',
              color: const Color(0xFF7C6FF7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStat(
              label: 'Avg Intensity',
              value: avg.toStringAsFixed(1),
              icon: '⚡',
              color: const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStat(
              label: 'Best for Habits',
              value: best ?? '—',
              icon: '🏆',
              color: const Color(0xFF4CAF50),
              compact: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'HISTORY'),
          const SizedBox(height: 10),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'All',
                    onTap: () =>
                        setState(() => _selectedFilter = 'All')),
                ..._moods.map((m) => _FilterChip(
                      label: m['emoji'],
                      isSelected: _selectedFilter == m['name'],
                      color: Color(m['color'] as int),
                      onTap: () => setState(() =>
                          _selectedFilter =
                              _selectedFilter == m['name']
                                  ? 'All'
                                  : m['name']),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: color.withOpacity(0.75),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6));
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8));
}

class _TodayFilled extends StatelessWidget {
  final MoodEntry entry;
  const _TodayFilled({required this.entry});
  @override
  Widget build(BuildContext context) {
    final c = Color(entry.colorValue);
    return Row(children: [
      Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: RadialGradient(
              colors: [c.withOpacity(0.85), c.withOpacity(0.35)]),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 18)],
        ),
        child: Center(
            child: Text(entry.emoji, style: const TextStyle(fontSize: 30))),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Feeling ${entry.name}',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: c,
                      letterSpacing: -0.4)),
              const SizedBox(height: 5),
              Row(
                  children: List.generate(
                      5,
                      (i) => Container(
                            width: 18,
                            height: 5,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: i < entry.intensity
                                  ? c
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ))),
              if (entry.totalHabits > 0) ...[
                const SizedBox(height: 5),
                Text(
                    '${entry.completedHabitNames.length}/${entry.totalHabits} habits today',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.38),
                        fontSize: 12)),
              ],
            ]),
      ),
    ]);
  }
}

class _TodayEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.1))),
          child:
              const Center(child: Text('🌙', style: TextStyle(fontSize: 26))),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('How are you today?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 3),
          Text('Tap a mood below to check in',
              style: TextStyle(
                  fontSize: 13, color: Colors.white.withOpacity(0.3))),
        ]),
      ]);
}

class _InsightBanner extends StatelessWidget {
  final String text;
  const _InsightBanner({required this.text});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(22, 16, 22, 0),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFF7C6FF7).withOpacity(0.14),
            const Color(0xFF4FC3A1).withOpacity(0.08),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF7C6FF7).withOpacity(0.3)),
        ),
        child: Row(children: [
          const Text('💡', style: TextStyle(fontSize: 17)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 13,
                      fontWeight: FontWeight.w600))),
        ]),
      );
}

/// Fixed: uses `compact` flag to shrink font when value is long,
/// and wraps value in FittedBox so it never overflows.
class _MiniStat extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  final bool compact;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon,
                  style: TextStyle(fontSize: compact ? 13 : 16)),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: compact ? 12 : 19,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.w600)),
            ]),
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.isSelected,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF7C6FF7);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? c.withOpacity(0.2)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected
                  ? c.withOpacity(0.5)
                  : Colors.white.withOpacity(0.07)),
        ),
        child: Text(label,
            style: TextStyle(
                color:
                    isSelected ? c : Colors.white.withOpacity(0.35),
                fontSize: 13)),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback onDelete;
  const _EntryCard({required this.entry, required this.onDelete});

  String _fmt(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'Today at ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays < 7) {
      return DateFormat("EEEE 'at' h:mm a").format(date);
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color c = Color(entry.colorValue);
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4757).withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFFFF4757).withOpacity(0.3)),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Color(0xFFFF4757), size: 22),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withOpacity(0.22)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      gradient: RadialGradient(colors: [
                        c.withOpacity(0.55),
                        c.withOpacity(0.2)
                      ]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: c.withOpacity(0.3),
                            blurRadius: 12)
                      ]),
                  child: Center(
                      child: Text(entry.emoji,
                          style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(entry.name,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: c,
                                    letterSpacing: -0.3)),
                          ),
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                  5,
                                  (i) => Icon(
                                        i < entry.intensity
                                            ? Icons.circle
                                            : Icons.circle_outlined,
                                        size: 8,
                                        color: c.withOpacity(
                                            i < entry.intensity
                                                ? 1.0
                                                : 0.3),
                                      ))),
                        ]),
                        const SizedBox(height: 4),
                        Text(_fmt(entry.date),
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.white.withOpacity(0.45))),
                      ]),
                ),
              ]),
              if (entry.note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(entry.note,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.55),
                        height: 1.45),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ],
              if (entry.completedHabitNames.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.check_circle_rounded,
                      size: 12, color: c.withOpacity(0.6)),
                  const SizedBox(width: 5),
                  Text(
                      '${entry.completedHabitNames.length}/${entry.totalHabits} habits · ${(entry.completionRate * 100).round()}%',
                      style: TextStyle(
                          color: c.withOpacity(0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              ],
            ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(22, 20, 22, 0),
        padding: const EdgeInsets.symmetric(vertical: 52),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(children: [
          const Text('🌙', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 14),
          Text('Your mood journal is empty',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text('Tap a mood above to begin',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.22),
                  fontSize: 13)),
        ]),
      );
}
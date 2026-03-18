import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_habit_tracker/services/period_service.dart';
import 'package:provider/provider.dart';

class PeriodTrackerPage extends StatefulWidget {
  const PeriodTrackerPage({super.key});

  @override
  State<PeriodTrackerPage> createState() => _PeriodTrackerPageState();
}

class _PeriodTrackerPageState extends State<PeriodTrackerPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  DateTime _calMonth = DateTime(DateTime.now().year, DateTime.now().month);

  static const Color _rose    = Color(0xFFFF6B9D);
  static const Color _violet  = Color(0xFFAB47BC);
  static const Color _teal    = Color(0xFF26A69A);
  static const Color _amber   = Color(0xFFFFB74D);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeriodService>().load();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Log day sheet ──────────────────────────────────────────────────────────
  void _openDayLogger(BuildContext ctx, DateTime date, PeriodService svc) {
    final existing = svc.logForDate(date);
    FlowIntensity? flow = existing?.flow;
    List<PeriodSymptom> symptoms = List.from(existing?.symptoms ?? []);
    final noteCtrl = TextEditingController(text: existing?.note ?? '');

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(builder: (_, setS) {
        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetCtx).size.height * 0.88),
          decoration: const BoxDecoration(
            color: Color(0xFF0E0C1C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 32,
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
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    DateFormat('EEEE, MMMM d').format(date),
                    style: TextStyle(
                        color: _rose,
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 28),

                // Flow
                _SheetLabel(text: 'FLOW INTENSITY', color: _rose),
                const SizedBox(height: 12),
                Row(
                  children: FlowIntensity.values.map((f) {
                    final selected = flow == f;
                    final labels = ['Spotting', 'Light', 'Medium', 'Heavy'];
                    final emojis = ['💧', '🌊', '🔴', '❗'];
                    final i = FlowIntensity.values.indexOf(f);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setS(() => flow = selected ? null : f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? _rose.withOpacity(0.2)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: selected
                                    ? _rose
                                    : Colors.white.withOpacity(0.08)),
                          ),
                          child: Column(children: [
                            Text(emojis[i],
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(labels[i],
                                style: TextStyle(
                                    fontSize: 9,
                                    color: selected
                                        ? _rose
                                        : Colors.white.withOpacity(0.35),
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Symptoms
                _SheetLabel(text: 'SYMPTOMS', color: _violet),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PeriodSymptom.values.map((s) {
                    final on = symptoms.contains(s);
                    return GestureDetector(
                      onTap: () => setS(() {
                        on ? symptoms.remove(s) : symptoms.add(s);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: on
                              ? _violet.withOpacity(0.18)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: on
                                  ? _violet
                                  : Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(s.emoji,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 5),
                          Text(s.label,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: on
                                      ? _violet
                                      : Colors.white.withOpacity(0.4),
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Note
                _SheetLabel(text: 'NOTE', color: _teal),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _teal.withOpacity(0.25)),
                  ),
                  child: TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'How are you feeling? Any notes...',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.2), fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Save
                GestureDetector(
                  onTap: () async {
                    await svc.saveLog(DayLog(
                      date: date,
                      flow: flow,
                      symptoms: symptoms,
                      note: noteCtrl.text.trim(),
                    ));
                    if (mounted) Navigator.pop(sheetCtx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [_rose, _rose.withOpacity(0.7)]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: _rose.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: const Center(
                      child: Text('Save Log',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<PeriodService>(builder: (ctx, svc, _) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final phase = svc.phaseFor(today);

      return Scaffold(
        backgroundColor: const Color(0xFF08060F),
        body: FadeTransition(
          opacity: _fade,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(ctx, svc, phase, today)),
              SliverToBoxAdapter(child: _buildPhaseCard(phase)),
              SliverToBoxAdapter(child: _buildPredictions(svc)),
              SliverToBoxAdapter(
                  child: _buildCalendar(ctx, svc, today)),
              SliverToBoxAdapter(child: _buildStats(svc)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      );
    });
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext ctx, PeriodService svc, CyclePhase phase,
      DateTime today) {
    final phaseColor = Color(phase.color);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(ctx).padding.top + 22,
        left: 22,
        right: 22,
        bottom: 22,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D0B1A),
            Color.lerp(const Color(0xFF0D0B1A), _rose, 0.07)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cycle Tracker',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.1)),
                  Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 13)),
                ]),
          ),
          // Start / End Period button
          GestureDetector(
            onTap: () async {
              if (svc.hasCycleInProgress) {
                await svc.endPeriod(today);
              } else {
                await svc.startPeriod(today);
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  _rose,
                  _rose.withOpacity(0.7),
                ]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: _rose.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Text(
                svc.hasCycleInProgress ? '🛑  End Period' : '🌸  Start Period',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // Today's status card
        GestureDetector(
          onTap: () => _openDayLogger(ctx, today, svc),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  phaseColor.withOpacity(0.18),
                  phaseColor.withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: phaseColor.withOpacity(0.35), width: 1.4),
            ),
            child: Row(children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [
                    phaseColor.withOpacity(0.8),
                    phaseColor.withOpacity(0.3),
                  ]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: phaseColor.withOpacity(0.4), blurRadius: 18)
                  ],
                ),
                child: Center(
                    child:
                        Text(phase.emoji, style: const TextStyle(fontSize: 30))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(phase.label,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: phaseColor,
                              letterSpacing: -0.4)),
                      const SizedBox(height: 4),
                      Text(phase.description,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.45),
                              height: 1.4)),
                    ]),
              ),
              Icon(Icons.edit_note_rounded,
                  color: Colors.white.withOpacity(0.3), size: 20),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Phase info card ─────────────────────────────────────────────────────────
  Widget _buildPhaseCard(CyclePhase phase) {
    final c = Color(phase.color);
    final tips = _phaseTips[phase] ?? [];
    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.22)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SLabel(label: 'PHASE TIPS'),
        const SizedBox(height: 10),
        ...tips.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('✦ ',
                    style: TextStyle(color: c, fontSize: 12)),
                Expanded(
                    child: Text(t,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            height: 1.4))),
              ]),
            )),
      ]),
    );
  }

  static const _phaseTips = {
    CyclePhase.menstrual: [
      'Rest more — your body is working hard',
      'Warm foods & herbal tea help with cramps',
      'Gentle yoga or walking is ideal today',
    ],
    CyclePhase.follicular: [
      'Your energy is rising — try a new habit!',
      'Great time for social plans & creativity',
      'Strength training is especially effective now',
    ],
    CyclePhase.ovulation: [
      'Peak energy & communication skills',
      'Schedule important meetings & workouts',
      'Your skin is glowing — confidence is high!',
    ],
    CyclePhase.luteal: [
      'Reduce caffeine to ease PMS symptoms',
      'Favour calm habits like journaling',
      'Magnesium-rich foods can help with mood',
    ],
  };

  // ── Predictions row ─────────────────────────────────────────────────────────
  Widget _buildPredictions(PeriodService svc) {
    final nextDate = svc.nextPeriodDate;
    final daysUntil = svc.daysUntilNextPeriod;
    final ovDate = svc.ovulationDate;
    final fw = svc.fertileWindow;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SLabel(label: 'PREDICTIONS'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _PredCard(
              icon: '🌸',
              label: 'Next Period',
              value: nextDate != null
                  ? DateFormat('MMM d').format(nextDate)
                  : '—',
              sub: daysUntil != null
                  ? daysUntil == 0
                      ? 'Today'
                      : daysUntil > 0
                          ? 'In $daysUntil days'
                          : '${daysUntil.abs()}d overdue'
                  : 'Log a cycle',
              color: _rose,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PredCard(
              icon: '🌟',
              label: 'Ovulation',
              value: ovDate != null
                  ? DateFormat('MMM d').format(ovDate)
                  : '—',
              sub: fw != null
                  ? 'Fertile ${DateFormat('MMM d').format(fw.start)}–${DateFormat('d').format(fw.end)}'
                  : 'Log a cycle',
              color: const Color(0xFF66BB6A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PredCard(
              icon: '🔄',
              label: 'Avg Cycle',
              value: '${svc.avgCycleLength}d',
              sub: '${svc.totalCycles} cycles logged',
              color: _violet,
            ),
          ),
        ]),
      ]),
    );
  }

  // ── Calendar ───────────────────────────────────────────────────────────────
  Widget _buildCalendar(
      BuildContext ctx, PeriodService svc, DateTime today) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_calMonth.year, _calMonth.month);
    final firstDay = DateTime(_calMonth.year, _calMonth.month, 1);
    final startOffset = (firstDay.weekday - 1) % 7;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Month nav
        Row(children: [
          _SLabel(label: 'CALENDAR'),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _calMonth =
                DateTime(_calMonth.year, _calMonth.month - 1)),
            child: Icon(Icons.chevron_left,
                color: Colors.white.withOpacity(0.4), size: 22),
          ),
          const SizedBox(width: 4),
          Text(DateFormat('MMMM yyyy').format(_calMonth),
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _calMonth =
                DateTime(_calMonth.year, _calMonth.month + 1)),
            child: Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.4), size: 22),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF11101D),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(children: [
            // Weekday labels
            Row(
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            // Days grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1),
              itemCount: startOffset + daysInMonth,
              itemBuilder: (_, idx) {
                if (idx < startOffset) return const SizedBox();
                final day = DateTime(
                    _calMonth.year, _calMonth.month, idx - startOffset + 1);
                final isToday = day.year == today.year &&
                    day.month == today.month &&
                    day.day == today.day;
                final isPeriod = svc.isPeriodDay(day);
                final isFertile = svc.isFertileDay(day);
                final isOvulation = svc.isOvulationDay(day);
                final log = svc.logForDate(day);
                final hasLog = log != null;

                Color? bg;
                Color border = Colors.transparent;
                if (isPeriod) bg = _rose.withOpacity(0.28);
                else if (isOvulation) bg = const Color(0xFF66BB6A).withOpacity(0.3);
                else if (isFertile) bg = const Color(0xFF66BB6A).withOpacity(0.12);

                if (isToday) border = _rose;

                return GestureDetector(
                  onTap: () => _openDayLogger(ctx, day, svc),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Stack(alignment: Alignment.center, children: [
                      Text('${day.day}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday
                                  ? FontWeight.w900
                                  : FontWeight.w500,
                              color: isPeriod
                                  ? _rose
                                  : isOvulation
                                      ? const Color(0xFF66BB6A)
                                      : isFertile
                                          ? const Color(0xFF66BB6A)
                                              .withOpacity(0.8)
                                          : Colors.white.withOpacity(0.65))),
                      if (hasLog)
                        Positioned(
                          bottom: 3,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _amber),
                          ),
                        ),
                    ]),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            // Legend
            Wrap(spacing: 16, runSpacing: 8, children: [
              _Legend(color: _rose.withOpacity(0.5), label: 'Period'),
              _Legend(
                  color: const Color(0xFF66BB6A).withOpacity(0.5),
                  label: 'Fertile'),
              _Legend(
                  color: const Color(0xFF66BB6A),
                  label: 'Ovulation'),
              _Legend(color: _amber, label: 'Logged'),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ── Stats ──────────────────────────────────────────────────────────────────
  Widget _buildStats(PeriodService svc) {
    final topSymptom = svc.topSymptom;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SLabel(label: 'YOUR STATS'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _StatCard(
              emoji: '📓',
              label: 'Total Cycles',
              value: '${svc.totalCycles}',
              color: _rose,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              emoji: '⏱',
              label: 'Avg Length',
              value: '${svc.avgCycleLength}d',
              color: _violet,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              emoji: topSymptom?.emoji ?? '💊',
              label: 'Top Symptom',
              value: topSymptom?.label ?? '—',
              color: _amber,
              compact: true,
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SheetLabel({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6));
}

class _SLabel extends StatelessWidget {
  final String label;
  const _SLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8));
}

class _PredCard extends StatelessWidget {
  final String icon, label, value, sub;
  final Color color;
  const _PredCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.sub,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.22)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(sub,
                style: TextStyle(
                    color: color.withOpacity(0.65),
                    fontSize: 9,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}

class _StatCard extends StatelessWidget {
  final String emoji, label, value;
  final Color color;
  final bool compact;
  const _StatCard(
      {required this.emoji,
      required this.label,
      required this.value,
      required this.color,
      this.compact = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(emoji, style: TextStyle(fontSize: compact ? 13 : 16)),
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

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45), fontSize: 11)),
        ],
      );
}

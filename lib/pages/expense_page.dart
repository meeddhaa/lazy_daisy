import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mini_habit_tracker/database/expense_database.dart';
import 'package:mini_habit_tracker/models/expense.dart';
import 'package:provider/provider.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseDatabase>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, db, _) {
        if (!db.hasProfile) return _ProfilePickerScreen(db: db);
        return _ExpenseMainScreen(db: db);
      },
    );
  }
}

// ─────────────────────────────────────────────
// Currency Picker Widget (reusable)
// ─────────────────────────────────────────────
class _CurrencyPicker extends StatelessWidget {
  final ExpenseCurrency selected;
  final ValueChanged<ExpenseCurrency> onSelected;
  final bool compact;

  const _CurrencyPicker({
    required this.selected,
    required this.onSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact)
          const Text(
            'Currency',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
        if (!compact) const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExpenseCurrency.values.map((c) {
            final isSelected = c == selected;
            return GestureDetector(
              onTap: () => onSelected(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF9370DB).withOpacity(0.12)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF9370DB)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c.flag, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '${c.symbol} ${c.code}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF9370DB)
                            : Colors.black54,
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

// ─────────────────────────────────────────────
// Profile Picker (first launch) — now with currency step
// ─────────────────────────────────────────────
class _ProfilePickerScreen extends StatefulWidget {
  final ExpenseDatabase db;
  const _ProfilePickerScreen({required this.db});

  @override
  State<_ProfilePickerScreen> createState() => _ProfilePickerScreenState();
}

class _ProfilePickerScreenState extends State<_ProfilePickerScreen> {
  ExpenseProfile? _selectedProfile;
  ExpenseCurrency _selectedCurrency = ExpenseCurrency.bdt;
  int _step = 0; // 0 = pick profile, 1 = pick currency

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _step == 0 ? _buildProfileStep() : _buildCurrencyStep(),
        ),
      ),
    );
  }

  Widget _buildProfileStep() {
    return Padding(
      key: const ValueKey('profile'),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text('💰', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 20),
          const Text(
            'Expense Sheet',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your profile to get tailored categories.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          _ProfileCard(
            emoji: '🎓',
            title: 'Student',
            subtitle:
                'Tuition, textbooks, dorm,\npocket money & social life',
            color: const Color(0xFF9370DB),
            isSelected: _selectedProfile == ExpenseProfile.student,
            onTap: () =>
                setState(() => _selectedProfile = ExpenseProfile.student),
          ),
          const SizedBox(height: 16),
          _ProfileCard(
            emoji: '💼',
            title: 'Professional',
            subtitle:
                'Salary, rent, bills, EMI,\ninvestments & more',
            color: const Color(0xFF4CAF50),
            isSelected: _selectedProfile == ExpenseProfile.professional,
            onTap: () => setState(
                () => _selectedProfile = ExpenseProfile.professional),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedProfile == null
                  ? null
                  : () => setState(() => _step = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9370DB),
                disabledBackgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Next →',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCurrencyStep() {
    return Padding(
      key: const ValueKey('currency'),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => setState(() => _step = 0),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios,
                    size: 16, color: Colors.black45),
                Text('Back',
                    style:
                        TextStyle(fontSize: 14, color: Colors.black45)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('🌍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 20),
          const Text(
            'Pick your Currency',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can change this anytime in Expense Settings.',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          _CurrencyPicker(
            selected: _selectedCurrency,
            onSelected: (c) => setState(() => _selectedCurrency = c),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await widget.db.setProfile(_selectedProfile!);
                await widget.db.setCurrency(_selectedCurrency);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9370DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                "Let's Go ${_selectedProfile?.emoji ?? ''}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Profile Card
// ─────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
                color: isSelected
                    ? color.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14)),
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                          height: 1.4)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24)
            else
              const Icon(Icons.radio_button_unchecked,
                  color: Colors.black26, size: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Main Expense Screen
// ─────────────────────────────────────────────
class _ExpenseMainScreen extends StatelessWidget {
  final ExpenseDatabase db;
  const _ExpenseMainScreen({required this.db});

  String _fmt(double v) {
    final sym = db.currency.symbol;
    return '$sym${NumberFormat('#,##0.00').format(v)}';
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expense Sheet',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black87)),
            Text(
                '${db.profile!.emoji} ${db.profile!.label} · $monthLabel',
                style:
                    const TextStyle(fontSize: 12, color: Colors.black45)),
          ],
        ),
        actions: [
          // ✅ Settings button
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black54),
            tooltip: 'Expense Settings',
            onPressed: () => _showExpenseSettings(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntry(context),
        backgroundColor: const Color(0xFF9370DB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Entry',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBalanceCard(),
          const SizedBox(height: 16),
          if (db.thisMonthEntries
              .any((e) => e.type == EntryType.expense)) ...[
            _buildCategoryBreakdown(),
            const SizedBox(height: 16),
          ],
          _buildEntryList(context),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Expense Settings bottom sheet ─────────
  void _showExpenseSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.gear,
                      color: Color(0xFF9370DB), size: 20),
                  const SizedBox(width: 10),
                  const Text('Expense Settings',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 28),

              // Currency section
              const Text('Currency',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
              const SizedBox(height: 12),
              _CurrencyPicker(
                selected: db.currency,
                onSelected: (c) {
                  ctx.read<ExpenseDatabase>().setCurrency(c);
                  setS(() {});
                },
              ),
              const SizedBox(height: 28),

              // Profile section
              const Text('Profile',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
              const SizedBox(height: 12),
              Row(
                children: ExpenseProfile.values.map((p) {
                  final isSelected = p == db.profile;
                  final color = p == ExpenseProfile.student
                      ? const Color(0xFF9370DB)
                      : const Color(0xFF4CAF50);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ctx.read<ExpenseDatabase>().setProfile(p);
                        setS(() {});
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.1)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color:
                                  isSelected ? color : Colors.transparent,
                              width: 2),
                        ),
                        child: Column(
                          children: [
                            Text(p.emoji,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(p.label,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? color
                                        : Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              const Text(
                'Switching profile changes your category list. Existing entries are kept.',
                style: TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Balance card ──────────────────────────
  Widget _buildBalanceCard() {
    final isPositive = db.balance >= 0;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF9370DB), const Color(0xFFB39DDB)]
              : [const Color(0xFFE57373), const Color(0xFFEF9A9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: (isPositive
                      ? const Color(0xFF9370DB)
                      : const Color(0xFFE57373))
                  .withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Balance',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 14)),
              // Currency badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${db.currency.flag} ${db.currency.code}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${isPositive ? '+' : ''}${_fmt(db.balance)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryChip(
                  icon: Icons.arrow_downward,
                  label: 'Income',
                  value: _fmt(db.totalIncome),
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(
                  icon: Icons.arrow_upward,
                  label: 'Expenses',
                  value: _fmt(db.totalExpense),
                  color: Colors.redAccent.shade100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Category breakdown ────────────────────
  Widget _buildCategoryBreakdown() {
    final totals = db.categoryTotals;
    if (totals.isEmpty) return const SizedBox.shrink();
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spending by Category',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          ...sorted.take(6).map((entry) {
            final cat = entry.key;
            final pct = max > 0 ? entry.value / max : 0.0;
            final hexColor = cat.colorHex.replaceFirst('#', '0xFF');
            final color = Color(int.parse(hexColor));
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(cat.label,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                            Text(_fmt(entry.value),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct.clamp(0.0, 1.0),
                            minHeight: 7,
                            backgroundColor: Colors.grey.shade100,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Entry list ────────────────────────────
  Widget _buildEntryList(BuildContext context) {
    final entries = db.entries;
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.receipt_long,
                  size: 60, color: Colors.black.withOpacity(0.2)),
              const SizedBox(height: 16),
              const Text(
                  'No entries yet.\nTap + Add Entry to get started!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black45, fontSize: 15)),
            ],
          ),
        ),
      );
    }

    final grouped = <String, List<ExpenseEntry>>{};
    for (final e in entries) {
      final key = DateFormat('MMMM d, yyyy').format(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(group.key,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45)),
            ),
            ...group.value.map((entry) => _EntryTile(
                  entry: entry,
                  currencySymbol: db.currency.symbol,
                  onDelete: () =>
                      context.read<ExpenseDatabase>().deleteEntry(entry.id),
                )),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  // ─── Add entry bottom sheet ────────────────
  void _showAddEntry(BuildContext context) {
    final categories =
        ExpenseCategoryExtension.forProfile(db.profile!);
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    EntryType selectedType = EntryType.expense;
    ExpenseCategory selectedCat = categories.first;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add Entry',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    // Currency indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: const Color(0xFF9370DB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        '${db.currency.flag} ${db.currency.symbol} ${db.currency.code}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9370DB),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Income / Expense toggle
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: EntryType.values.map((t) {
                      final isSelected = t == selectedType;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setS(() => selectedType = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.all(4),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (t == EntryType.income
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFE57373))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                t == EntryType.income
                                    ? '💰 Income'
                                    : '💸 Expense',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                _inputField(titleCtrl,
                    'Title (e.g. Lunch, Netflix)'),
                const SizedBox(height: 12),
                _inputField(
                  amountCtrl,
                  'Amount (${db.currency.symbol})',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                ),
                const SizedBox(height: 16),

                // Category
                const Text('Category',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = cat == selectedCat;
                    final hexColor =
                        cat.colorHex.replaceFirst('#', '0xFF');
                    final color = Color(int.parse(hexColor));
                    return GestureDetector(
                      onTap: () => setS(() => selectedCat = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? color
                                  : Colors.transparent,
                              width: 2),
                        ),
                        child: Text(
                            '${cat.emoji} ${cat.label}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? color
                                    : Colors.black54)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null)
                      setS(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.black54),
                        const SizedBox(width: 10),
                        Text(
                            DateFormat('MMMM d, yyyy')
                                .format(selectedDate),
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _inputField(noteCtrl, 'Note (optional)'),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      final amtStr = amountCtrl.text.trim();
                      if (title.isEmpty || amtStr.isEmpty) return;
                      final amt = double.tryParse(amtStr);
                      if (amt == null || amt <= 0) return;
                      context.read<ExpenseDatabase>().addEntry(
                            ExpenseEntry(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              title: title,
                              amount: amt,
                              type: selectedType,
                              category: selectedCat,
                              date: selectedDate,
                              note: noteCtrl.text.trim().isEmpty
                                  ? null
                                  : noteCtrl.text.trim(),
                            ),
                          );
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9370DB),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Save Entry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Summary Chip
// ─────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _SummaryChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Entry Tile
// ─────────────────────────────────────────────
class _EntryTile extends StatelessWidget {
  final ExpenseEntry entry;
  final String currencySymbol;
  final VoidCallback onDelete;

  const _EntryTile({
    required this.entry,
    required this.currencySymbol,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == EntryType.income;
    final hexColor = entry.category.colorHex.replaceFirst('#', '0xFF');
    final catColor = Color(int.parse(hexColor));

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: Text(entry.category.emoji,
                      style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  Text(
                    entry.category.label +
                        (entry.note != null
                            ? ' · ${entry.note}'
                            : ''),
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}$currencySymbol${NumberFormat('#,##0.00').format(entry.amount)}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isIncome
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE57373)),
            ),
          ],
        ),
      ),
    );
  }
}
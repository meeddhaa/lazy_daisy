import 'dart:convert';

// ─────────────────────────────────────────────
// Currency
// ─────────────────────────────────────────────
enum ExpenseCurrency { bdt, usd, eur, inr, krw }

extension ExpenseCurrencyExtension on ExpenseCurrency {
  String get symbol {
    switch (this) {
      case ExpenseCurrency.bdt: return '৳';
      case ExpenseCurrency.usd: return '\$';
      case ExpenseCurrency.eur: return '€';
      case ExpenseCurrency.inr: return '₹';
      case ExpenseCurrency.krw: return '₩';
    }
  }

  String get code {
    switch (this) {
      case ExpenseCurrency.bdt: return 'BDT';
      case ExpenseCurrency.usd: return 'USD';
      case ExpenseCurrency.eur: return 'EUR';
      case ExpenseCurrency.inr: return 'INR';
      case ExpenseCurrency.krw: return 'KRW';
    }
  }

  String get label {
    switch (this) {
      case ExpenseCurrency.bdt: return 'Taka';
      case ExpenseCurrency.usd: return 'Dollar';
      case ExpenseCurrency.eur: return 'Euro';
      case ExpenseCurrency.inr: return 'Rupee';
      case ExpenseCurrency.krw: return 'Won';
    }
  }

  String get flag {
    switch (this) {
      case ExpenseCurrency.bdt: return '🇧🇩';
      case ExpenseCurrency.usd: return '🇺🇸';
      case ExpenseCurrency.eur: return '🇪🇺';
      case ExpenseCurrency.inr: return '🇮🇳';
      case ExpenseCurrency.krw: return '🇰🇷';
    }
  }
}

// ─────────────────────────────────────────────
// User Profile
// ─────────────────────────────────────────────
enum ExpenseProfile { student, professional }

extension ExpenseProfileExtension on ExpenseProfile {
  String get label =>
      this == ExpenseProfile.student ? 'Student' : 'Professional';
  String get emoji => this == ExpenseProfile.student ? '🎓' : '💼';
  String get incomeLabel =>
      this == ExpenseProfile.student ? 'Pocket Money / Allowance' : 'Salary / Income';
}

// ─────────────────────────────────────────────
// Expense Category
// ─────────────────────────────────────────────
enum ExpenseCategory {
  food, transport, shopping, health, entertainment, other,
  tuition, textbooks, dorm, subscriptions, social,
  rent, groceries, bills, emi, travel, investments,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food: return 'Food';
      case ExpenseCategory.transport: return 'Transport';
      case ExpenseCategory.shopping: return 'Shopping';
      case ExpenseCategory.health: return 'Health';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.other: return 'Other';
      case ExpenseCategory.tuition: return 'Tuition';
      case ExpenseCategory.textbooks: return 'Textbooks';
      case ExpenseCategory.dorm: return 'Dorm / Housing';
      case ExpenseCategory.subscriptions: return 'Subscriptions';
      case ExpenseCategory.social: return 'Social';
      case ExpenseCategory.rent: return 'Rent';
      case ExpenseCategory.groceries: return 'Groceries';
      case ExpenseCategory.bills: return 'Bills';
      case ExpenseCategory.emi: return 'EMI / Loan';
      case ExpenseCategory.travel: return 'Travel';
      case ExpenseCategory.investments: return 'Investments';
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.food: return '🍔';
      case ExpenseCategory.transport: return '🚌';
      case ExpenseCategory.shopping: return '🛍️';
      case ExpenseCategory.health: return '💊';
      case ExpenseCategory.entertainment: return '🎬';
      case ExpenseCategory.other: return '📦';
      case ExpenseCategory.tuition: return '🏫';
      case ExpenseCategory.textbooks: return '📚';
      case ExpenseCategory.dorm: return '🏠';
      case ExpenseCategory.subscriptions: return '📱';
      case ExpenseCategory.social: return '🎉';
      case ExpenseCategory.rent: return '🏠';
      case ExpenseCategory.groceries: return '🛒';
      case ExpenseCategory.bills: return '💡';
      case ExpenseCategory.emi: return '🏦';
      case ExpenseCategory.travel: return '✈️';
      case ExpenseCategory.investments: return '📈';
    }
  }

  String get colorHex {
    switch (this) {
      case ExpenseCategory.food: return '#FFB6C1';
      case ExpenseCategory.transport: return '#B0C4DE';
      case ExpenseCategory.shopping: return '#FFDAB9';
      case ExpenseCategory.health: return '#B4E7CE';
      case ExpenseCategory.entertainment: return '#E6E6FA';
      case ExpenseCategory.other: return '#D3D3D3';
      case ExpenseCategory.tuition: return '#FFD700';
      case ExpenseCategory.textbooks: return '#87CEEB';
      case ExpenseCategory.dorm: return '#DDA0DD';
      case ExpenseCategory.subscriptions: return '#98FB98';
      case ExpenseCategory.social: return '#FFA07A';
      case ExpenseCategory.rent: return '#DDA0DD';
      case ExpenseCategory.groceries: return '#90EE90';
      case ExpenseCategory.bills: return '#F0E68C';
      case ExpenseCategory.emi: return '#F08080';
      case ExpenseCategory.travel: return '#87CEFA';
      case ExpenseCategory.investments: return '#98FB98';
    }
  }

  static List<ExpenseCategory> forProfile(ExpenseProfile profile) {
    if (profile == ExpenseProfile.student) {
      return [
        ExpenseCategory.food, ExpenseCategory.transport,
        ExpenseCategory.tuition, ExpenseCategory.textbooks,
        ExpenseCategory.dorm, ExpenseCategory.subscriptions,
        ExpenseCategory.social, ExpenseCategory.shopping,
        ExpenseCategory.health, ExpenseCategory.entertainment,
        ExpenseCategory.other,
      ];
    } else {
      return [
        ExpenseCategory.food, ExpenseCategory.transport,
        ExpenseCategory.rent, ExpenseCategory.groceries,
        ExpenseCategory.bills, ExpenseCategory.emi,
        ExpenseCategory.travel, ExpenseCategory.shopping,
        ExpenseCategory.health, ExpenseCategory.investments,
        ExpenseCategory.entertainment, ExpenseCategory.other,
      ];
    }
  }
}

// ─────────────────────────────────────────────
// Entry Type
// ─────────────────────────────────────────────
enum EntryType { income, expense }

// ─────────────────────────────────────────────
// Expense Entry
// ─────────────────────────────────────────────
class ExpenseEntry {
  final String id;
  final String title;
  final double amount;
  final EntryType type;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;

  ExpenseEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'category': category.name,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) {
    return ExpenseEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: EntryType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => EntryType.expense),
      category: ExpenseCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => ExpenseCategory.other),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  static String encodeList(List<ExpenseEntry> entries) =>
      jsonEncode(entries.map((e) => e.toJson()).toList());

  static List<ExpenseEntry> decodeList(String source) {
    final List<dynamic> list = jsonDecode(source);
    return list
        .map((e) => ExpenseEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
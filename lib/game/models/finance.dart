class FinanceEntry {
  FinanceEntry({
    required this.title,
    required this.detail,
    required this.category,
    required this.amount,
    required this.requiredAmount,
    required this.debtChange,
    required this.balanceAfter,
    required this.debtAfter,
  });
  final String title, detail, category;
  final int amount, requiredAmount, debtChange, balanceAfter, debtAfter;
  factory FinanceEntry.fromJson(Map<String, dynamic> j) => FinanceEntry(
    title: j['title'],
    detail: j['detail'],
    category: j['category'],
    amount: j['amount'],
    requiredAmount: j['requiredAmount'],
    debtChange: j['debtChange'],
    balanceAfter: j['balanceAfter'],
    debtAfter: j['debtAfter'],
  );
  Map<String, dynamic> toJson() => {
    'title': title,
    'detail': detail,
    'category': category,
    'amount': amount,
    'requiredAmount': requiredAmount,
    'debtChange': debtChange,
    'balanceAfter': balanceAfter,
    'debtAfter': debtAfter,
  };
}

class FinanceWeek {
  FinanceWeek({
    required this.week,
    required this.openingBalance,
    required this.openingDebt,
    required this.closingBalance,
    required this.closingDebt,
    this.closed = false,
    this.partial = false,
    List<FinanceEntry>? entries,
  }) : entries = entries ?? [];
  final int week, openingBalance, openingDebt;
  int closingBalance, closingDebt;
  bool closed, partial;
  final List<FinanceEntry> entries;
  int get income =>
      entries.where((e) => e.amount > 0).fold(0, (sum, e) => sum + e.amount);
  int get expense =>
      entries.where((e) => e.amount < 0).fold(0, (sum, e) => sum - e.amount);
  int get newDebt => entries
      .where((e) => e.debtChange > 0)
      .fold(0, (sum, e) => sum + e.debtChange);
  int get debtReduction => entries
      .where((e) => e.debtChange < 0)
      .fold(0, (sum, e) => sum - e.debtChange);
  factory FinanceWeek.fromJson(Map<String, dynamic> j) => FinanceWeek(
    week: j['week'],
    openingBalance: j['openingBalance'],
    openingDebt: j['openingDebt'],
    closingBalance: j['closingBalance'],
    closingDebt: j['closingDebt'],
    closed: j['closed'] == true,
    partial: j['partial'] == true,
    entries:
        (j['entries'] as List)
            .map((e) => FinanceEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
  );
  Map<String, dynamic> toJson() => {
    'week': week,
    'openingBalance': openingBalance,
    'openingDebt': openingDebt,
    'closingBalance': closingBalance,
    'closingDebt': closingDebt,
    'closed': closed,
    'partial': partial,
    'entries': entries.map((e) => e.toJson()).toList(),
  };
}

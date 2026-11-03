class FoodEntry {
  FoodEntry({
    required this.title,
    required this.detail,
    required this.category,
    required this.amount,
    required this.requested,
    required this.balanceAfter,
    this.prepaid = 0,
    this.applied = 0,
    this.expired = 0,
    this.rationNeed = 0,
  });
  final String title, detail, category;
  final int amount,
      requested,
      balanceAfter,
      prepaid,
      applied,
      expired,
      rationNeed;
  int get overflow => requested > 0 ? requested - amount : 0;
  int get shortfall => requested < 0 ? amount - requested : 0;
  factory FoodEntry.fromJson(Map<String, dynamic> j) => FoodEntry(
    title: j['title'],
    detail: j['detail'] ?? '',
    category: j['category'],
    amount: j['amount'],
    requested: j['requested'],
    balanceAfter: j['balanceAfter'],
    prepaid: j['prepaid'] ?? 0,
    applied: j['applied'] ?? 0,
    expired: j['expired'] ?? 0,
    rationNeed: j['rationNeed'] ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'title': title,
    'detail': detail,
    'category': category,
    'amount': amount,
    'requested': requested,
    'balanceAfter': balanceAfter,
    'prepaid': prepaid,
    'applied': applied,
    'expired': expired,
    'rationNeed': rationNeed,
  };
}

class FoodWeek {
  FoodWeek({
    required this.week,
    required this.openingBalance,
    required this.closingBalance,
    required this.openingPrepaid,
    required this.capacity,
    this.closed = false,
    this.partial = false,
    List<FoodEntry>? entries,
  }) : entries = entries ?? [];
  final int week, openingBalance, openingPrepaid;
  int closingBalance, capacity;
  bool closed, partial;
  final List<FoodEntry> entries;
  int get income =>
      entries.where((e) => e.amount > 0).fold(0, (n, e) => n + e.amount);
  int get expense =>
      entries.where((e) => e.amount < 0).fold(0, (n, e) => n - e.amount);
  int get prepaid => entries.fold(openingPrepaid, (n, e) => n + e.prepaid);
  int get applied => entries.fold(0, (n, e) => n + e.applied);
  int get expired => entries.fold(0, (n, e) => n + e.expired);
  int get overflow => entries.fold(0, (n, e) => n + e.overflow);
  int get shortfall => entries.fold(0, (n, e) => n + e.shortfall);
  int get outstanding => prepaid - applied - expired;
  factory FoodWeek.fromJson(Map<String, dynamic> j) => FoodWeek(
    week: j['week'],
    openingBalance: j['openingBalance'],
    closingBalance: j['closingBalance'],
    openingPrepaid: j['openingPrepaid'] ?? 0,
    capacity: j['capacity'],
    closed: j['closed'] == true,
    partial: j['partial'] == true,
    entries:
        (j['entries'] as List? ?? [])
            .map((e) => FoodEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
  );
  Map<String, dynamic> toJson() => {
    'week': week,
    'openingBalance': openingBalance,
    'closingBalance': closingBalance,
    'openingPrepaid': openingPrepaid,
    'capacity': capacity,
    'closed': closed,
    'partial': partial,
    'entries': entries.map((e) => e.toJson()).toList(),
  };
}

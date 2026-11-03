/// Seasonal production losses; previous harvest samples are never rewritten.
class FoodDisruption {
  FoodDisruption({
    required this.id,
    required this.title,
    required this.percent,
    required this.start,
    required this.until,
    this.lastReliefTurn = 0,
  });
  final String id, title;
  int percent, start, until, lastReliefTurn;
  bool active(int turn) => percent > 0 && start <= turn && turn <= until;
  factory FoodDisruption.fromJson(Map<String, dynamic> j) => FoodDisruption(
    id: j['id'],
    title: j['title'],
    percent: j['percent'],
    start: j['start'],
    until: j['until'],
    lastReliefTurn: j['lastReliefTurn'] ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'percent': percent,
    'start': start,
    'until': until,
    'lastReliefTurn': lastReliefTurn,
  };
}

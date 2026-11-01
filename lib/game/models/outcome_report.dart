/// A receipt for one resolved delayed task/event, committed with its effects.
class OutcomeReport {
  const OutcomeReport({
    required this.id,
    required this.week,
    required this.title,
    required this.status,
    required this.detail,
    required this.changes,
  });
  final String id, title, status, detail;
  final int week;
  final Map<String, int> changes;

  String get statusLabel => switch (status) {
    'success' => 'Thành công',
    'failure' => 'Thất bại',
    'partial' => 'Hoàn thành một phần',
    'interrupted' => 'Gián đoạn',
    _ => 'Chưa có kết luận',
  };

  factory OutcomeReport.fromJson(Map<String, dynamic> j) => OutcomeReport(
    id: j['id'] as String,
    week: (j['week'] as num).toInt(),
    title: j['title'] as String,
    status: j['status'] as String,
    detail: j['detail'] as String,
    changes: (j['changes'] as Map).map(
      (k, v) => MapEntry(k as String, (v as num).toInt()),
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'week': week,
    'title': title,
    'status': status,
    'detail': detail,
    'changes': changes,
  };
}

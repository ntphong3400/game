part of 'game_engine.dart';

extension FoodLedgerEngine on GameEngine {
  FoodWeek? _foodWeek(GameState s) {
    if (s.population == null) return null;
    if (s.foodWeeks.isEmpty || s.foodWeeks.last.week != s.week) {
      s.foodWeeks.add(
        FoodWeek(
          week: s.week,
          openingBalance: s.grain,
          closingBalance: s.grain,
          openingPrepaid: s.population!.foodCredit,
          capacity: foodCapacity(s),
          partial:
              s.foodWeeks.isEmpty && (s.revision > 0 || s.completedWeeks > 0),
        ),
      );
    }
    final report = s.foodWeeks.last;
    if (!report.closed && report.closingBalance != s.grain) {
      // An imported/edited save can contain a balance without its transactions.
      // Disclose the gap instead of inventing old purchases or harvests.
      final delta = s.grain - report.closingBalance;
      report.partial = true;
      report.entries.add(
        FoodEntry(
          title: 'Đối chiếu số dư ngoài sổ',
          detail:
              'Số tồn trong dữ liệu đã thay đổi so với lần ghi cuối; không có chi tiết nguồn phát sinh.',
          category: 'adjustment',
          amount: delta,
          requested: delta,
          balanceAfter: s.grain,
        ),
      );
      report.closingBalance = s.grain;
    }
    final creditGap =
        s.population!.foodCredit - (report.prepaid - report.expired);
    if (!report.closed && creditGap != 0) {
      report.partial = true;
      report.entries.add(
        FoodEntry(
          title: 'Đối chiếu khẩu phần ngoài sổ',
          detail:
              'Phần đối trừ trong dữ liệu khác lần ghi cuối; chỉ điều chỉnh thông tin khẩu phần, không thay đổi tồn kho.',
          category: 'prepaid',
          amount: 0,
          requested: 0,
          balanceAfter: s.grain,
          prepaid: math.max(0, creditGap),
          expired: math.max(0, -creditGap),
        ),
      );
    }
    return report;
  }

  void _recordFood(GameState s, FoodEntry entry) {
    final report = s.foodWeeks.last;
    report.entries.add(entry);
    report.closingBalance = s.grain;
    report.capacity = foodCapacity(s);
  }

  void _prepayFood(GameState s, int amount, String title) {
    if (s.population == null || amount <= 0) return;
    _foodWeek(s);
    s.population!.foodCredit += amount;
    _recordFood(
      s,
      FoodEntry(
        title: title,
        detail:
            'Khẩu phần đã nằm trong đợt xuất kho; chỉ đối trừ tiêu dùng cuối mùa, không phải lương nhập thêm.',
        category: 'prepaid',
        amount: 0,
        requested: 0,
        prepaid: amount,
        balanceAfter: s.grain,
      ),
    );
  }

  void _closeFoodWeek(GameState s) {
    final report = _foodWeek(s);
    if (report == null || report.closed) return;
    final unused = math.max(0, report.outstanding);
    if (unused > 0) {
      _recordFood(
        s,
        FoodEntry(
          title: 'Khẩu phần đối trừ chưa sử dụng hết',
          detail:
              'Phần đối trừ chưa dùng kết thúc cùng mùa, không chuyển thành lương nhập kho hoặc chuyển sang mùa sau.',
          category: 'prepaid',
          amount: 0,
          requested: 0,
          expired: unused,
          balanceAfter: s.grain,
        ),
      );
    }
    report.closed = true;
    report.capacity = foodCapacity(s);
  }
}

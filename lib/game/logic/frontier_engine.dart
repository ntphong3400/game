part of 'game_engine.dart';

extension FrontierEngine on GameEngine {
  void _transferTroops(GameState s, GameCommand command) {
    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(command.option));
    } catch (_) {
      throw const GameRuleException('Lệnh điều quân không hợp lệ.');
    }
    final from = data['from'] is String ? data['from'] as String : '';
    final to = command.target;
    final rawCount = data['count'];
    final count = rawCount is int ? rawCount : 0;
    final blocked = transferBlocked(s, from, to, count);
    if (blocked != null) throw GameRuleException(blocked);
    final warning = transferWarning(s, from, count);
    _spend(s, 0, title: 'Điều quân đến ${garrisonNames[to]}');
    final p = s.population!;
    final destinationTroops = p.stationed(to);
    p.setTrainingAt(
      to,
      (destinationTroops * p.trainingAt(to) + count * p.trainingAt(from)) /
          (destinationTroops + count),
    );
    p.setMoraleAt(
      to,
      (destinationTroops * p.moraleAt(to) + count * p.moraleAt(from)) /
          (destinationTroops + count),
    );
    p.garrisons[from] = p.stationed(from) - count;
    p.garrisons[to] = p.stationed(to) + count;
    s.workThisWeek++;
    s.affairsThisWeek++;
    s.note(
      'Điều quân',
      '${whole(count)} quân từ ${garrisonNames[from]} đến ${garrisonNames[to]}. Quân đã đến nơi. $warning',
    );
  }

  void _frontierDefense(GameState s, Map<String, FrontierDefense> forecasts) {
    final w = s.warfare;
    if (w == null || w.lastDefenseWeek >= s.week) return;
    w.lastDefenseWeek = s.week;
    for (final n in w.neighbors) {
      final d = forecasts[n.id];
      if (d == null || d.penalty == 0 || frontierProtected(s, n)) continue;
      final actual = math.min(d.penalty, n.advantage + 100);
      n.advantage -= actual;
      final detail = '${d.forecast} Ưu thế còn ${n.advantage}.';
      w.reports.insert(0, {
        'week': s.week,
        'countryId': n.id,
        'title': 'Phòng thủ ${garrisonNames[n.id]}',
        'detail': detail,
        'result': 'defense',
        'penalty': actual,
      });
      s.note('Phòng thủ ${garrisonNames[n.id]}', detail, 'warning');
    }
  }

  void _frontierNewYear(GameState s) {
    if (!s.seasonal ||
        s.warfare == null ||
        s.completedWeeks == 0 ||
        s.completedWeeks % 4 != 0) {
      return;
    }
    final endedYear = s.completedWeeks ~/ 4;
    final range = reinforcementRange(endedYear);
    for (final n in s.warfare!.neighbors) {
      if (n.lastReinforcementYear >= endedYear) continue;
      final roll =
          range.low + _next(s, (range.high - range.low) ~/ 100 + 1) * 100;
      final actual = math.min(
        roll,
        math.max(0, enemyFrontierCap - n.enemyTroops),
      );
      n.enemyTroops += actual;
      n.lastReinforcementYear = endedYear;
      n.lastReinforcement = actual;
      n.lastReinforcementRoll = roll;
      final detail =
          '${n.name} tăng viện +${whole(actual)} quân; tổng ${whole(n.enemyTroops)} quân tại biên giới.${actual < roll ? ' Bốc ${whole(roll)} quân, chỉ nhận phần còn thiếu tới trần 40.000.' : ''}';
      s.warfare!.reports.insert(0, {
        'week': s.week,
        'countryId': n.id,
        'title': 'Tăng viện đầu năm ${endedYear + 1}',
        'detail': detail,
        'result': 'reinforcement',
        'troops': actual,
        'rolled': roll,
      });
      s.note('Quân báo đầu năm · ${n.name}', detail, 'warning');
    }
  }
}

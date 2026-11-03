part of 'game_engine.dart';

extension FoodPressureEngine on GameEngine {
  void _creditReliefFood(GameState s, int rations) {
    if (!s.foodPressureEnabled || rations <= 0) return;
    final credit = math.min(rations, remainingFoodConsumption(s));
    _prepayFood(s, credit, 'Khẩu phần cứu trợ đã cấp trước');
    _populationChange(s, 'Khẩu phần cứu trợ đã cấp trước (tạ)', credit);
  }

  void _recordCrisisPressure(GameState s, MajorMission m, int choice) {
    if (!isProductionCrisis(s, m) || choice == 0) {
      return;
    }
    final percent = crisisProductionPercent(m, choice);
    final until = s.week + (choice == 1 ? 0 : 1);
    final id = 'production-${m.id}';
    _recordProductionDisruption(
      s,
      id,
      majorDefinition(m.kind).title,
      percent,
      until,
    );
  }

  void _recordOrdinaryDisaster(GameState s, EventDefinition e, int index) {
    if (!s.foodPressureEnabled ||
        !isOrdinaryProductionDisaster(e) ||
        index == 0) {
      return;
    }
    final ignored = index == e.choices.length - 1;
    _recordProductionDisruption(
      s,
      'petition-production-${e.id}',
      e.title,
      ignored ? 25 : 12,
      s.week + (ignored ? 1 : 0),
    );
  }

  void _recordProductionDisruption(
    GameState s,
    String id,
    String title,
    int percent,
    int until,
  ) {
    final old = s.foodDisruptions.where((e) => e.id == id).firstOrNull;
    if (old == null) {
      s.foodDisruptions.add(
        FoodDisruption(
          id: id,
          title: title,
          percent: percent,
          start: s.week,
          until: until,
        ),
      );
    } else {
      final active = old.active(s.week);
      old.percent = active ? math.max(old.percent, percent) : percent;
      if (!active) old.start = s.week;
      old.until = math.max(old.until, until);
    }
    s.note(
      'Gián đoạn sản xuất',
      '$title: giảm $percent% '
          'năng suất phần mùa liên quan đến hết ${s.date(until)}. Tổng các nguyên nhân giới hạn 35%. '
          'Nếu còn kéo dài, mùa sau sẽ trình tấu cứu trợ để bệ hạ quyết định.',
      'warning',
    );
  }

  bool _syncFoodRecoveryPetitions(GameState s) {
    var changed = false;
    for (final effect in s.foodDisruptions.where(
      (e) => foodRecoveryDue(s, e),
    )) {
      final id = foodRecoveryId(effect);
      if (s.petitions.any((p) => p.definitionId == id)) continue;
      s.petitions.add(
        Petition(
          id: '$id:${s.week}',
          definitionId: id,
          openedWeek: s.week,
          deadline: s.week,
        ),
      );
      changed = true;
    }
    return changed;
  }

  void _resolveFoodRecovery(
    GameState s,
    Petition p,
    String option, {
    bool expired = false,
    String assigneeId = '',
  }) {
    final effect =
        s.foodDisruptions
            .where((e) => foodRecoveryId(e) == p.definitionId)
            .firstOrNull;
    final index = int.tryParse(option);
    if (expired && (effect == null || !foodRecoveryDue(s, effect))) {
      s.petitions.remove(p);
      return;
    }
    if (effect == null ||
        !foodRecoveryDue(s, effect) ||
        index == null ||
        index < 0 ||
        index > 2 ||
        assigneeId.isNotEmpty) {
      throw const GameRuleException(
        'Tấu cứu trợ không còn phù hợp với tình hình.',
      );
    }
    final e = foodRecoveryEvent(s, p.definitionId)!, c = e.choices[index];
    final base = recoveryRations(s, effect);
    if (!expired) {
      _spend(s, 0, grain: c.grainCost, title: e.title, detail: c.hint);
      s.workThisWeek++;
      s.affairsThisWeek++;
    }
    if (index < 2) {
      _creditReliefFood(s, index == 0 ? base : (base / 2).ceil());
      _respond(s, 'hunger');
      effect.percent = index == 0 ? 0 : (effect.percent / 2).ceil();
    }
    effect.lastReliefTurn = s.week;
    _apply(s, c.effects, title: e.title);
    s.petitions.remove(p);
    s.note(
      e.title,
      '${expired ? 'Quá hạn: ' : ''}${c.label}. ${c.hint}',
      index == 2 ? 'warning' : 'neutral',
    );
  }

  void _recordCampaignWorkers(GameState s) {
    if (!s.foodPressureEnabled) return;
    final workers = s.population!.deployments.fold<int>(
      0,
      (n, d) => n + d.troops,
    );
    s.population!.campaignWorkers = math.max(
      s.population!.campaignWorkers,
      workers,
    );
  }
}

part of 'game_engine.dart';

extension PopulationEngine on GameEngine {
  void _populationChange(GameState s, String label, int amount) {
    final p = s.population!;
    p.changes.update(label, (n) => n + amount, ifAbsent: () => amount);
  }

  void _food(GameState s, int amount, String title) {
    if (s.population == null) {
      s.grain += amount;
      return;
    }
    final next = (s.grain + amount).clamp(0, foodCapacity);
    final actual = next - s.grain;
    s.grain = next;
    _populationChange(s, '$title (tạ)', actual);
  }

  void _recruitPopulation(GameState s, int count, {double training = 20}) {
    final p = s.population!;
    final actual = math.min(count, p.recruitable);
    if (actual <= 0) return;
    p.setTrainingAt(
      'capital',
      (p.stationed('capital') * p.trainingAt('capital') + actual * training) /
          (p.stationed('capital') + actual),
    );
    p.soldiers += actual;
    p.garrisons['capital'] = p.stationed('capital') + actual;
    p.serviceSoldiers = math.max(p.serviceSoldiers, p.soldiers);
    p.productiveCivilians = math.min(p.productiveCivilians, p.civilians);
    _populationChange(s, 'Tuyển quân', actual);
  }

  /// Shared deaths remove the same people from the total and the appropriate
  /// workforce. A deployment is never duplicated into a second army.
  void _losePopulation(
    GameState s,
    int count,
    String cause, {
    bool soldiersOnly = false,
    bool civiliansOnly = false,
    bool displaced = false,
    String? sourceGarrison,
  }) {
    final p = s.population!;
    final actual = math.min(
      count,
      soldiersOnly
          ? p.availableSoldiers
          : civiliansOnly
          ? p.civilians
          : p.civilians + p.availableSoldiers,
    );
    if (actual <= 0) return;
    final armyLoss =
        soldiersOnly
            ? actual
            : civiliansOnly
            ? 0
            : math.max(
              actual - p.civilians,
              math.min(
                p.availableSoldiers,
                (actual * p.soldiers / math.max(1, p.population)).round(),
              ),
            );
    final beforeArmy = p.soldiers;
    p.population -= actual;
    p.soldiers -= armyLoss;
    if (sourceGarrison != null) {
      p.removeGarrisonTroops(armyLoss, source: sourceGarrison);
    } else if (armyLoss > 0) {
      final available = p.availableSoldiers + armyLoss;
      var remaining = armyLoss;
      for (final id in p.garrisons.keys.toList()) {
        final loss = math.min(
          p.availableAt(id),
          (armyLoss * p.availableAt(id) / math.max(1, available)).floor(),
        );
        p.garrisons[id] = p.stationed(id) - loss;
        remaining -= loss;
      }
      p.removeGarrisonTroops(remaining);
    }
    // Deployed contingents have their own frozen risk; do not charge the same
    // people twice or alter the advertised casualty denominator on reload.
    if (armyLoss > 0 && beforeArmy > 0) {
      p.equipment = math.max(
        0,
        p.equipment - (p.equipment * armyLoss / beforeArmy * .5).ceil(),
      );
    }
    if (displaced) p.displaced += actual - armyLoss;
    p.earlyWorkers = math.min(p.earlyWorkers, p.civilians);
    p.productiveCivilians = math.min(p.productiveCivilians, p.civilians);
    _populationChange(s, cause, -actual);
  }

  void _populationCommand(GameState s, String kind, String option) {
    final p = s.population;
    if (p == null) {
      throw const GameRuleException('Lượt cũ giữ bộ luật dân số cũ.');
    }
    if (kind == 'production') {
      if (!populationPolicies.containsKey(option) || option == p.nextPolicy) {
        throw const GameRuleException('Hãy chọn chính sách sản xuất khác.');
      }
      _spend(s, money(s, 0), title: 'Đổi ưu tiên sản xuất');
      p.nextPolicy = option;
      s.workThisWeek++;
      s.affairsThisWeek++;
      s.note(
        'Ưu tiên sản xuất',
        '${populationPolicies[option]}; có hiệu lực từ ${s.date(s.week + 1)}.',
      );
      return;
    }
    final blocked = populationActionBlocked(s, kind);
    if (blocked != null) throw GameRuleException(blocked);
    _spend(
      s,
      money(s, populationActionMoney(kind)),
      grain: populationActionFood(kind),
      title: populationActionNames[kind]!,
      detail: populationActionHint(s, kind),
    );
    s.workThisWeek++;
    s.affairsThisWeek++;
    switch (kind) {
      case 'public_health':
        p.diseaseLevel = math.max(0, p.diseaseLevel - 1);
        s.people++;
        s.actionCounts[kind] = 1;
      case 'demobilize':
        p.removeGarrisonTroops(5000);
        p.soldiers -= 5000;
        _populationChange(s, 'Giải ngũ', -5000);
      case 'reward_army':
        final uses = s.actionCounts[kind] ?? 0;
        p.changeMorale(8 / (uses + 1));
        s.actionCounts[kind] = uses + 1;
      case 'supply_army':
        p.foodCredit += populationActionFood(kind);
      default:
        final count = switch (kind) {
          'settle' || 'recruit' || 'equipment' => 5000,
          'return' => math.min(10000, p.displaced),
          _ => 10000,
        };
        if (kind == 'return') {
          p.displaced -= count; // reserve, never return twice
        }
        if (kind == 'refugees') {
          final petition =
              s.petitions
                  .where((x) => x.definitionId == 'population_refugees')
                  .first;
          s.petitions.remove(petition);
          s.factions['Văn thần'] = s.factions['Văn thần']! + 3;
          s.factions['Võ tướng'] = s.factions['Võ tướng']! - 5;
        }
        p.orders.add(
          PopulationOrder(
            kind: kind,
            title: populationActionNames[kind]!,
            count: count,
            due: s.week + (kind == 'settle' ? 1 : 0),
          ),
        );
    }
    s.note(populationActionNames[kind]!, populationActionHint(s, kind));
  }

  void _populationEmergency(GameState s, String kind, String officerId) {
    final p = s.population!;
    if (kind == 'early_labor') {
      if (s.week < p.earlyAvailable || p.earlyDebt > 0) {
        throw GameRuleException(
          'Có thể dùng lại từ ${s.date(p.earlyAvailable)} sau khi hết nghĩa vụ.',
        );
      }
      _spend(s, money(s, 0), title: 'Hạ tuổi lao động');
      final count = (p.population * .01).floor();
      p.population += count;
      p.earlyWorkers += count;
      p.earlyDebt += count;
      p.earlyInstallment = (count / 2).ceil();
      p.earlyDue = s.week + 1;
      p.earlyAvailable = s.week + 4;
      s.people -= 8;
      s.stability -= 5;
      _populationChange(s, 'Huy động lao động sớm', count);
      s.note(
        'Hạ tuổi lao động',
        '+${whole(count)} lao động dân sự; lòng dân −8, ổn định −5. '
            'Khấu trừ nguồn người hai mùa sau; sớm nhất dùng lại ${s.date(p.earlyAvailable)}.',
      );
    } else {
      if (p.recruitable < 10000) {
        throw const GameRuleException(
          'Cần đủ 10.000 lao động hợp lệ để mở đợt tuyển khẩn cấp.',
        );
      }
      if (s.obligations.any((o) => o.kind == 'levy')) {
        throw const GameRuleException('Đợt tuyển trước còn nghĩa vụ.');
      }
      if (officerId.isEmpty) {
        throw const GameRuleException(
          'Hãy chọn triều thần phụ trách tuyển quân.',
        );
      }
      final c = _person(s, officerId);
      if (c.isConsort || c.age < 18 || officerBusy(s, c.id)) {
        throw const GameRuleException(
          'Cần một triều thần trưởng thành đang rảnh.',
        );
      }
      final chance = actionSuccessChance(s, 'train', c);
      _spend(
        s,
        money(s, 15),
        grain: 1500,
        title: 'Tuyển quân khẩn cấp',
        detail:
            '${c.name}; tỷ lệ $chance%. Chi phí tổ chức cố định, không hoàn khi thất bại.',
      );
      final success = _next(s, 100) < chance;
      final count = emergencyRecruitmentCount(chance, success);
      _recruitPopulation(s, count, training: 10);
      _assignOfficer(
        s,
        c,
        success: success,
        meritTitle: 'Tuyển quân khẩn cấp',
        meritEventId: 'levy-${s.revision}',
      );
      s.people -= 4;
      s.obligations.add(
        Obligation(
          id: 'levy-${s.revision}',
          kind: 'levy',
          title: 'Ổn định đợt tuyển quân khẩn cấp',
          remaining: 2,
          nextWeek: s.week + 1,
        ),
      );
      s.note(
        'Tuyển quân khẩn cấp',
        '${c.name} · tỷ lệ đã chốt $chance% · '
            '${success ? 'thành công' : 'thất bại'}: nhận ${whole(count)} quân. '
            'Đã chi ${money(s, 15)} ${moneyUnit(s)} và 1.500 tạ; lòng dân −4. Không tăng tổng dân số.',
        success ? 'gold' : 'warning',
      );
      _respond(s, 'border');
    }
    s.workThisWeek++;
    s.affairsThisWeek++;
  }

  bool _populationEffect(GameState s, String key, int value, String title) {
    final p = s.population;
    if (p == null) return false;
    switch (key) {
      case 'food':
        _food(s, value, title);
      case 'training':
        p.changeTraining(value.toDouble());
      case 'equipment':
        p.equipment += value;
      case 'morale':
        p.changeMorale(value.toDouble());
      case 'logistics':
        p.logistics += value;
      case 'population':
        if (value >= 0) {
          p.population += value;
          _populationChange(s, title, value);
        } else {
          _losePopulation(s, -value, title, civiliansOnly: true);
        }
      case 'settlers':
      case 'refugees':
        p.orders.add(
          PopulationOrder(kind: key, title: title, count: value, due: s.week),
        );
      case 'returnees':
        final actual = math.min(value, p.displaced);
        p.displaced -= actual;
        p.orders.add(
          PopulationOrder(
            kind: 'return',
            title: title,
            count: actual,
            due: s.week,
          ),
        );
      case 'troops':
        if (value > 0) {
          _recruitPopulation(s, value);
        } else {
          _losePopulation(s, -value, title, soldiersOnly: true);
        }
      case 'displaced':
        _losePopulation(s, value, title, civiliansOnly: true, displaced: true);
      case 'disease':
        p.diseaseLevel = (p.diseaseLevel + value).clamp(0, 3);
      default:
        return false;
    }
    return true;
  }

  void _populationLaborSample(GameState s) {
    final p = s.population!;
    p.productiveCivilians = math.min(p.productiveCivilians, p.civilians);
    p.yearlyFarmLabor += farmLaborFactor(s);
    p.yearlyEconomicLabor += economicLaborFactor(s);
    p.yearlyLaborSamples++;
  }

  void _populationSeason(GameState s) {
    final p = s.population!;
    final before = _outcomeStats(s);
    // Population arrivals below contribute to production starting next season.
    final made = manufacturedEquipment(s);
    final wear = (p.equipment * (s.war > 0 ? .03 : .01)).ceil();
    p.equipment = math.max(0, p.equipment + made - wear);
    _populationChange(s, 'Sản xuất quân khí (bộ)', made);
    _populationChange(s, 'Hao mòn quân khí (bộ)', -wear);
    p.changeMorale(((s.people - 50) / 10).clamp(-3, 3));
    if (p.wageCoverage < 100) p.changeMorale(-(100 - p.wageCoverage) / 10);
    final base = p.openingPopulation;
    final growth = base * populationGrowthRate(s) + p.growthRemainder;
    var additions = growth.floor();
    final grossAdditions = additions;
    p.growthRemainder = growth - additions;
    if (p.earlyDebt > 0 && s.week >= p.earlyDue) {
      final deduction = math.min(
        additions,
        math.min(p.earlyInstallment, p.earlyDebt),
      );
      additions -= deduction;
      p.earlyDebt -= deduction;
      p.earlyWorkers = math.max(0, p.earlyWorkers - deduction);
      _populationChange(s, 'Khấu trừ huy động sớm', -deduction);
    }
    final aging = base * .0025 + p.agingRemainder;
    final old = aging.floor();
    p.agingRemainder = aging - old;
    final disease = base * diseaseRate(s) + p.diseaseRemainder;
    final sick = disease.floor();
    p.diseaseRemainder = disease - sick;
    _losePopulation(s, old, 'Rời lực lượng vì tuổi già');
    _losePopulation(s, sick, 'Bệnh tật');
    p.population += additions;
    _populationChange(s, 'Người mới tới tuổi lao động', grossAdditions);
    if (foodDays(s) < 30) {
      _losePopulation(
        s,
        (p.civilians * .002).floor(),
        'Bỏ xứ vì thiếu lương',
        civiliansOnly: true,
        displaced: true,
      );
      s.people -= 2;
    }
    for (final d in p.deployments.where((d) => d.due <= s.week).toList()) {
      p.deployments.remove(d);
      final leader =
          s.court.where((c) => c.id == d.officerId && c.available).firstOrNull;
      final deputyPresent =
          d.deputyId.isEmpty ||
          s.court.any((c) => c.id == d.deputyId && c.available);
      final success =
          d.succeeded &&
          (d.officerId.isEmpty || leader != null) &&
          deputyPresent;
      _losePopulation(
        s,
        d.losses,
        'Tử trận: ${d.title}',
        soldiersOnly: true,
        sourceGarrison: d.sourceGarrison,
      );
      if (d.missionId.isNotEmpty && s.warfare != null) {
        _warDeploymentResult(s, d, leader != null && deputyPresent);
        final mission =
            s.warfare!.missions.where((m) => m.id == d.missionId).firstOrNull;
        p.changeMorale(
          mission?.status == 'success' ? 3 : -6,
          at: d.sourceGarrison,
        );
        continue;
      }
      _apply(
        s,
        success ? d.effects : d.failureEffects,
        title: 'Quân báo: ${d.title}',
        category: 'outcome',
      );
      final major = s.major;
      if (major != null && d.majorId == major.id) {
        final goal = major.objectives.firstWhere(
          (o) => o.key == d.objectiveKey,
        );
        if (!success) {
          goal.done = false;
          goal.delivered = 50;
        }
        if (major.stage >= major.objectives.length) _resolveMajor(s);
      }
      p.changeMorale(success ? 3 : -6, at: d.sourceGarrison);
      s.note(
        'Quân báo: ${d.title}',
        '${whole(d.troops)} quân tham gia, '
            'tổn thất ${whole(d.losses)}, ${whole(d.troops - d.losses)} trở về. '
            '${success ? 'Hoàn thành nhiệm vụ' : 'Nhiệm vụ thất bại hoặc gián đoạn'}; tỷ lệ đã chốt ${d.chance}%.',
        success ? 'gold' : 'danger',
      );
    }
    for (final o in p.orders.where((o) => o.due <= s.week).toList()) {
      p.orders.remove(o);
      var received = o.count;
      if (o.kind == 'recruit') {
        received = math.min(o.count, p.recruitable);
        _recruitPopulation(s, received);
      } else if (o.kind == 'equipment') {
        p.equipment += received;
      } else {
        p.population += received;
        _populationChange(s, o.title, received);
      }
      s.note(
        'Kết quả: ${o.title}',
        'Đã nhận ${whole(received)} '
            '${o.kind == 'equipment'
                ? 'bộ quân khí'
                : o.kind == 'recruit'
                ? 'tân binh'
                : 'lao động dân sự'}.',
        'gold',
      );
    }
    if (s.season == 'Thu') {
      p.yearlyFarmLabor = p.yearlyEconomicLabor = 0;
      p.yearlyLaborSamples = 0;
    }
    p.reports.add({
      'week': s.week,
      'population': p.population,
      'soldiers': p.soldiers,
      'food': s.grain,
      'changes': Map.of(p.changes),
    });
    _recordOutcome(
      s,
      before,
      'Dân cư và quân đội cuối mùa',
      'success',
      detail: p.changes.entries
          .map((e) => '${e.key}: ${e.value >= 0 ? '+' : ''}${whole(e.value)}')
          .join('\n'),
    );
  }

  void _populationNewSeason(GameState s) {
    final p = s.population!;
    p.policy = p.nextPolicy;
    p.openingPopulation = p.population;
    p.serviceSoldiers = p.soldiers;
    p.productiveCivilians = p.civilians;
    p.foodCredit = 0;
    p.wageCoverage = 100;
    p.changes = {};
  }

  void _populationFoodSeason(GameState s) {
    final p = s.population!;
    final need = remainingFoodConsumption(s);
    final available = math.min(s.grain, need);
    final coverage = need == 0 ? 100.0 : available * 100 / need;
    p.logistics = .6 * coverage + .4 * p.wageCoverage;
    if (coverage < 100) p.changeMorale(-(100 - coverage) / 10);
    _food(s, -available, 'Tiêu dùng dân sự và quân đội');
    if (available < need) {
      _losePopulation(
        s,
        (p.population * (1 - coverage / 100) * .005).ceil(),
        'Thiếu khẩu phần',
      );
      s.note(
        'Thiếu khẩu phần',
        'Cần ${whole(need)} tạ, cấp được ${whole(available)} tạ. '
            'Hậu cần ${p.logistics.toStringAsFixed(1)}/100; dân số và sĩ khí bị ảnh hưởng.',
        'danger',
      );
    }
  }

  void _deployChoice(
    GameState s,
    EventDefinition e,
    EventChoice c,
    String personId,
  ) {
    final p = s.population!;
    if (c.troops > p.availableSoldiers) {
      throw GameRuleException(
        'Cần ${whole(c.troops)} quân rảnh; hiện có ${whole(p.availableSoldiers)}.',
      );
    }
    Courtier? leader;
    if (personId.isNotEmpty) {
      leader = _person(s, personId);
      final reason = petitionAssigneeBlocked(s, leader);
      if (reason != null || leader.isConsort) {
        throw GameRuleException(
          reason ?? 'Nhiệm vụ quân sự cần triều thần phụ trách.',
        );
      }
    }
    final chance = petitionChance(s, e, c, leader);
    final success = _next(s, 100) < chance;
    final (low, high) =
        !success
            ? (50, 70)
            : c.combat == 'large'
            ? (20, 50)
            : (1, 20);
    final percent = low + _next(s, high - low + 1);
    final losses = (c.troops * percent / 100).ceil();
    if (leader != null) _assignOfficer(s, leader);
    // Thirty days of expedition food is prepaid in grainCost. Credit only the
    // ordinary 1.5-cân ration; the expedition premium remains a real cost.
    p.foodCredit += foodAmount(c.troops * 30 * 1.5 / 100);
    p.deployments.add(
      ArmyDeployment(
        id: '${s.runId}-${s.revision}-${e.id}',
        title: e.title,
        troops: c.troops,
        losses: losses,
        due: s.week,
        officerId: leader?.id ?? '',
        chance: chance,
        succeeded: success,
        majorId: e.id.startsWith('major:') ? s.major?.id ?? '' : '',
        objectiveKey:
            e.id.startsWith('major:') && s.major != null
                ? majorDefinition(s.major!.kind).objectives[s.major!.stage].key
                : '',
        effects: e.id.startsWith('major:') ? c.effects : c.laterEffects,
        failureEffects: c.laterFailureEffects,
      ),
    );
    s.note(
      'Điều quân: ${e.title}',
      '${whole(c.troops)} quân làm nhiệm vụ trong mùa này; '
          'không thể điều động trùng. ${c.combat == 'large' ? 'Giao tranh lớn: 20–50%' : 'Giao tranh nhỏ: 1–20%'}; '
          'thất bại nặng 50–70% tổn thất trên quân được cử.',
    );
  }
}

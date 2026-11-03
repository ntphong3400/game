part of 'game_engine.dart';

extension WarfareEngine on GameEngine {
  NeighborState _warCountry(GameState s, String id) {
    final n = s.warfare?.neighbors.where((n) => n.id == id).firstOrNull;
    if (n == null) throw const GameRuleException('Không có quốc gia này.');
    return n;
  }

  void _warBegin(GameState s, NeighborState n, {bool initialMissions = true}) {
    if (s.warfare!.active != null && s.warfare!.active != n) {
      throw const GameRuleException(
        'Chỉ tham chiến với một nước tại một thời điểm.',
      );
    }
    if (n.status == 'treaty' || n.cooldownUntil > s.week) {
      throw const GameRuleException(
        'Đang có hòa ước hoặc thời gian bảo hộ hòa bình.',
      );
    }
    if (n.status == 'war') return;
    n.status = 'war';
    n.warStarted = s.week;
    n.nextMission = s.week + 1;
    n.relation = (n.relation - 20).clamp(-100, 100);
    n.capitalWarned = false;
    s.war = math.max(1, s.war);
    s.siege = 0;
    s.note(
      'Chiến tranh với ${n.name}',
      'Ưu thế ban đầu ${n.advantage}. Chọn nhiệm vụ, quân và tướng tại Quân sự. Chiến thắng dẫn tới hòa ước triều cống, không sáp nhập quốc gia.',
      'danger',
    );
    if (initialMissions) {
      _warOpenMission(s, n, 'defend');
      _warOpenMission(s, n, 'scout');
    }
  }

  void _warSync(GameState s) {
    final w = s.warfare;
    if (w == null) return;
    if (w.active != null) {
      s.war = math.max(1, s.war);
      return;
    }
    if (s.war > 0) {
      final candidates =
          w.neighbors
              .where((n) => n.status != 'treaty' && n.cooldownUntil <= s.week)
              .toList()
            ..sort((a, b) => a.relation.compareTo(b.relation));
      if (candidates.isNotEmpty) {
        _warBegin(s, candidates.first);
      } else {
        s.war = 0;
      }
    }
  }

  WarMission? _warOpenMission(
    GameState s,
    NeighborState n,
    String kind, {
    String? title,
  }) {
    if (s.hasCourtSystem && kind == 'naval') kind = 'battle';
    final w = s.warfare!;
    final count = frontierMissionSize(s, n, kind);
    if (count <= 0) return null;
    final m = WarMission(
      id: 'war-${++w.sequence}',
      countryId: n.id,
      kind: kind,
      title: title ?? warMissionNames[kind]!,
      enemyTroops: count,
      opened: s.week,
      deadline: s.week + (kind == 'capital' ? 1 : 2),
      naval: kind == 'naval',
    );
    w.missions.add(m);
    s.note(
      'Quân tình: ${m.title}',
      '${n.name}: ${whole(count)} quân địch. Hạn nhận cuối ${s.date(m.deadline)}. ${kind == 'capital' ? 'Kinh thành lâm nguy: cầu hòa hoặc tổ chức phòng thủ; bỏ mặc sẽ mất nước.' : 'Xem Quân sự để chọn đối sách và điều quân.'}',
      kind == 'capital' ? 'danger' : 'warning',
    );
    return m;
  }

  void _warCommand(GameState s, GameCommand command) {
    if (s.warfare == null || s.population == null) {
      throw const GameRuleException('Lượt này giữ cơ chế chiến tranh cũ.');
    }
    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(command.option));
    } catch (_) {
      throw const GameRuleException('Lệnh chiến tranh không hợp lệ.');
    }
    final action = data['action'];
    if (['deploy', 'decline', 'intervene', 'withdraw'].contains(action)) {
      final m =
          s.warfare!.missions.where((m) => m.id == command.target).firstOrNull;
      if (m == null) throw const GameRuleException('Nhiệm vụ không tồn tại.');
      if (action == 'deploy') {
        final ratio = (data['ratio'] as num?)?.toDouble() ?? 0;
        final leader =
            s.court.where((c) => c.id == command.assigneeId).firstOrNull;
        final deputyId = data['deputy'] as String? ?? '';
        final deputy = s.court.where((c) => c.id == deputyId).firstOrNull;
        if (deputyId.isNotEmpty && deputy == null) {
          throw const GameRuleException('Phó tướng không còn trong triều.');
        }
        final tactic = data['tactic'] as String? ?? 'balanced';
        if (!warTactics.containsKey(tactic)) {
          throw const GameRuleException('Đối sách không hợp lệ.');
        }
        final blocked = warDeployBlocked(s, m, ratio, leader, deputy);
        if (blocked != null) throw GameRuleException(blocked);
        final troops = warTroops(m, ratio);
        final quote = WarPreview(s, m, troops, leader!, deputy, tactic: tactic);
        _spend(
          s,
          quote.cost,
          grain: quote.food,
          title: 'Xuất quân: ${m.title}',
          detail:
              '${whole(troops)} quân; ${leader.name}; cơ hội thắng ${quote.winChance.toStringAsFixed(1)}%.',
        );
        final retreat = _next(s, 100) < quote.withdrawal;
        final won = !retreat && _next(s, 100) < quote.tacticalChance;
        final reduction =
            retreat
                ? 10 + _next(s, 16)
                : won
                ? 50 + _next(s, 26)
                : 0;
        final losses = battleLosses(
          troops,
          quote.base,
          won: won,
          retreated: retreat,
          reduction: reduction,
        );
        m.status = 'deployed';
        m.troops = troops;
        m.officerId = leader.id;
        m.deputyId = deputyId;
        m.tactic = tactic;
        m.due = s.week + m.duration - 1;
        _assignOfficer(s, leader);
        if (deputy != null) _assignOfficer(s, deputy);
        _prepayFood(
          s,
          warFoodCredit(troops, s),
          'Khẩu phần xuất quân: ${m.title}',
        );
        s.population!.deployments.add(
          ArmyDeployment(
            id: m.id,
            title: m.title,
            troops: troops,
            losses: losses,
            due: m.due,
            officerId: leader.id,
            deputyId: deputyId,
            chance: quote.winChance.round(),
            succeeded: won,
            countryId: m.countryId,
            sourceGarrison: missionGarrison(m),
            missionId: m.id,
            retreated: retreat,
            baseCasualty: quote.base,
            reduction: reduction,
          ),
        );
        s.workThisWeek++;
        s.affairsThisWeek++;
        _respond(s, 'border');
        _recordCampaignWorkers(s);
        s.note(
          'Điều quân: ${m.title}',
          '${whole(troops)} quân, chủ tướng ${leader.name}${deputy == null ? '' : ', phó tướng ${deputy.name}'}. Cơ hội thắng ${quote.winChance.toStringAsFixed(1)}%; nguy cơ bỏ nhiệm vụ ${quote.withdrawal}%. Trở về cuối ${s.date(m.due)}. Còn ${whole(s.population!.availableSoldiers)} quân có thể điều động.',
        );
      } else if (action == 'decline') {
        if (m.status != 'open') {
          throw const GameRuleException('Nhiệm vụ đã đóng.');
        }
        _spend(s, 0, title: 'Rút bỏ mục tiêu: ${m.title}');
        _warFailedMission(s, m, 'Chủ động bỏ mục tiêu');
        s.workThisWeek++;
        s.affairsThisWeek++;
      } else if (action == 'intervene') {
        if (!m.intervention || m.status != 'deployed') {
          throw const GameRuleException('Không có yêu cầu tiếp tế đang chờ.');
        }
        _spend(
          s,
          money(s, 10),
          grain: warMissionFood(m.troops, s, m),
          title: 'Tiếp tế: ${m.title}',
        );
        _prepayFood(
          s,
          warFoodCredit(m.troops, s),
          'Khẩu phần tiếp tế: ${m.title}',
        );
        m.intervention = false;
        m.relief = 1;
        s.workThisWeek++;
        s.affairsThisWeek++;
      } else {
        if (m.status != 'deployed') {
          throw const GameRuleException('Đạo quân không còn làm nhiệm vụ.');
        }
        _spend(s, 0, title: 'Lệnh rút quân: ${m.title}');
        m.status = 'returning';
        m.intervention = false;
        _warRecall(s, m, combatRetreat: true);
        final n = _warCountry(s, m.countryId);
        n.advantage = (n.advantage - m.advantageValue).clamp(-100, 100);
        if (m.kind == 'capital') {
          _finish(
            s,
            'Chủ động rút bỏ lực lượng bảo vệ kinh thành; quốc gia thất thủ trước quân ${n.name}.',
            kind: 'invasion',
          );
        }
        s.authority -= 2;
        s.workThisWeek++;
        s.affairsThisWeek++;
        s.note(
          'Rút quân',
          'Bỏ mục tiêu ${m.title}, kinh phí không hoàn. Quân sống sót trở về cuối ${s.date(m.due)}.',
          'warning',
        );
      }
      return;
    }
    final n = _warCountry(s, command.target);
    if (action == 'declare') {
      if (s.warfare!.active != null ||
          n.status == 'treaty' ||
          n.cooldownUntil > s.week) {
        throw const GameRuleException('Chưa thể mở cuộc chiến này.');
      }
      _spend(s, 0, title: 'Tuyên chiến với ${n.name}');
      s.workThisWeek++;
      s.affairsThisWeek++;
      _warBegin(s, n);
    } else if (action == 'oldPay') {
      if (n.oldPayable <= 0) {
        throw const GameRuleException('Không có nợ cống từ hòa ước cũ.');
      }
      _spend(s, n.oldPayable, title: 'Trả nợ hòa ước cũ ${n.name}');
      n.oldPayable = 0;
      s.workThisWeek++;
      s.affairsThisWeek++;
    } else if (action == 'oldCollect') {
      if (n.oldReceivable <= 0) {
        throw const GameRuleException('Không có khoản cống cũ để đòi.');
      }
      _spend(s, money(s, 5), title: 'Đòi cống hòa ước cũ ${n.name}');
      if (_next(s, 100) < 70) {
        _postMoney(
          s,
          n.oldReceivable,
          title: 'Thu cống hòa ước cũ ${n.name}',
          detail: 'Thu khoản còn thiếu được bảo lưu.',
          category: 'tribute',
        );
        n.oldReceivable = 0;
      }
      s.workThisWeek++;
      s.affairsThisWeek++;
    } else if (action == 'envoy') {
      if (n.status == 'war') {
        throw const GameRuleException('Hãy dùng hòa đàm khi đang chiến tranh.');
      }
      _spend(s, money(s, 10), title: 'Giao hảo với ${n.name}');
      n.relation = (n.relation + 12).clamp(-100, 100);
      s.workThisWeek++;
      s.affairsThisWeek++;
    } else if (action == 'negotiate') {
      if (n.status != 'war') {
        throw const GameRuleException('Không có chiến tranh để hòa đàm.');
      }
      final tier = data['tier'] as String? ?? '';
      final surrender = data['surrender'] == true;
      if (!tributeNames.containsKey(tier)) {
        throw const GameRuleException('Điều khoản không hợp lệ.');
      }
      if (surrender && tier == 'armistice') {
        throw const GameRuleException('Cầu hòa phải có điều khoản triều cống.');
      }
      final required =
          n.advantage <= -70
              ? 'heavy'
              : n.advantage <= -30
              ? 'medium'
              : 'light';
      if (surrender && tributeGold(tier) < tributeGold(required)) {
        throw const GameRuleException(
          'Đối phương yêu cầu mức cống cao hơn ở tình thế hiện tại.',
        );
      }
      final chance = surrender ? 100 : treatyDemandChance(n, tier);
      if (chance == 0) {
        throw const GameRuleException(
          'Ưu thế chưa đủ để yêu cầu điều khoản này.',
        );
      }
      _spend(s, money(s, surrender ? 20 : 10), title: 'Hòa đàm với ${n.name}');
      s.workThisWeek++;
      s.affairsThisWeek++;
      if (_next(s, 100) < chance) {
        _warSignTreaty(s, n, tier, receiving: !surrender);
      } else {
        n.relation = (n.relation - 3).clamp(-100, 100);
        s.note(
          'Hòa đàm chưa thành',
          '${n.name} từ chối điều khoản ${tributeNames[tier]}; chiến tranh tiếp diễn. Phí sứ đoàn không hoàn lại.',
          'warning',
        );
      }
    } else if ([
      'pay',
      'extend',
      'refuse',
      'forgive',
      'pressure',
    ].contains(action)) {
      final t = n.treaty;
      if (t == null || t.arrears <= 0) {
        throw const GameRuleException('Không có khoản cống còn thiếu.');
      }
      if (action == 'pay') {
        if (t.receiving) {
          throw const GameRuleException('Đối phương đang nợ cống.');
        }
        _spend(s, t.arrears, title: 'Trả bù triều cống ${n.name}');
        t.arrears = 0;
        t.graceUntil = 0;
      } else if (action == 'extend') {
        if (t.broken || t.extensions >= 1) {
          throw const GameRuleException(
            'Chỉ gia hạn một lần trước khi hòa ước bị phá.',
          );
        }
        _spend(s, 0, title: 'Gia hạn triều cống ${n.name}');
        t.extensions++;
        t.graceUntil = s.week + 1;
        n.relation = (n.relation - (t.receiving ? 0 : 5)).clamp(-100, 100);
      } else if (action == 'forgive') {
        if (!t.receiving) {
          throw const GameRuleException(
            'Chỉ miễn khoản cống đối phương đang nợ.',
          );
        }
        _spend(s, 0, title: 'Miễn khoản cống còn thiếu ${n.name}');
        t.arrears = 0;
        n.relation = (n.relation + 10).clamp(-100, 100);
      } else if (action == 'pressure') {
        if (!t.receiving) {
          throw const GameRuleException('Chỉ gây sức ép đòi cống đối phương.');
        }
        _spend(s, money(s, 5), title: 'Đòi cống ${n.name}');
        if (_next(s, 100) < 70) {
          _postMoney(
            s,
            t.arrears,
            title: 'Thu cống còn thiếu ${n.name}',
            detail: 'Thu đúng một lần khoản còn thiếu.',
            category: 'tribute',
          );
          t.arrears = 0;
        } else {
          n.relation = (n.relation - 15).clamp(-100, 100);
          s.note(
            'Đòi cống chưa thành',
            '${n.name} chưa chịu trả khoản còn thiếu.',
            'warning',
          );
        }
      } else {
        if (t.receiving) {
          throw const GameRuleException(
            'Không thể khước từ khoản cống được nhận.',
          );
        }
        _spend(s, 0, title: 'Khước từ triều cống ${n.name}');
        _warBreakTreaty(s, n);
      }
      s.workThisWeek++;
      s.affairsThisWeek++;
      _warTreatyExpiry(s, n);
    } else {
      throw const GameRuleException('Lệnh chiến tranh không hợp lệ.');
    }
  }

  void _warRecall(GameState s, WarMission m, {bool combatRetreat = false}) {
    final index = s.population!.deployments.indexWhere(
      (d) => d.missionId == m.id,
    );
    if (index < 0) return;
    final d = s.population!.deployments[index];
    final j = d.toJson();
    j['losses'] =
        combatRetreat
            ? battleLosses(
              d.troops,
              d.baseCasualty,
              won: false,
              retreated: true,
              reduction: 10 + _next(s, 16),
            )
            : 0;
    j['succeeded'] = false;
    j['retreated'] = combatRetreat;
    s.population!.deployments[index] = ArmyDeployment.fromJson(j);
  }

  void _warSignTreaty(
    GameState s,
    NeighborState n,
    String tier, {
    required bool receiving,
  }) {
    final previous = n.treaty;
    if (previous != null && previous.arrears > 0) {
      if (previous.receiving) {
        n.oldReceivable += previous.arrears;
      } else {
        n.oldPayable += previous.arrears;
      }
    }
    n.status = 'treaty';
    n.capitalWarned = false;
    n.treaty = TributeTreaty(
      tier: tier,
      receiving: receiving,
      annualGold: tributeGold(tier),
      signed: s.week,
      installments: tributeYears(tier),
    );
    for (final m in s.warfare!.missions.where(
      (m) => m.countryId == n.id && ['open', 'deployed'].contains(m.status),
    )) {
      if (m.status == 'deployed') {
        m.status = 'returning';
        m.intervention = false;
        _warRecall(s, m);
      } else {
        m.status = 'cancelled';
        _warMajorResult(s, m, false);
      }
    }
    s.war = 0;
    s.siege = 0;
    _respond(s, 'border');
    s.authority +=
        receiving && tier != 'armistice'
            ? 4
            : tier == 'armistice'
            ? 0
            : -3;
    s.note(
      'Hòa ước với ${n.name}',
      tier == 'armistice'
          ? 'Đình chiến trong 4 mùa, không triều cống.'
          : '${receiving ? 'Nhận' : 'Nộp'} ${whole(tributeGold(tier))} lượng vàng/năm × ${tributeYears(tier)} năm. Kỳ đầu cuối ${s.date(s.week + 4)}. Không thay đổi lãnh thổ.',
      receiving ? 'gold' : 'warning',
    );
  }

  void _warBreakTreaty(GameState s, NeighborState n) {
    n.treaty!.broken = true;
    n.status = 'tension';
    n.relation = (n.relation - 25).clamp(-100, 100);
    n.cooldownUntil = s.week + 1;
    n.defenseGraceThrough = n.cooldownUntil;
    s.note(
      'Hòa ước bị phá: ${n.name}',
      'Khoản cống còn thiếu vẫn tồn tại. Đối phương gửi tối hậu thư; nguy cơ tái chiến từ mùa sau.',
      'danger',
    );
  }

  void _warTreatyExpiry(GameState s, NeighborState n) {
    final t = n.treaty;
    if (t == null || t.broken || n.status != 'treaty') return;
    if (t.tier == 'armistice'
        ? s.week >= t.signed + 4
        : t.paidInstallments >= t.installments) {
      n.status = 'peace';
      n.cooldownUntil = s.week + 4;
      n.defenseGraceThrough = n.cooldownUntil;
      s.note(
        'Hết hòa ước: ${n.name}',
        'Đã hết thời hạn hòa ước. Không phát sinh kỳ cống mới; khoản còn thiếu ${whole(t.arrears)} lượng vàng vẫn được bảo lưu. Bảo hộ hòa bình thêm 4 mùa, đến ${s.date(n.cooldownUntil)}.',
      );
    }
  }

  void _warPrepareBudget(GameState s) {
    for (final n in s.warfare?.neighbors ?? <NeighborState>[]) {
      if (tributeDue(s, n) && n.treaty!.receiving) {
        n.treaty!.incomingWithheld = n.relation < -50 && _next(s, 100) < 20;
      }
    }
  }

  void _warSettleTribute(GameState s) {
    for (final n in s.warfare?.neighbors ?? <NeighborState>[]) {
      if (!tributeDue(s, n)) continue;
      final t = n.treaty!;
      var received = t.receiving ? (t.incomingWithheld ? 0 : t.annualGold) : 0;
      if (!t.receiving) {
        // Annual tribute uses a separate arrears balance: ordinary debt must
        // never collect this amount again behind the diplomacy screen.
        received = math.min(s.treasury, t.annualGold);
        _postMoney(
          s,
          -received,
          title: 'Triều cống ${n.name}',
          detail:
              'Kỳ ${t.paidInstallments + 1}/${t.installments}; thiếu được ghi riêng trong hòa ước.',
          category: 'tribute',
          requiredAmount: t.annualGold,
        );
        s.lastExpense += received;
      }
      t.paidInstallments++;
      final missing = t.annualGold - received;
      if (missing > 0) {
        t.arrears += missing;
        t.graceUntil = s.week + 1;
        s.note(
          'Thiếu triều cống: ${n.name}',
          '${t.receiving ? 'Đối phương' : 'Quốc gia'} còn thiếu ${whole(t.arrears)} lượng vàng. Hạn trả bù cuối ${s.date(t.graceUntil)}; xử lý tại Quân sự.',
          'warning',
        );
      }
      t.incomingWithheld = false;
      _warTreatyExpiry(s, n);
    }
  }

  void _warMajorResult(GameState s, WarMission m, bool won) {
    if (m.majorId.isEmpty || s.major?.id != m.majorId) return;
    final major = s.major!;
    final goal =
        major.objectives.where((o) => o.key == m.objectiveKey).firstOrNull;
    if (goal != null) {
      goal.done = won;
      goal.delivered = won ? 100 : 50;
      goal.officerId = '';
      goal.finishWeek = 0;
    }
    if (major.stage >= major.objectives.length) _resolveMajor(s);
  }

  void _warFailedMission(GameState s, WarMission m, String reason) {
    final n = _warCountry(s, m.countryId);
    m.status = 'failed';
    n.advantage = (n.advantage - m.advantageValue).clamp(-100, 100);
    s.authority -= 2;
    if (m.kind == 'supply') s.population!.logistics -= 8;
    _warMajorResult(s, m, false);
    s.note(
      'Thất bại: ${m.title}',
      '$reason. Ưu thế −${m.advantageValue}, còn ${n.advantage}.',
      'danger',
    );
    if (m.kind == 'capital' && n.status == 'war') {
      _finish(
        s,
        'Không giữ được kinh thành trong chiến tranh với ${n.name}. Quốc gia mất quyền tự chủ.',
        kind: 'invasion',
      );
    }
  }

  void _warDeploymentResult(GameState s, ArmyDeployment d, bool leaderPresent) {
    final w = s.warfare!;
    final m = w.missions.where((m) => m.id == d.missionId).firstOrNull;
    if (m == null) return;
    final n = _warCountry(s, m.countryId);
    final recalled = m.status == 'returning';
    final missingSupply = m.intervention && m.relief != 1;
    final success =
        d.succeeded &&
        leaderPresent &&
        !recalled &&
        (!m.intervention || m.relief == 1);
    final result =
        recalled
            ? 'recalled'
            : !leaderPresent
            ? 'interrupted'
            : d.retreated
            ? 'retreated'
            : success
            ? 'success'
            : 'failure';
    m.status =
        success
            ? 'success'
            : recalled
            ? 'returned'
            : 'failed';
    m.intervention = false;
    if (!recalled && n.status == 'war') {
      n.advantage = (n.advantage +
              (success ? m.advantageValue : -m.advantageValue))
          .clamp(-100, 100);
      if (success && m.kind == 'scout') {
        n.enemyQuality = math.max(35, n.enemyQuality - 3);
      }
      if (success && m.kind == 'raid') {
        n.enemyQuality = math.max(35, n.enemyQuality - 5);
      }
      if (m.kind == 'supply') s.population!.logistics += success ? 8 : -8;
      s.authority += success ? 2 : -2;
      if (success) {
        for (final c in s.court.where(
          (c) => c.id == d.officerId || c.id == d.deputyId,
        )) {
          final major = ['siege', 'capital'].contains(m.kind);
          _merit(
            s,
            c,
            points:
                major
                    ? 3
                    : ['battle', 'relieve'].contains(m.kind)
                    ? 2
                    : 1,
            major: major,
            title: m.title,
            eventId: 'war-${m.id}',
          );
        }
      }
    }
    if (!recalled) {
      _apply(
        s,
        {
          for (final e
              in (success ? m.successEffects : m.failureEffects).entries)
            if (!['war', 'peace', 'warMission'].contains(e.key)) e.key: e.value,
        },
        title: m.title,
        category: 'outcome',
      );
    }
    _warMajorResult(s, m, success);
    final reason =
        recalled
            ? 'Đã rút về theo lệnh/hòa ước'
            : !leaderPresent
            ? 'Chỉ huy không còn đủ điều kiện; nhiệm vụ gián đoạn'
            : d.retreated
            ? 'Thất bại do chủ tướng tự ý rút quân'
            : missingSupply
            ? 'Thất bại do không được tiếp tế'
            : success
            ? 'Chiến thắng'
            : 'Thất bại khi giao chiến';
    final engaged =
        !recalled &&
        leaderPresent &&
        !d.retreated &&
        !missingSupply &&
        !['scout', 'supply'].contains(m.kind) &&
        n.status == 'war';
    final enemyLosses =
        engaged
            ? math.min(
              n.enemyTroops,
              (m.enemyTroops * (success ? .25 : .10)).ceil(),
            )
            : 0;
    n.enemyTroops -= enemyLosses;
    final detail =
        '$reason. ${whole(d.troops)} quân tham chiến; tổn thất ${whole(d.losses)}, ${whole(d.troops - d.losses)} trở về ${garrisonNames[d.sourceGarrison]}. Địch mất ${whole(enemyLosses)} quân, còn ${whole(n.enemyTroops)} tại mặt trận. Ưu thế ${n.advantage}.';
    w.reports.insert(0, {
      'week': s.week,
      'missionId': m.id,
      'countryId': n.id,
      'title': m.title,
      'result': result,
      'troops': d.troops,
      'losses': d.losses,
      'returned': d.troops - d.losses,
      'enemyLosses': enemyLosses,
      'sourceGarrison': d.sourceGarrison,
      'chance': d.chance,
      'baseCasualty': d.baseCasualty,
      'reduction': d.reduction,
      'detail': detail,
    });
    s.note('Quân báo: ${m.title}', detail, success ? 'gold' : 'warning');
    if (m.kind == 'capital' && n.status == 'war' && !recalled) {
      if (!success) {
        _finish(
          s,
          'Kinh thành thất thủ trước quân ${n.name}. Quốc gia mất nước sau trận phòng thủ cuối cùng.',
          kind: 'invasion',
        );
      } else {
        n.advantage = math.max(-40, n.advantage);
        n.capitalWarned = false;
      }
    }
  }

  void _warSeason(GameState s) {
    final w = s.warfare;
    if (w == null || s.ended) return;
    _warSync(s);
    for (final n in w.neighbors) {
      final t = n.treaty;
      if (['treaty', 'peace'].contains(n.status) &&
          t != null &&
          !t.broken &&
          t.arrears > 0 &&
          t.graceUntil <= s.week) {
        if (!t.receiving) {
          _warBreakTreaty(s, n);
        } else if (t.graceUntil > 0) {
          n.relation = (n.relation - 10).clamp(-100, 100);
          t.graceUntil = 0;
          s.note(
            'Đối phương chậm cống',
            '${n.name} quá hạn trả bù; có thể gia hạn, miễn khoản thiếu hoặc gây sức ép.',
            'warning',
          );
        }
      }
      _warTreatyExpiry(s, n);
    }
    for (final m
        in w.missions
            .where((m) => m.status == 'open' && m.deadline <= s.week)
            .toList()) {
      _warFailedMission(s, m, 'Quá hạn không điều quân');
      if (s.ended) return;
    }
    for (final m in w.missions.where(
      (m) =>
          m.status == 'deployed' &&
          m.duration == 2 &&
          m.opened <= s.week &&
          m.due > s.week &&
          !m.intervention &&
          m.relief == 0,
    )) {
      m.intervention = true;
      s.note(
        'Xin tiếp tế: ${m.title}',
        'Cần tiếp tế cho mùa tiếp theo. Cấp ${moneyText(s, money(s, 10))}, ${whole(warMissionFood(m.troops, s, m))} tạ hoặc rút quân. Bỏ mặc làm nhiệm vụ thất bại; quân vẫn trở về theo lịch.',
        'warning',
      );
    }
    final n = w.active;
    if (n != null) {
      s.war = (1 + math.max(0, -n.advantage) ~/ 25).clamp(1, 8);
      if (n.advantage <= -70 && !n.capitalWarned) {
        n.capitalWarned = true;
        for (final pending in w.missions.where(
          (m) => m.countryId == n.id && m.status == 'open',
        )) {
          pending.status = 'cancelled';
        }
        // Active contingents keep their reservations; the emergency opens as
        // soon as the enemy has enough unassigned soldiers.
        final capitalMission = _warOpenMission(s, n, 'capital');
        if (capitalMission == null) n.capitalWarned = false;
      } else if (s.week >= n.nextMission &&
          w.missions
                  .where(
                    (m) =>
                        m.countryId == n.id &&
                        ['open', 'deployed'].contains(m.status),
                  )
                  .length <
              4) {
        final kinds = [
          'supply',
          'relieve',
          'raid',
          'battle',
          'siege',
          if (!s.hasCourtSystem) 'naval',
          'defend',
        ];
        final kind = kinds[_next(s, kinds.length)];
        _warOpenMission(s, n, kind);
        n.nextMission = s.week + 1;
      }
    } else {
      s.war = 0;
      final threatened =
          w.neighbors
              .where(
                (n) =>
                    n.status != 'treaty' &&
                    n.cooldownUntil <= s.week &&
                    (n.treaty?.broken == true || n.relation <= -60),
              )
              .firstOrNull;
      if (threatened != null) _warBegin(s, threatened);
    }
  }

  void _warPetition(GameState s, Petition p, EventDefinition e, EventChoice c) {
    _warSync(s);
    var n = s.warfare!.active;
    if (n == null) {
      final candidates =
          s.warfare!.neighbors
              .where((n) => n.status != 'treaty' && n.cooldownUntil <= s.week)
              .toList();
      if (candidates.isEmpty) {
        throw const GameRuleException(
          'Các biên giới đang có hòa ước; chưa thể mở mặt trận.',
        );
      }
      n = candidates.first;
      _warBegin(s, n, initialMissions: false);
    }
    // A specific petition replaces an unaccepted routine large objective.
    // Accepted campaigns and story objectives keep their enemy reservations.
    for (final pending in s.warfare!.missions.where(
      (m) =>
          m.countryId == n!.id &&
          m.status == 'open' &&
          largeFrontierMission(m.kind) &&
          m.majorId.isEmpty &&
          m.successEffects.isEmpty &&
          m.failureEffects.isEmpty,
    )) {
      pending.status = 'cancelled';
    }
    final m = _warOpenMission(
      s,
      n,
      c.naval
          ? 'naval'
          : c.combat == 'large'
          ? 'battle'
          : 'defend',
      title: e.title,
    );
    if (m == null) {
      throw const GameRuleException(
        'Đối phương chưa đủ quân rảnh để mở nhiệm vụ mới. Hãy xử lý quân báo hiện tại.',
      );
    }
    m.successEffects = Map.of(c.laterEffects);
    m.failureEffects = Map.of(c.laterFailureEffects);
    if (p.storyKind == 'major' && s.major?.id == p.storyId) {
      final major = s.major!;
      m.majorId = major.id;
      m.objectiveKey = major.objectives[major.stage].key;
      major.decisions = [...major.decisions, e.choices.indexOf(c)];
      major.decisionLabels = [
        ...major.decisionLabels,
        'Nhận quân báo: ${e.title}',
      ];
      major.stage++;
      major.dueWeek = s.week + 1;
      major.deadline = math.max(
        major.deadline,
        s.week + major.objectives.length - major.stage + 3,
      );
    }
    s.petitions.remove(p);
    s.note(
      'Chờ điều quân',
      '${e.title}: chọn số quân và tướng tại Quân sự. Chỉ thu kinh phí và hành động khi xác nhận xuất quân.',
    );
  }
}

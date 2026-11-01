part of 'game_engine.dart';

extension InvestigationEngine on GameEngine {
  void _startCovertInvestigation(GameState s, GameCommand command) {
    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(command.option));
    } catch (_) {
      throw const GameRuleException('Lệnh điều tra không hợp lệ.');
    }
    if (data['spy'] is! String || data['funding'] is! int) {
      throw const GameRuleException('Hãy chọn mật thám và kinh phí điều tra.');
    }
    final target =
        [
          ...s.court,
          ...s.officialsPool,
        ].where((c) => c.id == command.target).firstOrNull;
    if (target == null) {
      throw const GameRuleException('Mục tiêu không còn hiện diện.');
    }
    final spy = s.court.where((c) => c.id == data['spy']).firstOrNull;
    final funding = data['funding'] as int;
    final blocked = covertBlocked(s, target, spy, funding);
    if (blocked != null) throw GameRuleException(blocked);
    final chance = covertChance(spy!, target, funding);
    final deathRisk = investigationDeathRisk(target);
    _spend(
      s,
      covertCost(s, funding),
      title: 'Điều tra ${target.name}',
      category: 'character',
      detail:
          '${spy.name}: thành công $chance%; tử vong nếu thất bại $deathRisk%.',
    );
    final success = _next(s, 100) < chance;
    final fatal = !success && _next(s, 100) < deathRisk;
    s.pending.add(
      Consequence(
        kind: 'investigate',
        target: target.id,
        dueWeek: s.week + investigationDuration(s) - 1,
        investigation: CharacterInvestigation(
          week: s.week,
          plot: target.plot,
          discontent: target.discontent,
        ),
        covertMission: CovertMission(
          spyId: spy.id,
          funding: funding,
          chance: chance,
          deathRisk: deathRisk,
          succeeded: success,
          fatal: fatal,
        ),
      ),
    );
    s.workThisWeek++;
    s.affairsThisWeek++;
    s.note(
      'Điều tra kín',
      '${spy.name} điều tra ${target.name}; chi ${moneyText(s, covertCost(s, funding))}, 1 hành động. '
          'Thành công $chance%; tử vong nếu thất bại $deathRisk%. '
          'Báo cáo về cuối ${s.date(s.week + investigationDuration(s) - 1)}. Chỉ thành công mới cập nhật hồ sơ; bằng chứng hiệu lực một năm.',
    );
  }

  String _settleCovertInvestigation(GameState s, Consequence pending) {
    final mission = pending.covertMission!;
    final spy =
        [
          ...s.court,
          ...s.officialsPool,
        ].where((c) => c.id == mission.spyId).firstOrNull;
    final target =
        [
          ...s.court,
          ...s.officialsPool,
        ].where((c) => c.id == pending.target).firstOrNull;
    if (spy == null || !spy.available || target == null || !target.available) {
      s.note(
        'Điều tra gián đoạn',
        'Mật thám hoặc mục tiêu không còn hiện diện. Không xét tử vong do thất bại; kinh phí không hoàn lại.',
        'warning',
      );
      return 'interrupted';
    }
    if (mission.succeeded) {
      target.lastInvestigation = pending.investigation;
      target.evidenceTurn = s.week + 1;
      target.investigated = true;
      target.plot = math.max(0, target.plot - (s.seasonal ? 6 : 8));
      spy.ability = math.min(100, spy.ability + 1);
      _respond(s, 'plot');
      final captured = pending.investigation!;
      s.note(
        'Hồ sơ ${target.name}',
        'Âm mưu ${captured.plot}/100, bất mãn ${captured.discontent}/100, ghi nhận ${s.date(captured.week)}. '
            '${target.qualitiesText}. Bằng chứng có hiệu lực từ ${s.date(target.evidenceTurn)} tới trước ${s.date(evidenceExpires(s, target))}. '
            '${spy.name} +1 năng lực.',
        'gold',
      );
      return 'success';
    }
    if (mission.fatal) {
      _removePersonFromDuty(s, spy);
      spy.dead = true;
      spy.available = false;
      spy.role = 'Đã tử nạn';
      s.note(
        'Mật thám tử nạn',
        '${spy.name} tử nạn khi điều tra ${target.name}. Chức Mật thám để trống; hồ sơ mục tiêu giữ nguyên, không hoàn kinh phí.',
        'danger',
      );
      return 'fatal';
    }
    s.note(
      'Điều tra chưa rõ',
      '${spy.name} trở về nhưng không đủ bằng chứng về ${target.name}. Giữ báo cáo cũ, không gia hạn bằng chứng và không hoàn kinh phí.',
      'warning',
    );
    return 'inconclusive';
  }

  void _vacatePersonOffices(GameState s, Courtier c) {
    for (final office in s.courtOffices.where((o) => o.holderId == c.id)) {
      office.holderId = '';
      office.appointedTurn = s.week;
    }
  }

  void _removePersonFromDuty(GameState s, Courtier c) {
    _vacatePersonOffices(s, c);
    for (final p in s.projects.where((p) => p.officerId == c.id).toList()) {
      if (developmentTasks.contains(p.kind)) {
        p.officerId = '';
      } else {
        s.projects.remove(p);
      }
    }
    s.population?.orders.removeWhere((o) => o.officerId == c.id);
    if (s.population != null) {
      for (var i = 0; i < s.population!.deployments.length; i++) {
        final d = s.population!.deployments[i];
        if (d.officerId != c.id && d.deputyId != c.id) continue;
        final m =
            s.warfare?.missions.where((m) => m.id == d.missionId).firstOrNull;
        if (m != null) {
          m.status = 'returning';
          _warRecall(s, m);
        } else {
          s.population!.deployments[i] = ArmyDeployment.fromJson({
            ...d.toJson(),
            'succeeded': false,
            'losses': 0,
          });
        }
      }
    }
    if (s.heirId == c.id) {
      s.heirId = '';
      s.heirCondition = 'withdrawn';
      s.successionCertified = false;
    }
  }

  void _convict(GameState s, String id) {
    final c =
        [...s.court, ...s.officialsPool].where((c) => c.id == id).firstOrNull;
    if (c == null) {
      throw const GameRuleException('Nhân vật không còn hiện diện.');
    }
    final reason = evidenceBlocked(s, c, 75);
    if (reason != null) throw GameRuleException(reason);
    _spend(
      s,
      0,
      title: 'Kết tội ${c.name}',
      category: 'character',
      detail: 'Bỏ tù theo bằng chứng âm mưu >75%.',
    );
    _removePersonFromDuty(s, c);
    c.grade = 0;
    c.inHarem = false;
    c.queen = false;
    c.imprisoned = true;
    c.available = false;
    if (!c.isConsort) c.role = 'Đang bị giam';
    s.factions[c.faction] = s.factions[c.faction]! - 5;
    s.workThisWeek++;
    s.affairsThisWeek++;
    s.note(
      'Kết tội ${c.name}',
      'Bỏ tù, tước phẩm và chức vụ; các vị trí đang giữ để trống. Chi 1 hành động; phe ${c.faction} −5. Không đổi uy quyền hoặc ổn định triều đình.',
      'warning',
    );
  }

  void _demoteCourtier(GameState s, String id, String destination) {
    final c = courtPerson(s, id);
    final steps = int.tryParse(destination) ?? 0;
    if (c == null) throw const GameRuleException('Quan không còn hiện diện.');
    final reason = courtDemotionBlocked(s, c, steps);
    if (reason != null) throw GameRuleException(reason);
    final before = c.grade;
    _spend(
      s,
      0,
      title: 'Giáng phẩm ${c.name}',
      category: 'character',
      detail: 'Giáng $steps phẩm theo bằng chứng điều tra.',
    );
    _vacatePersonOffices(s, c);
    c.grade += steps;
    c.role = 'Chờ bổ nhiệm';
    s.factions[c.faction] = s.factions[c.faction]! - 2;
    s.workThisWeek++;
    s.affairsThisWeek++;
    s.note(
      'Giáng phẩm ${c.name}',
      '${courtGradeName(before)} → ${courtGradeName(c.grade)}; thôi chức, vị trí để trống. Chi 1 hành động; phe ${c.faction} −2. Không đổi uy quyền hoặc ổn định triều đình.',
      'warning',
    );
  }
}

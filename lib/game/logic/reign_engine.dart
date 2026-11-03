part of 'game_engine.dart';

/// Kept in the engine library to use the same random, ledger, terminal checks
/// and atomic gateway as ordinary actions. No UI-side gameplay mutation.
extension ReignEngine on GameEngine {
  void _respond(GameState s, String crisis) => s.responsesThisWeek[crisis] = 1;

  void _crisisPressure(GameState s) {
    final active = activeCrises(s);
    for (final key in crisisNames.keys) {
      if (!active.contains(key) || s.responsesThisWeek.containsKey(key)) {
        s.crisisWeeks.remove(key);
        continue;
      }
      final weeks = (s.crisisWeeks[key] ?? 0) + 1;
      s.crisisWeeks[key] = weeks;
      final loss = math.min(4, (weeks + 1) ~/ 2);
      if (key == 'hunger') s.people -= loss;
      if (key == 'border') {
        if (s.population == null) {
          s.army -= loss;
        } else {
          s.population!.changeMorale(-loss.toDouble());
        }
      }
      if (key == 'plot') s.stability -= loss;
      s.note(
        '${crisisNames[key]} bị bỏ mặc',
        '$weeks tuần chưa ứng phó đúng vấn đề; ${key == 'hunger'
            ? 'lòng dân'
            : key == 'border'
            ? 'quân lực'
            : stabilityLabel} −$loss. ${crisisRemedies[key]}',
        'warning',
      );
    }
  }

  void _assignOfficer(
    GameState s,
    Courtier c, {
    bool success = false,
    String meritTitle = 'Hoàn thành công vụ',
    String? meritEventId,
  }) {
    c.strain = (c.strain + 12).clamp(0, 100);
    c.assignments++;
    if (success) _merit(s, c, title: meritTitle, eventId: meritEventId);
  }

  void _merit(
    GameState s,
    Courtier c, {
    int points = 1,
    bool major = false,
    String title = 'Hoàn thành công vụ',
    String? eventId,
  }) {
    if (s.hasCourtSystem) {
      final id = eventId ?? 'merit-${s.revision}-${c.meritHistory.length}';
      if (c.meritHistory.any((m) => m.id == id)) return;
      final before = c.totalMerit;
      c.merit += points;
      if (major) c.majorMerits++;
      c.meritHistory.add(CourtMeritRecord(id, s.week, title, points, major));
      s.note(
        'Ghi công ${c.name}',
        '$title: +$points công trạng${major ? ', 1 thành tích lớn' : ''}; khả dụng ${c.merit}.',
        'gold',
      );
      if (before ~/ 3 == c.totalMerit ~/ 3) return;
    } else {
      c.merit = (c.merit + 1).clamp(0, 100);
      if (c.merit % 3 != 0) return;
    }
    c.influence = (c.influence + 3).clamp(0, 100);
    final id = 'demand:${c.id}';
    if (s.obligations.any((o) => o.id == id)) return;
    s.obligations.add(
      Obligation(
        id: id,
        kind: 'demand',
        title: '${c.name} xin ghi nhận công trạng',
        remaining: s.seasonal ? 2 : 4,
        nextWeek: s.week + 1,
        amount: money(s, s.seasonal ? 8 : 4),
        effects: {'faction:${c.faction}': -1},
      ),
    );
    s.note(
      'Công thần có yêu sách',
      '${c.name} lập công, ảnh hưởng +3. '
          'Xin ${money(s, s.seasonal ? 8 : 4)} ${moneyUnit(s)}/${s.periodName} trong ${s.seasonal ? 2 : 4} ${s.periodName} từ ${s.date(s.week + 1)}; mỗi kỳ không trả đủ, phe ${c.faction} −1. Xem Quốc sự → Nghĩa vụ.',
      'warning',
    );
  }

  void _emergency(GameState s, String kind, [String officerId = '']) {
    if (s.warfare?.active != null && kind == 'peace') {
      final n = s.warfare!.active!;
      final tier =
          n.advantage <= -70
              ? 'heavy'
              : n.advantage <= -30
              ? 'medium'
              : 'light';
      _spend(s, money(s, 20), title: 'Cầu hòa với ${n.name}');
      _warSignTreaty(s, n, tier, receiving: false);
      s.workThisWeek++;
      s.affairsThisWeek++;
      return;
    }
    if (s.population != null && ['levy', 'early_labor'].contains(kind)) {
      _populationEmergency(s, kind, officerId);
      return;
    }
    final blocked = emergencyBlocked(s, kind);
    if (blocked != null) throw GameRuleException(blocked);
    _spend(
      s,
      money(
        s,
        kind == 'levy'
            ? 15
            : kind == 'peace'
            ? 20
            : 0,
      ),
      title: emergencyNames[kind]!,
    );
    s.workThisWeek++;
    s.affairsThisWeek++;
    if (kind == 'borrow') {
      _postMoney(
        s,
        money(s, 120),
        title: 'Vay thế gia',
        category: 'commitment',
        detail: emergencyHint(s, kind),
      );
      s.factions['Thế gia'] = s.factions['Thế gia']! + 5;
      s.authority -= 2;
    } else if (kind == 'levy') {
      s.army += 14;
      s.people -= 4;
      _respond(s, 'border');
    } else {
      s.war = math.max(0, s.war - 2);
      s.authority -= 3;
      _respond(s, 'border');
    }
    s.obligations.add(
      Obligation(
        id: '$kind-${s.revision}',
        kind: kind,
        title: emergencyNames[kind]!,
        remaining:
            s.seasonal
                ? (kind == 'levy' ? 2 : 3)
                : kind == 'borrow'
                ? 10
                : kind == 'levy'
                ? 6
                : 8,
        nextWeek: s.week + 1,
        amount: money(
          s,
          s.seasonal
              ? (kind == 'borrow'
                  ? 50
                  : kind == 'peace'
                  ? 16
                  : 0)
              : kind == 'borrow'
              ? 15
              : kind == 'peace'
              ? 6
              : 0,
        ),
        effects: kind == 'levy' ? {'grain': s.seasonal ? -6 : -2} : const {},
      ),
    );
    s.note(emergencyNames[kind]!, emergencyHint(s, kind), 'warning');
  }

  void _missionOrder(GameState s, String key, String officerId) {
    final m = s.major;
    if (m?.petitionDriven == true) {
      throw const GameRuleException(
        'Hãy ngự phê tấu chương đại biến cố; hồ sơ không nhận nhiệm vụ riêng.',
      );
    }
    if (m == null || m.resolved || s.week > m.deadline) {
      throw const GameRuleException('Không có đại biến cố đang nhận nhiệm vụ.');
    }
    final objective = m.objectives.where((o) => o.key == key).firstOrNull;
    if (objective == null || objective.done || objective.working) {
      throw const GameRuleException(
        'Mục tiêu đã hoàn thành hoặc đang được thực hiện.',
      );
    }
    final d = majorDefinition(
      m.kind,
    ).objectives.firstWhere((o) => o.key == key);
    final unavailable = majorGoalUnavailable(s, m, d);
    if (unavailable != null) throw GameRuleException(unavailable);
    final officer = _person(s, officerId);
    if (officer.isConsort || officerBusy(s, officer.id)) {
      throw const GameRuleException('Hãy chọn một quan đang rảnh.');
    }
    final officerBlock = missionOfficerBlocked(m, d, officer);
    if (officerBlock != null) throw GameRuleException(officerBlock);
    final finish = s.week + missionDuration(d, officer) - 1;
    if (finish > m.deadline) {
      throw const GameRuleException(
        'Không đủ thời gian hoàn tất trước hạn; hãy chọn người phù hợp hơn.',
      );
    }
    _spend(
      s,
      money(s, missionRemainingCost(missionCost(m, d), objective)),
      grain: missionRemainingCost(missionGrain(m, d), objective),
      title: d.title,
      category: 'major',
      detail:
          '${officer.name} phụ trách; hoàn tất cuối tuần $finish. Kinh phí và lương đã cấp, không trừ lại khi tổng kết.',
    );
    objective.officerId = officer.id;
    objective.finishWeek = finish;
    _assignOfficer(s, officer);
    s.workThisWeek++;
    s.affairsThisWeek++;
    s.note(
      'Giao việc: ${d.title}',
      '${officer.name} phụ trách, cuối tuần $finish nhận kết quả. '
          'Mục tiêu chỉ được tính khi nhận đủ thành quả. Chi ${missionRemainingCost(missionCost(m, d), objective)} ${moneyUnit(s)}, ${missionRemainingCost(missionGrain(m, d), objective)} thóc, 1 hành động. Quan hệ, tính cách và thất thoát có thể ảnh hưởng kết quả.',
    );
  }

  void _resolveMajor(GameState s) {
    final m = s.major;
    if (m == null) return;
    if (s.population?.deployments.any((d) => d.majorId == m.id) ?? false) {
      return;
    }
    if (s.warfare?.missions.any(
          (w) =>
              w.majorId == m.id &&
              ['open', 'deployed', 'returning'].contains(w.status),
        ) ??
        false) {
      return;
    }
    final definition = majorDefinition(m.kind);
    for (final o in m.objectives.where((o) => o.working)) {
      final c =
          s.court.where((c) => c.available && c.id == o.officerId).firstOrNull;
      if (c == null) {
        o.officerId = '';
        o.finishWeek = 0;
        s.note(
          'Nhiệm vụ đại biến cố gián đoạn',
          'Người phụ trách đã rời chức; cần giao lại, kinh phí cũ không hoàn.',
          'warning',
        );
        continue;
      }
      final goal = definition.objectives.firstWhere((g) => g.key == o.key);
      final unavailable =
          majorGoalUnavailable(s, m, goal) ?? missionOfficerBlocked(m, goal, c);
      if (unavailable != null) {
        o.officerId = '';
        o.finishWeek = 0;
        s.note('Nhiệm vụ đại biến cố gián đoạn', unavailable, 'warning');
        continue;
      }
      if (o.finishWeek > s.week) continue;
      final assessment = missionAssessment(s, goal, c);
      if (_next(s, 100) >= assessment.successChance) {
        o.officerId = '';
        o.finishWeek = 0;
        s.note(
          'Nhiệm vụ đại biến cố thất bại',
          '${c.name} chưa hoàn thành ${goal.title}. Đã nhận ${o.delivered}% khối lượng; có thể giao lại phần còn thiếu trước hạn. Kinh phí đã cấp không hoàn lại.',
          'warning',
        );
        continue;
      }
      final delivery = _deliveryPercent(s, c, goal.title);
      o.delivered += ((100 - o.delivered) * delivery / 100).floor();
      if (o.delivered < 100) {
        o.officerId = '';
        o.finishWeek = 0;
        s.note(
          'Mục tiêu chưa đủ khối lượng',
          '${goal.title}: đã nhận ${o.delivered}/100% khối lượng. Chưa tính hoàn thành; cần giao lại phần thiếu trước hạn, kinh phí mới tính theo phần còn lại.',
          'warning',
        );
        continue;
      }
      o.done = true;
      _merit(
        s,
        c,
        points: 3,
        major: true,
        title: goal.title,
        eventId: 'major-${m.id}-${o.key}',
      );
      final d = definition.objectives.firstWhere((d) => d.key == o.key);
      if ([
        'food',
        'reserve',
        'relief',
        'seeds',
        'fields',
        'supply',
      ].contains(o.key)) {
        _respond(s, 'hunger');
      }
      for (final response in d.responses) {
        _respond(s, response);
      }
      if (m.kind == 'invasion') _respond(s, 'border');
      if (m.kind == 'rumor') _respond(s, 'plot');
      if (m.kind == 'db-55' &&
          ['goal1', 'goal2'].contains(o.key) &&
          s.court.any((c) => c.id == m.subjectId && c.available)) {
        s.heirCondition = 'care';
      }
      s.note(
        'Hoàn thành: ${d.title}',
        '${c.name} đã hoàn tất. ${m.achieved}/4 mục tiêu của ${definition.title}.',
        'gold',
      );
    }
    if (m.petitionDriven) {
      _skipCompletedMajorStages(m);
      if (m.stage < m.objectives.length) return;
    } else if (m.achieved < 4 && s.week < m.deadline) {
      return;
    }
    final before = _outcomeStats(s);
    final rawEffects = missionEffects(m);
    final effects =
        definition.group == 'disaster'
            ? protectLeveeFromDisaster(s, rawEffects)
            : rawEffects;
    _apply(
      s,
      effects,
      title: definition.title,
      category: 'major',
      detail:
          m.petitionDriven
              ? 'Tổng kết chuỗi tấu chương. Tổn thất từng mùa đã tính, không trừ lại.'
              : 'Tổng kết ${m.achieved}/4 mục tiêu. Chỉ tính hậu quả, không thu lại kinh phí đã cấp.',
    );
    m.resolvedWeek = s.week;
    m.result = missionResultLabel(m.responseScore);
    if (m.responseScore <= 1) {
      final aftermath =
          definition.group == 'disaster'
              ? protectLeveeFromDisaster(s, majorAftermath(m))
              : majorAftermath(m);
      s.obligations.add(
        Obligation(
          id: 'aftermath-${m.id}',
          kind: 'aftermath',
          title: 'Dư âm: ${definition.title}',
          remaining:
              s.seasonal
                  ? (m.responseScore == 0 ? 2 : 1)
                  : (m.responseScore == 0 ? 4 : 2),
          nextWeek: s.week + 1,
          effects: aftermath,
        ),
      );
    }
    if (m.achieved == 4) {
      s.realmMilestones[m.kind] = s.week;
      if (m.kind == 'db-55' &&
          s.court.any((c) => c.id == m.subjectId && c.available)) {
        s.heirCondition = 'stable';
      }
      if (m.kind == 'db-56' &&
          s.court.any((c) => c.id == m.subjectId && c.available)) {
        s.successionCertified = true;
      }
    }
    final agreement = definition.agreement;
    if (agreement != null &&
        (agreement.goal.isEmpty
            ? m.achieved == 4
            : m.objectives.any((o) => o.key == agreement.goal && o.done))) {
      s.obligations.add(
        Obligation(
          id: 'agreement-${m.id}',
          kind: agreement.income > 0 ? 'benefit' : 'alliance',
          title: agreement.title,
          remaining:
              s.seasonal ? s.workTurns(agreement.weeks) : agreement.weeks,
          nextWeek: s.week + (s.seasonal && agreement.income > 0 ? 4 : 1),
          amount: money(
            s,
            s.seasonal
                ? (agreement.amount *
                        agreement.weeks /
                        s.workTurns(agreement.weeks))
                    .ceil()
                : agreement.amount,
          ),
          income: money(
            s,
            s.seasonal
                ? (agreement.income *
                        agreement.weeks /
                        s.workTurns(agreement.weeks))
                    .ceil()
                : agreement.income,
          ),
        ),
      );
    }
    s.lastMajorGap = majorGap(s, _next(s, s.seasonal ? 3 : 21));
    s.nextMajorWeek = s.week + s.lastMajorGap + 1;
    s.lastMajorKind = m.kind;
    s.note(
      '${definition.title} — ${m.result}',
      '${m.petitionDriven ? '${m.stage} bản tấu, ${m.achieved} phần được bảo vệ đầy đủ. Lịch sử: ${m.decisionLabels.join(' → ')}. Tổn thất đã xảy ra: ${eventEffectText(m.damageTaken)}. ' : '${m.achieved}/4 mục tiêu. '}'
          '${majorOutcomeNarrative(s, m)} '
          '${eventEffectText(effects)}. ${m.responseScore <= 1 ? 'Hậu quả kéo dài được ghi tại Nghĩa vụ. ' : ''}'
          'Đã có ${m.preparedness}/2 mức chuẩn bị, giảm ${m.preparedness * 10}% thiệt hại. '
          '${agreement != null && s.obligations.any((o) => o.id == 'agreement-${m.id}') ? '${majorCommitmentHint(definition, s)} ' : ''}'
          'Khoảng nghỉ ${s.lastMajorGap} tuần trọn vẹn; đại biến cố tiếp theo sớm nhất tuần ${s.nextMajorWeek}.',
      m.achieved == 4 ? 'gold' : 'danger',
    );
    _recordOutcome(
      s,
      before,
      definition.title,
      m.achieved == 4
          ? 'success'
          : m.responseScore >= 2
          ? 'partial'
          : 'failure',
    );
    s.majorHistory.add(m);
    s.major = null;
  }

  void _openMajor(GameState s) {
    final pool = majorDrawPool(s);
    if (pool.isEmpty) return;
    final total = pool.fold<int>(0, (sum, d) => sum + majorWeight(s, d));
    var draw = _next(s, total);
    var d = pool.last;
    for (final candidate in pool) {
      draw -= majorWeight(s, candidate);
      if (draw < 0) {
        d = candidate;
        break;
      }
    }
    final preparedness = majorPreparation(s, d);
    String subjectId = '';
    if (d.condition == 'heir') {
      final heirs = heirCandidates(s);
      final heir =
          heirs.where((c) => c.id == s.heirId).firstOrNull ?? heirs.first;
      s.heirId = subjectId = heir.id;
      if (d.id == 'db-55') s.heirCondition = 'critical';
      if (d.id == 'db-56') s.successionCertified = false;
    }
    s.major = MajorMission(
      id: '${d.id}-${s.week}',
      kind: d.id,
      subjectId: subjectId,
      openedWeek: s.week,
      deadline: s.week + majorDuration(s, d) - 1,
      severity: reignStage(s) + 1,
      preparedness: preparedness,
      demanding: s.seasonal,
      petitionDriven: s.seasonal,
      dueWeek: s.week,
      objectives:
          d.objectives.map((o) => MissionObjective(key: o.key)).toList(),
    );
    if (d.id == 'earthquake') {
      _apply(
        s,
        {'people': -2, 'treasury': -10},
        title: d.title,
        detail:
            'Thiệt hại ban đầu của động đất; nhiệm vụ ứng phó ngăn hậu quả tiếp theo.',
        category: 'major',
      );
    }
    s.note(
      'Đại biến cố: ${d.title}',
      s.seasonal
          ? '${majorBody(s, s.major!)} Các bản tấu nối tiếp qua mùa, mức ${s.major!.severity}. '
              'Ngự phê tại Tấu chương. Mỗi bản có hạn cuối mùa; phần chưa bảo vệ chịu tổn thất ngay và làm ứng phó sau đắt hơn.'
          : '${majorBody(s, s.major!)} Hạn cuối tuần ${s.major!.deadline}; 4 mục tiêu, mức ${s.major!.severity}. '
              'Xem Triều chính hoặc Quốc sự để giao việc. Đạt đủ sẽ kết thúc sớm; thiếu mục tiêu chịu hậu quả theo phần chưa bảo vệ.',
      'danger',
    );
  }

  void _chainChoice(GameState s, String id, String option) {
    if (s.seasonal) {
      throw const GameRuleException(
        'Hãy xử lý chuỗi bằng cách ngự phê tấu chương.',
      );
    }
    final arc =
        s.chains.where((a) => a.id == id && a.dueWeek <= s.week).firstOrNull;
    if (arc == null) {
      throw const GameRuleException(
        'Chưa tới giai đoạn tiếp theo hoặc chuỗi đã kết thúc.',
      );
    }
    final stage = legacyChainDefinition(arc.kind).stages[arc.stage];
    final index = int.tryParse(option);
    if (index == null || index < 0 || index >= stage.choices.length) {
      throw const GameRuleException('Lựa chọn không hợp lệ.');
    }
    final choice = stage.choices[index];
    _spend(
      s,
      money(s, choice.cost),
      grain: choice.grainCost,
      points: choice.points,
      title: stage.title,
      category: 'chain',
      detail: choice.label,
    );
    s.workThisWeek += choice.points;
    s.affairsThisWeek++;
    final before = _outcomeStats(s);
    _apply(
      s,
      choice.effects,
      title: stage.title,
      detail: choice.label,
      category: 'chain',
    );
    _advanceChain(s, arc, index, choice.label, before: before);
  }

  void _advanceChain(
    GameState s,
    StoryArc arc,
    int index,
    String label, {
    Map<String, int>? before,
  }) {
    before ??= _outcomeStats(s);
    final kind = arc.kind;
    final stage = arc.stage;
    if ((kind == 'border' && stage == 1 && index == 1) ||
        (kind == 'granary' && stage == 0 && index == 1)) {
      s.obligations.add(
        Obligation(
          id: '${arc.id}-$stage',
          kind: 'chainPromise',
          title:
              kind == 'border'
                  ? 'Cống nạp theo thỏa thuận biên giới'
                  : 'Hoàn trả khoản vay thóc',
          remaining:
              s.seasonal
                  ? (kind == 'border' ? 2 : 1)
                  : (kind == 'border' ? 6 : 5),
          nextWeek: s.week + 1,
          amount: money(
            s,
            s.seasonal
                ? (kind == 'border' ? 18 : 35)
                : (kind == 'border' ? 6 : 7),
          ),
        ),
      );
    }
    arc.decisions = [...arc.decisions, index];
    // Earlier choices change the later cost/outcome, not just the story label.
    if (stage == 2) {
      final neglected = arc.decisions.take(2).where((i) => i == 2).length;
      final tradeoffs = <String, int>{};
      if (neglected > 0) {
        tradeoffs[kind == 'border' ? 'army' : 'people'] = -3 * neglected;
      }
      if (kind == 'embezzlement' &&
          index == 0 &&
          arc.decisions.first == 0 &&
          arc.decisions[1] == 0) {
        tradeoffs['treasury'] = 30;
        tradeoffs['authority'] = 2;
      }
      if (kind == 'embezzlement' && arc.decisions.first == 1) {
        tradeoffs['faction:Thế gia'] = -4;
      }
      if (kind == 'border' &&
          index == 0 &&
          arc.decisions.first == 0 &&
          arc.decisions[1] == 0) {
        tradeoffs['war'] = -1;
      }
      if (kind == 'granary' && index == 0 && arc.decisions.first == 0) {
        tradeoffs['grain'] = 10;
      }
      _apply(
        s,
        tradeoffs,
        title: legacyChainDefinition(kind).title,
        category: 'chain',
        detail: 'Hệ quả của các quyết định trước trong chuỗi.',
      );
      s.chains.remove(arc);
      s.completedChains.add(kind);
      s.nextChainWeek =
          s.week + (s.seasonal ? 1 + _next(s, 2) : 6 + _next(s, 7));
      s.note(
        'Khép lại: ${legacyChainDefinition(kind).title}',
        '$label. '
            'Lịch sử lựa chọn: ${arc.decisions.map((i) => i + 1).join(' → ')}. '
            'Hệ quả tích lũy: ${eventEffectText(tradeoffs)}.',
        'gold',
      );
      _recordOutcome(
        s,
        before,
        legacyChainDefinition(kind).title,
        arc.decisions.every((i) => i == 0) ? 'success' : 'partial',
      );
    } else {
      arc.stage++;
      arc.dueWeek = s.week + (s.seasonal ? 1 : 2);
      s.note(
        legacyChainDefinition(kind).title,
        '$label. Giai đoạn tiếp theo xuất hiện tuần ${arc.dueWeek}; '
        'lựa chọn vừa rồi được giữ trong hồ sơ chuỗi.',
      );
    }
  }

  void _reignWeek(GameState s) {
    // Monetary obligations are paid through the ordinary ledger/budget loop.
    for (final o in s.obligations.where((o) => o.nextWeek <= s.week).toList()) {
      final before = _outcomeStats(s);
      if (o.kind != 'demand') {
        _apply(s, o.effects, title: o.title, category: 'commitment');
      }
      o.remaining--;
      o.nextWeek++;
      if (o.remaining <= 0) {
        s.obligations.remove(o);
        s.note(
          '${o.income > 0 ? 'Kết thúc nguồn thu' : 'Hết nghĩa vụ'}: ${o.title}',
          o.income > 0
              ? 'Nguồn thu đã nhận đủ ${o.income} ${moneyUnit(s)} ở kỳ cuối; không phát sinh lại sau khi kết thúc.'
              : 'Đã tới kỳ cuối. Các khoản còn thiếu đã ghi vào nợ chi trả, không tự xóa nợ.',
        );
      }
      if (o.effects.isNotEmpty && o.kind != 'demand') {
        s.note(
          o.title,
          'Hậu quả kỳ này: ${eventEffectText(o.effects)}. Còn ${o.remaining} tuần.',
          'warning',
        );
        _recordOutcome(s, before, o.title, 'failure');
      }
    }
    for (final arc
        in s.chains
            .where((a) => !s.seasonal && a.dueWeek + 2 <= s.week)
            .toList()) {
      final stage = legacyChainDefinition(arc.kind).stages[arc.stage];
      final choice = stage.choices.last;
      final before = _outcomeStats(s);
      _apply(
        s,
        choice.effects,
        title: 'Quá hạn: ${stage.title}',
        category: 'chain',
      );
      _advanceChain(
        s,
        arc,
        stage.choices.length - 1,
        'Quá hạn: ${choice.label}',
        before: before,
      );
    }
    _finishIfCritical(s);
    if (s.ended) return;
    _resolveMajor(s);
    _finishIfCritical(s);
    if (s.ended) return;
    _crisisPressure(s);
    for (final c in s.court.where((c) => c.available)) {
      c.strain = math.max(0, c.strain - (officerBusy(s, c.id) ? 3 : 8));
    }
    if (reignStage(s) >= 2 &&
        s.factions.values.reduce(math.max) -
                s.factions.values.reduce(math.min) >
            35) {
      s.stability--;
    }
  }

  void _reignGenerate(GameState s) {
    final warnings =
        s.seasonal
            ? seasonalStageStarts.skip(1).map((n) => n - 1).toList()
            : [firstDifficultyWeek - 5, 48];
    final starts =
        s.seasonal
            ? seasonalStageStarts.skip(1).toList()
            : [firstDifficultyWeek - 1, 52];
    if (warnings.contains(s.completedWeeks)) {
      s.note(
        'Thế cục sắp đổi',
        'Còn ${s.seasonal ? '1 mùa' : '4 tuần'} trước giai đoạn mới. ${reignStageHint(s)}',
        'warning',
      );
    }
    if (starts.contains(s.completedWeeks)) {
      s.note('Giai đoạn ${reignStageName(s)}', reignStageHint(s), 'warning');
    }
    if (s.major == null && s.week >= s.nextMajorWeek) _openMajor(s);
    if (s.chains.isEmpty && s.week >= s.nextChainWeek) {
      final definitions =
          s.seasonal ? chainDefinitions : legacyChainDefinitions;
      var pool =
          definitions
              .where(
                (d) =>
                    (!s.seasonal
                        ? ['embezzlement', 'border', 'granary'].contains(d.id)
                        : chainEligible(s, d)) &&
                    !s.completedChains.contains(d.id),
              )
              .toList();
      if (pool.isEmpty) {
        final eligible =
            definitions
                .where(
                  (d) =>
                      s.seasonal
                          ? chainEligible(s, d)
                          : [
                            'embezzlement',
                            'border',
                            'granary',
                          ].contains(d.id),
                )
                .toList();
        // Do not erase unseen, temporarily ineligible stories from the cycle.
        if (eligible.isEmpty) return;
        if (definitions.every(
          (d) => s.completedChains.contains(d.id) || !chainEligible(s, d),
        )) {
          s.completedChains.removeWhere(
            (id) => eligible.any((d) => d.id == id),
          );
        }
        pool = eligible;
      }
      final d = pool[_next(s, pool.length)];
      final arc = StoryArc(
        id: '${d.id}-${s.week}',
        kind: d.id,
        dueWeek: s.week,
        settlementVersion: s.seasonal ? (s.challengingEconomy ? 2 : 1) : 0,
      );
      if (s.seasonal) _initializeStory(s, arc);
      s.chains.add(arc);
      s.note(
        'Chuỗi sự kiện: ${d.title}',
        'Có hồ sơ mới chờ ngự phê. Mỗi giai đoạn có ${s.seasonal ? 2 : 3} ${s.periodName} để quyết định; xem Quốc sự.',
        'warning',
      );
    }
    if (s.seasonal) _syncStoryPetitions(s);
  }
}

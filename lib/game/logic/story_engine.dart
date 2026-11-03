part of 'game_engine.dart';

extension StoryPetitionEngine on GameEngine {
  bool storyPetitionsNeedSync(GameState s) {
    if (!s.seasonal || s.ended) return false;
    if (s.foodDisruptions.any(
      (e) =>
          foodRecoveryDue(s, e) &&
          !s.petitions.any((p) => p.definitionId == foodRecoveryId(e)),
    )) {
      return true;
    }
    if (s.storySystemVersion < 1) return true;
    final m = s.major;
    if (m != null &&
        m.petitionDriven &&
        m.stage < m.objectives.length &&
        m.objectives[m.stage].done) {
      return true;
    }
    if (m != null &&
        m.petitionDriven &&
        m.stage < m.objectives.length &&
        !m.objectives[m.stage].working &&
        m.dueWeek <= s.week &&
        !s.petitions.any((p) => p.storyId == m.id)) {
      return true;
    }
    return s.chains.any(
      (arc) =>
          arc.dueWeek <= s.week && !s.petitions.any((p) => p.storyId == arc.id),
    );
  }

  /// Called inside the same transaction as the normal save/command. No money,
  /// spent actions, old decisions or already-paid officer assignments reset.
  bool prepareStoryPetitions(GameState s) {
    if (!s.seasonal || s.ended) return false;
    var changed = false;
    if (s.storySystemVersion < 1) {
      s.storySystemVersion = 1;
      for (final arc in s.chains) {
        _initializeStory(s, arc);
        if (arc.decisionLabels.isEmpty) {
          arc.decisionLabels = [
            for (var i = 0; i < arc.decisions.length; i++)
              chainDefinitionFor(arc).stages[i].choices[arc.decisions[i]].label,
          ];
        }
      }
      final m = s.major;
      if (m != null && !m.petitionDriven) {
        m.petitionDriven = true;
        m.dueWeek = s.week;
        _skipCompletedMajorStages(m);
        m.deadline = math.max(
          m.deadline,
          s.week + m.objectives.length - m.stage - 1,
        );
      }
      s.note(
        'Các hồ sơ được trình thành tấu chương',
        'Giữ nguyên quyết định, công việc đang làm và kinh phí đã chi. '
            'Bản tấu tiếp nối có hạn riêng; xử lý tại Tấu chương.',
      );
      changed = true;
    }
    for (final arc in s.chains.where(usesChainSettlement)) {
      if (!arc.facts.containsKey('initialized')) {
        _initializeStory(s, arc);
        changed = true;
      }
    }
    final recoveryChanged = _syncFoodRecoveryPetitions(s);
    return _syncStoryPetitions(s) || recoveryChanged || changed;
  }

  void _initializeStory(GameState s, StoryArc arc) {
    if (s.goldStandard && arc.currencyScale == 1) {
      arc.currencyScale = 100;
      arc.investedValue *= 100;
      arc.cashSpent *= 100;
    }
    if (arc.facts.containsKey('initialized')) return;
    arc.facts = {'initialized': 1};
    if (arc.kind == 'justice') arc.facts['innocent'] = _next(s, 2);
    if (arc.kind == 'palaceRumor') {
      final people = s.court.where((c) => c.available && c.inHarem).toList();
      if (people.isNotEmpty) arc.subjectId = people[_next(s, people.length)].id;
      arc.facts['guilty'] = _next(s, 2);
    }
    if (arc.kind == 'merit') {
      arc.subjectId =
          s.court
              .where(
                (c) => c.available && !c.isConsort && c.specialty == 'Quân sự',
              )
              .firstOrNull
              ?.id ??
          '';
    }
    if (arc.kind == 'haremHarmony') {
      final pairs = harmonyPairs(s);
      if (pairs.isNotEmpty) {
        final pair = pairs[_next(s, pairs.length)];
        arc.participantIds = [pair.$1.id, pair.$2.id];
        arc.participantFactions = [pair.$1.faction, pair.$2.faction];
      }
    }
  }

  void _skipCompletedMajorStages(MajorMission m) {
    while (m.stage < m.objectives.length && m.objectives[m.stage].done) {
      m.decisions = [...m.decisions, 0];
      m.decisionLabels = [
        ...m.decisionLabels,
        'Đã hoàn tất trước khi chuyển hồ sơ: ${majorDefinition(m.kind).objectives[m.stage].title}',
      ];
      m.stage++;
    }
  }

  bool _syncStoryPetitions(GameState s) {
    if (!s.seasonal || s.ended) return false;
    var changed = false;
    final activeMajor = s.major;
    if (activeMajor != null && activeMajor.petitionDriven) {
      final beforeStage = activeMajor.stage;
      _skipCompletedMajorStages(activeMajor);
      if (beforeStage != activeMajor.stage) {
        s.petitions.removeWhere(
          (p) =>
              p.storyId == activeMajor.id && p.storyStage != activeMajor.stage,
        );
        changed = true;
      }
    }
    for (final arc in s.chains) {
      if (arc.dueWeek > s.week || s.petitions.any((p) => p.storyId == arc.id)) {
        continue;
      }
      s.petitions.add(
        Petition(
          id: '${arc.id}-petition-${arc.stage}',
          definitionId: chainEventId(arc),
          openedWeek: s.week,
          deadline: math.max(s.week, arc.dueWeek + 1),
          storyId: arc.id,
          storyKind: 'chain',
          storyStage: arc.stage,
        ),
      );
      changed = true;
    }
    final m = s.major;
    if (m != null &&
        m.petitionDriven &&
        m.stage < m.objectives.length &&
        m.dueWeek <= s.week &&
        !m.objectives[m.stage].working &&
        !s.petitions.any((p) => p.storyId == m.id)) {
      // A migrated deadline may already have passed: grant the visible season,
      // never auto-apply a choice before the player can read the petition.
      m.dueWeek = math.max(m.dueWeek, s.week);
      s.petitions.insert(
        0,
        Petition(
          id: '${m.id}-petition-${m.stage}',
          definitionId: majorEventId(m),
          openedWeek: s.week,
          deadline: s.week,
          storyId: m.id,
          storyKind: 'major',
          storyStage: m.stage,
        ),
      );
      changed = true;
    }
    return changed;
  }

  void _resolveStoryPetition(
    GameState s,
    Petition p,
    String option, {
    bool expired = false,
    String assigneeId = '',
  }) {
    if (assigneeId.isNotEmpty) {
      throw const GameRuleException(
        'Ngự phê này không có công việc để giao riêng.',
      );
    }
    final arc = s.chains.where((a) => a.id == p.storyId).firstOrNull;
    final m = s.major;
    final chain = p.storyKind == 'chain';
    if ((chain &&
            (arc == null ||
                arc.stage != p.storyStage ||
                arc.dueWeek > s.week ||
                chainEventId(arc) != p.definitionId)) ||
        (!chain &&
            (p.storyKind != 'major' ||
                m == null ||
                !m.petitionDriven ||
                m.id != p.storyId ||
                m.stage != p.storyStage ||
                m.dueWeek > s.week ||
                majorEventId(m) != p.definitionId))) {
      throw const GameRuleException(
        'Bản tấu không còn khớp với diễn biến hiện tại. Hãy tải lại.',
      );
    }
    final e = eventForState(s, p.definitionId);
    if (chain && usesChainSettlement(arc!)) {
      _resolveSettlementChain(s, p, arc, option, expired: expired);
      return;
    }
    final index = int.tryParse(option);
    if (index == null || index < 0 || index >= e.choices.length) {
      throw const GameRuleException('Lựa chọn không hợp lệ.');
    }
    final c = e.choices[index];
    if (!expired && s.warfare != null && c.effects.containsKey('warMission')) {
      _warPetition(s, p, e, c);
      return;
    }
    final deployment = s.population != null && c.troops > 0 && !expired;
    if (deployment && c.troops > s.population!.availableSoldiers) {
      throw GameRuleException('Cần ${whole(c.troops)} quân rảnh.');
    }
    if (!expired) {
      _spend(
        s,
        c.cost,
        grain: c.grainCost,
        points: petitionPoints(s, c),
        title: e.title,
        category: chain ? 'chain' : 'major',
        detail: c.label,
      );
      s.workThisWeek += petitionPoints(s, c);
      s.affairsThisWeek++;
    }
    final before = _outcomeStats(s);
    if (deployment) _deployChoice(s, e, c, assigneeId);
    if (!deployment) {
      _apply(
        s,
        c.effects,
        title: expired ? 'Quá hạn: ${e.title}' : e.title,
        detail: c.label,
        category: chain ? 'chain' : 'major',
      );
    }
    s.petitions.remove(p);
    s.note(
      expired ? 'Quá hạn: ${e.title}' : e.title,
      '${c.label}. ${c.hint}',
      expired ? 'danger' : 'neutral',
    );
    final label =
        '${expired ? 'Quá hạn — ' : ''}${c.label} (${s.date(s.week)})';
    if (chain) {
      _advancePetitionChain(s, arc!, index, label);
    } else {
      final current = m!;
      final goal = majorDefinition(current.kind).objectives[current.stage];
      final objective = current.objectives[current.stage];
      final unavailable = majorGoalUnavailable(s, current, goal);
      objective.delivered =
          index == 0 && unavailable == null
              ? 100
              : index == 2
              ? objective.delivered
              : objective.delivered + ((100 - objective.delivered) / 2).floor();
      objective.done = objective.delivered == 100;
      objective.officerId = '';
      objective.finishWeek = 0;
      current.decisions = [...current.decisions, index];
      _recordCrisisPressure(s, current, index);
      current.decisionLabels = [...current.decisionLabels, label];
      current.damageTaken = Map.of(current.damageTaken);
      for (final entry in (deployment ? <String, int>{} : c.effects).entries) {
        current.damageTaken.update(
          entry.key,
          (v) => v + entry.value,
          ifAbsent: () => entry.value,
        );
      }
      if (index != 2) {
        for (final response in goal.responses) {
          _respond(s, response);
        }
        if (current.kind == 'invasion') _respond(s, 'border');
        if (current.kind == 'rumor') _respond(s, 'plot');
        if (current.kind == 'db-55' &&
            objective.done &&
            ['goal1', 'goal2'].contains(goal.key)) {
          s.heirCondition = 'care';
        }
      }
      current.stage++;
      _skipCompletedMajorStages(current);
      current.dueWeek = s.week + 1;
      current.deadline = math.max(
        current.deadline,
        s.week + current.objectives.length - current.stage,
      );
      if (current.stage == current.objectives.length) _resolveMajor(s);
    }
    _recordOutcome(
      s,
      before,
      e.title,
      index == 0
          ? 'success'
          : index == 1
          ? 'partial'
          : 'failure',
    );
  }

  void _resolveSettlementChain(
    GameState s,
    Petition p,
    StoryArc arc,
    String option, {
    required bool expired,
  }) {
    final d = chainDefinition(arc.kind), stage = d.stages[arc.stage];
    final explicitStop = option == 'abandon';
    final index = expired || explicitStop ? null : int.tryParse(option);
    if (!expired &&
        !explicitStop &&
        (index == null || index < 0 || index >= stage.choices.length)) {
      throw const GameRuleException('Lựa chọn không hợp lệ.');
    }
    final quit = expired || explicitStop || chainChoiceAbandons(arc, index!);
    if (quit) {
      if (!expired) {
        _spend(
          s,
          money(s, 0),
          points: 1,
          title: 'Dừng chuỗi: ${d.title}',
          category: 'chain',
        );
        s.workThisWeek++;
        s.affairsThisWeek++;
      }
      arc.decisionLabels = [
        ...arc.decisionLabels,
        '${expired ? 'Quá hạn, dừng chuỗi' : 'Từ bỏ'} (${s.date(s.week)})',
      ];
      s.petitions.remove(p);
      _settleChain(s, arc, reason: expired ? 'Quá hạn' : 'Từ bỏ');
      return;
    }
    final reason = chainSettlementChoiceBlocked(s, arc, index);
    if (reason != null) throw GameRuleException(reason);
    final c = stage.choices[index];
    final effects = chainChoiceEffects(arc, c);
    final before = _outcomeStats(s);
    _spend(
      s,
      money(s, c.cost),
      points: 1,
      title: stage.title,
      category: 'chain',
      detail: chainParticipantText(s, arc, c.label),
    );
    s.workThisWeek++;
    s.affairsThisWeek++;
    _apply(s, effects, title: stage.title, category: 'chain');
    arc.investedValue += chainStepValue(arc);
    arc.cashSpent += money(s, c.cost);
    arc.resourceCosts = Map.of(arc.resourceCosts);
    for (final e in currencyEffects(
      s,
      effects,
    ).entries.where((e) => e.value < 0)) {
      arc.resourceCosts.update(
        e.key,
        (n) => n - e.value,
        ifAbsent: () => -e.value,
      );
    }
    arc.decisions = [...arc.decisions, index];
    arc.decisionLabels = [
      ...arc.decisionLabels,
      '${chainParticipantText(s, arc, c.label)} (${s.date(s.week)})',
    ];
    arc.completedSteps++;
    arc.stage++;
    s.petitions.remove(p);
    if (arc.completedSteps == 4) {
      _settleChain(s, arc, reason: 'Hoàn thành');
    } else {
      arc.dueWeek = s.week + stage.delay;
      s.note(
        stage.title,
        'Đã hoàn thành ${arc.completedSteps}/4 · chi ${money(s, c.cost)} ${moneyUnit(s)} · tổng chi phí quy đổi ${arc.investedValue}. '
        '${effects.isEmpty ? '' : '${eventEffectText(effects)}. '}'
        'Chưa nhận phần thưởng. Bản tấu tiếp theo ${s.date(arc.dueWeek)}.',
      );
      _recordOutcome(s, before, stage.title, 'success');
    }
  }

  void _settleChain(GameState s, StoryArc arc, {required String reason}) {
    if (!s.chains.contains(arc) || arc.facts['settled'] == 1) {
      throw const GameRuleException('Chuỗi đã được quyết toán.');
    }
    final before = _outcomeStats(s);
    final d = chainDefinition(arc.kind);
    final effects = chainSettlementEffects(arc);
    _apply(
      s,
      effects,
      title: 'Quyết toán: ${d.title}',
      category: 'chain',
      detail:
          '$reason ở ${arc.completedSteps}/4; vốn quy đổi ${arc.investedValue}.',
    );
    final personChanges = <String>[];
    for (final p in chainSettlementPersonEffects(arc).entries) {
      final c =
          s.court
              .where(
                (c) =>
                    c.id == p.key && c.available && (!c.isConsort || c.inHarem),
              )
              .firstOrNull;
      if (c == null) {
        if (p.value.isNotEmpty) {
          personChanges.add(
            'Người liên quan đã rời vị trí; không chuyển thưởng cho người thay thế',
          );
        }
        continue;
      }
      for (final e in p.value.entries) {
        if (c.isConsort && e.key == 'ability') continue;
        final old = switch (e.key) {
          'ability' => c.ability,
          'affection' => c.affection,
          'discontent' => c.discontent,
          'loyalty' => c.loyalty,
          _ => throw StateError('Unknown chain person reward ${e.key}'),
        };
        final value = (old + e.value).clamp(0, 100);
        switch (e.key) {
          case 'ability':
            c.ability = value;
          case 'affection':
            c.affection = value;
          case 'discontent':
            c.discontent = value;
          case 'loyalty':
            c.loyalty = value;
        }
        final label =
            {
              'ability': 'năng lực',
              'affection': 'thiện cảm',
              'discontent': 'bất mãn',
              'loyalty': 'trung thành',
            }[e.key];
        personChanges.add(
          '${c.name}: $label ${value - old >= 0 ? '+' : ''}${value - old}',
        );
      }
    }
    if (arc.kind == 'exams' && arc.completedSteps == 4) {
      final candidate = _newOfficialCandidate(s)..ability = 80 + _next(s, 11);
      s.officialsPool.add(candidate);
      personChanges.add(
        'Ứng viên mới: ${candidate.name}, năng lực ${candidate.ability}; tự bổ nhiệm tại Triều thần',
      );
    }
    _clamp(s);
    final after = _outcomeStats(s);
    final received = [
      for (final e in after.entries)
        if (before[e.key] != null && e.value != before[e.key])
          '${e.key} ${e.value - before[e.key]! >= 0 ? '+' : ''}${e.value - before[e.key]!}',
      ...personChanges,
    ];
    arc.facts = {...arc.facts, 'settled': 1};
    s.chains.remove(arc);
    s.petitions.removeWhere((p) => p.storyId == arc.id);
    s.completedChains.add(arc.kind);
    s.nextChainWeek = s.week + 1 + _next(s, 2);
    s.note(
      'Quyết toán: ${d.title}',
      '$reason ở ${arc.completedSteps}/4 · đã chi ${arc.cashSpent} ${moneyUnit(s)} · tổng chi phí quy đổi ${arc.investedValue}. '
          '${d.economic ? 'Hệ số nhận lại ${chainMoneyPercent(arc.completedSteps, arc.settlementVersion)}%.' : 'Nhận ${chainRewardPercent(arc.completedSteps, arc.settlementVersion)}% quỹ thưởng.'} '
          'Thực nhận: ${received.isEmpty ? 'không có phần thưởng' : received.join(' · ')}. '
          'Chỉ số đã đánh đổi được giữ nguyên; quyết toán một lần.',
      arc.completedSteps == 4 ? 'gold' : 'neutral',
    );
    _recordOutcome(
      s,
      before,
      'Quyết toán: ${d.title}',
      arc.completedSteps == 4
          ? 'success'
          : arc.completedSteps >= 2
          ? 'partial'
          : 'failure',
    );
  }

  void _advancePetitionChain(
    GameState s,
    StoryArc arc,
    int index,
    String label,
  ) {
    final stage = chainStageFor(arc);
    final last = arc.stage == chainDefinitionFor(arc).stages.length - 1;
    if ((arc.kind == 'border' && arc.stage == 1 && index == 1) ||
        (arc.kind == 'granary' && arc.stage == 0 && index == 1)) {
      s.obligations.add(
        Obligation(
          id: '${arc.id}-${arc.stage}',
          kind: 'chainPromise',
          title:
              arc.kind == 'border'
                  ? 'Cống nạp theo thỏa thuận biên giới'
                  : 'Hoàn trả khoản vay thóc',
          remaining: arc.kind == 'border' ? 2 : 1,
          nextWeek: s.week + 1,
          amount: arc.kind == 'border' ? 18 : 35,
        ),
      );
    }
    if (arc.kind == 'exams' && arc.stage == 1 && arc.subjectId.isEmpty) {
      final candidate = _newOfficialCandidate(s);
      // Public recruitment decisions affect the selected cohort. The player
      // still sees the real candidate and appoints manually through the court.
      if (arc.decisions.first == 2 && index == 2) {
        candidate.ability = math.min(candidate.ability, 45);
      }
      s.officialsPool.add(candidate);
      arc.subjectId = candidate.id;
    }
    if (arc.kind == 'exams' && last && index == 2) {
      s.officialsPool.removeWhere((c) => c.id == arc.subjectId);
    }
    if (arc.kind == 'palaceRumor' && arc.subjectId.isNotEmpty) {
      final person =
          s.court
              .where((c) => c.id == arc.subjectId && c.available && c.inHarem)
              .firstOrNull;
      if (person != null) {
        if (arc.stage == 0 && index == 2) {
          person.affection -= 8;
          person.discontent += 8;
        }
        if (last && index == 0 && arc.decisions[1] == 0) {
          if (arc.facts['guilty'] != 1) {
            person.affection += arc.decisions.first == 2 ? 6 : 3;
            person.discontent = math.max(0, person.discontent - 6);
          } else {
            person.affection -= 3;
          }
        }
        if (last && index == 2) person.discontent += 6;
      }
    }
    if (arc.kind == 'merit' && last) {
      final person =
          s.court
              .where((c) => c.id == arc.subjectId && c.available)
              .firstOrNull;
      if (person != null) {
        person.loyalty +=
            index == 0 && arc.decisions.contains(0)
                ? 3
                : index == 2
                ? -4
                : 0;
      }
    }
    if (arc.kind == 'copper' &&
        last &&
        index == 0 &&
        arc.decisions[1] == 0 &&
        arc.decisions[2] == 0) {
      s.obligations.add(
        Obligation(
          id: 'income-${arc.id}',
          kind: 'benefit',
          title: 'Nguồn thu mỏ đồng có giám sát',
          remaining: 4,
          nextWeek: s.week + 1,
          income: money(s, 12),
        ),
      );
    }
    arc.decisions = [...arc.decisions, index];
    arc.decisionLabels = [...arc.decisionLabels, label];
    if (last || (arc.kind == 'copper' && arc.stage == 0 && index == 2)) {
      s.chains.remove(arc);
      s.completedChains.add(arc.kind);
      s.nextChainWeek = s.week + 1 + _next(s, 2);
      s.note(
        'Khép chuỗi: ${chainDefinitionFor(arc).title}',
        arc.decisionLabels.join(' → '),
        'gold',
      );
    } else {
      arc.stage++;
      arc.dueWeek = s.week + stage.delay;
      s.note(
        'Chờ bản tấu tiếp nối',
        '${chainDefinitionFor(arc).title}: dự kiến ${s.date(arc.dueWeek)}.',
      );
    }
  }
}

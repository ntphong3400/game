part of 'game_engine.dart';

extension HaremQuestEngine on GameEngine {
  bool haremQuestsNeedSync(GameState s) {
    if (!s.seasonal || s.ended) return false;
    if (s.haremVersion < 1 ||
        s.palaceWorks.isNotEmpty ||
        s.palaceEffects.isNotEmpty) {
      return true;
    }
    return s.court.any(
      (c) =>
          c.isConsort &&
          c.available &&
          c.inHarem &&
          c.age >= 18 &&
          ((c.affection >= 60 && haremQuestFor(s, c.id) == null) ||
              (c.queen &&
                  c.affection >= 85 &&
                  haremQuestFor(s, c.id)?.completed == true &&
                  haremQuestFor(s, c.id, queen: true) == null)),
    );
  }

  /// Called only inside a persisted transaction (never from a widget).
  bool prepareHaremQuests(GameState s) {
    if (!s.seasonal || s.ended) return false;
    var changed = false;
    if (s.haremVersion < 1) {
      s.haremVersion = 1;
      final interrupted = s.palaceWorks.length;
      s.palaceWorks.clear();
      s.palaceEffects.clear();
      for (final c in s.court.where((c) => c.isConsort)) {
        c.ability = 0;
        c.palaceExperience = 0;
      }
      s.note(
        'Nhiệm vụ quan hệ hậu cung',
        'Học tập và cung vụ đã kết thúc${interrupted == 0 ? '' : ' ($interrupted công việc cũ được dừng, không thu thêm phí)'}. '
            'Passive chuyển sang điều kiện câu chuyện và thiện cảm; không tự ghi hoàn thành nhiệm vụ. '
            '${haremResidentCount(s) > haremLimit ? 'Bản lưu đang vượt 10 người: giữ nhân vật hiện có, khóa tuyển thêm và chỉ tối đa 10 người đóng góp.' : ''}',
      );
      changed = true;
    }
    // Migration also removes legacy buffs in states created before dispatch.
    if (s.palaceWorks.isNotEmpty || s.palaceEffects.isNotEmpty) {
      s.palaceWorks.clear();
      s.palaceEffects.clear();
      changed = true;
    }
    final residents =
        s.court
            .where(
              (c) => c.isConsort && c.available && c.inHarem && c.age >= 18,
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    for (final c in residents) {
      c.ability = 0;
      if (c.affection >= 60 && haremQuestFor(s, c.id) == null) {
        _assignHaremQuest(s, c, queen: false);
        changed = true;
      }
      if (c.queen &&
          c.affection >= 85 &&
          haremQuestFor(s, c.id)?.completed == true &&
          haremQuestFor(s, c.id, queen: true) == null) {
        _assignHaremQuest(s, c, queen: true);
        changed = true;
      }
    }
    _refreshHaremCommitments(s);
    return changed;
  }

  /// Each entry is a complete, currently legal binding, not just a route ID.
  List<(String, String, List<String>)> _haremBindings(
    GameState s,
    Courtier person,
    HaremQuestDefinition d,
  ) {
    if (!d.conflict) return [('', '', <String>[])];
    if (d.objective == HaremObjective.removeConsort) {
      final contributing =
          HaremBenefits(s).contributions
              .where((x) => x.amount > 0)
              .map((x) => x.person.id)
              .toSet();
      return [
        for (final c in s.court)
          if (c.id != person.id &&
              c.isConsort &&
              c.available &&
              c.inHarem &&
              !c.queen &&
              contributing.contains(c.id))
            (c.id, '', <String>[]),
      ];
    }
    if (!s.hasCourtSystem) return [];
    final result = <(String, String, List<String>)>[];
    for (final office in s.courtOffices) {
      if (office.grade < d.minGrade ||
          office.grade > d.maxGrade ||
          managementPost(office.id) != null ||
          courtRemovalBlocked(s, office) != null) {
        continue;
      }
      final target = courtOfficeHolder(s, office);
      if (target == null ||
          target.isConsort ||
          target.id == person.id ||
          officerBusy(s, target.id)) {
        continue;
      }
      if ([
            HaremObjective.familyOffice,
            HaremObjective.removePower,
          ].contains(d.objective) &&
          target.faction == person.faction) {
        continue;
      }
      if (d.objective == HaremObjective.factionOffice &&
          target.faction != factionOpponents[person.faction]) {
        continue;
      }
      final candidates =
          [...s.court, ...s.officialsPool]
              .where(
                (candidate) =>
                    candidate.id != target.id &&
                    candidate.faction == person.faction &&
                    courtAppointmentBlocked(s, candidate, office) == null,
              )
              .toList();
      if ([
            HaremObjective.familyOffice,
            HaremObjective.factionOffice,
          ].contains(d.objective) &&
          candidates.isEmpty) {
        continue;
      }
      // These candidates are identified as relatives by the authored quest;
      // faction membership alone never establishes a global family relation.
      final family =
          d.objective == HaremObjective.familyOffice
              ? candidates.map((c) => c.id).take(2).toList()
              : <String>[];
      result.add((target.id, office.id, family));
    }
    return result;
  }

  void _assignHaremQuest(GameState s, Courtier c, {required bool queen}) {
    final benefit = haremPassives(c, asQueen: queen).last.benefit;
    // A queen's personal quest still follows her primary passive.
    final selectedBenefit = queen ? benefit : primaryHaremBenefit(c);
    final candidates =
        haremQuestCatalog
            .where(
              (d) =>
                  d.queen == queen &&
                  (d.benefit == null || d.benefit == selectedBenefit) &&
                  (d.foundation || d.traits.any(c.knownPersonalities.contains)),
            )
            .toList();
    final bindings = {
      for (final d in candidates) d.id: _haremBindings(s, c, d),
    };
    final conflicts =
        candidates
            .where((d) => d.conflict && bindings[d.id]!.isNotEmpty)
            .toList();
    final normal = candidates.where((d) => !d.conflict).toList();
    final conflict =
        conflicts.isNotEmpty &&
        _next(s, 100) < haremConflictPercent(c, queen: queen);
    final pool = conflict ? conflicts : normal;
    final used = s.haremQuests.map((q) => q.definitionId).toSet();
    // Integer weights preserve exact halves: matching normal 4, foundation 2;
    // conflicts 2. Previously used routes receive half that weight.
    int weight(HaremQuestDefinition d) {
      final base =
          d.conflict
              ? 2
              : d.traits.any(c.knownPersonalities.contains)
              ? 4
              : 2;
      return used.contains(d.id) ? base ~/ 2 : base;
    }

    var draw = _next(s, pool.fold(0, (sum, d) => sum + weight(d)));
    var selected = pool.first;
    for (final d in pool) {
      draw -= weight(d);
      if (draw < 0) {
        selected = d;
        break;
      }
    }
    final possible = bindings[selected.id]!;
    final binding = possible[_next(s, possible.length)];
    final target = haremQuestPerson(s, binding.$1);
    final faction = switch (selected.factionContext) {
      'owner' => c.faction,
      'opponent' => factionOpponents[c.faction]!,
      _ => target?.faction ?? factionOpponents[c.faction]!,
    };
    final q = HaremQuest(
      personId: c.id,
      definitionId: selected.id,
      assignedTurn: s.week,
      faction: faction,
      queen: queen,
      targetId: binding.$1,
      officeId: binding.$2,
      familyIds: binding.$3,
    );
    s.haremQuests.add(q);
    s.note(
      'Câu chuyện ${queen ? 'Hoàng hậu' : 'cá nhân'}: ${c.name}',
      '${selected.title}. ${haremQuestGoal(s, c, q)}',
    );
  }

  void _haremQuestOrder(GameState s, String personId, String option) {
    final parts = option.split(':');
    if (parts.length != 2 ||
        !['personal', 'queen'].contains(parts[0]) ||
        !['A', 'B', 'refuse', 'resume'].contains(parts[1])) {
      throw const GameRuleException('Lựa chọn nhiệm vụ quan hệ không hợp lệ.');
    }
    final c = _person(s, personId);
    final q = haremQuestFor(s, c.id, queen: parts[0] == 'queen');
    if (q == null) {
      throw const GameRuleException('Chưa đủ điều kiện mở tuyến nhiệm vụ này.');
    }
    final d = haremQuestDefinition(q.definitionId);
    if (!c.inHarem || !c.available || (q.queen && !c.queen)) {
      throw const GameRuleException(
        'Nhân vật không còn giữ thân phận phù hợp với tuyến.',
      );
    }
    final choice = parts[1];
    if (choice == 'resume') {
      if (q.refusedUntil == 0 || s.week < q.refusedUntil) {
        throw const GameRuleException('Chưa đến thời điểm tiếp tục tuyến.');
      }
      q.refusedUntil = 0;
      return;
    }
    if (q.refusedUntil > 0) {
      throw GameRuleException(
        'Đã từ chối. Có thể tiếp tục cùng tuyến từ ${s.date(q.refusedUntil)}.',
      );
    }
    if (choice == 'refuse') {
      if (!d.conflict || q.completed) {
        throw const GameRuleException('Không thể từ chối tuyến này.');
      }
      c.affection -= q.queen ? 12 : 8;
      q.refusedUntil = s.week + 2;
      s.note(
        'Từ chối: ${d.title}',
        '${c.name}: ${c.affection == 100 ? 'thiện cảm giữ ở 100' : 'thiện cảm −${q.queen ? 12 : 8}'}. '
            'Giữ tiến độ, không đổi tuyến; có thể tiếp tục từ ${s.date(q.refusedUntil)}.',
        'warning',
      );
      return;
    }
    final blocked = haremChapterBlocked(s, c, q, choice);
    if (blocked != null) throw GameRuleException(blocked);
    final chapter = d.chapters[q.stage];
    final cost = haremChapterCost(s, q, choice);
    _spend(
      s,
      cost,
      title: '${c.name}: ${chapter.title}',
      category: 'harem-quest',
      detail:
          '${d.title} · chương ${q.stage + 1}/3 · lựa chọn $choice. '
          '${haremChoiceConsequence(s, q, choice)}',
    );
    if (!d.conflict && choice == 'B') {
      if (q.stage < 2) {
        s.factions[q.faction] = s.factions[q.faction]! - d.factionLoss ~/ 2;
      } else if (d.stat == 'authority') {
        s.authority -= d.statLoss;
      } else {
        s.stability -= d.statLoss;
      }
    }
    q.choices.add(choice);
    q.stage++;
    q.lastChapterTurn = s.week;
    s.haremChapterTurns[c.id] = s.week;
    s.workThisWeek++;
    // Harem interaction does not excuse neglect of national affairs.
    if (q.completed) q.completedTurn = s.week;
    s.note(
      q.completed
          ? 'Hoàn thành: ${d.title}'
          : '${d.title} · chương ${q.stage}/3',
      '${c.name}: ${choice == 'A' ? chapter.choiceA : chapter.choiceB}. '
      'Chi ${moneyText(s, cost)}, 1 hành động. '
      '${q.completed ? (haremPassiveBlocked(s, c, queen: q.queen) ?? 'Passive đủ điều kiện hoạt động; vẫn chịu trần toàn hậu cung.') : 'Lựa chọn được lưu cho chương tiếp theo.'}',
      q.completed ? 'gold' : 'info',
    );
  }

  void _refreshHaremCommitments(GameState s) {
    for (final q in s.haremQuests) {
      if (!haremQuestDefinition(q.definitionId).conflict || q.stage < 2) {
        continue;
      }
      if (!haremCommitmentMet(s, q)) {
        q.commitmentSince = 0;
        q.verifiedSeasons = 0;
      } else if (q.commitmentSince == 0 && _haremQuestRoleActive(s, q)) {
        q.commitmentSince = s.week;
        q.verifiedSeasons = 0;
      }
    }
  }

  void _settleHaremQuests(GameState s) {
    _refreshHaremCommitments(s);
    for (final q in s.haremQuests) {
      if (q.commitmentSince > 0 && haremCommitmentMet(s, q)) {
        if (_haremQuestRoleActive(s, q)) {
          q.verifiedSeasons = (s.week - q.commitmentSince).clamp(0, 1000000);
        } else {
          // A role change pauses verification, but does not erase a fulfilled
          // story or count seasons spent outside that role.
          q.commitmentSince++;
        }
      }
    }
  }

  bool _haremQuestRoleActive(GameState s, HaremQuest q) {
    final c = haremQuestPerson(s, q.personId);
    return c != null && c.available && c.inHarem && (!q.queen || c.queen);
  }
}

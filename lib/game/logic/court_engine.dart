part of 'game_engine.dart';

extension CourtEngine on GameEngine {
  void _dismissOffice(GameState s, String officeId) {
    final office = s.courtOffices.where((o) => o.id == officeId).firstOrNull;
    if (office == null) {
      throw const GameRuleException('Chức vụ không còn hợp lệ.');
    }
    final reason = courtDismissalBlocked(s, office);
    if (reason != null) throw GameRuleException(reason);
    final old = courtOfficeHolder(s, office)!;
    _spend(
      s,
      0,
      title: 'Cho hồi hương ${old.name}',
      category: 'character',
      detail:
          'Thôi chức ${office.role}, để trống tới khi vua bổ nhiệm người mới.',
    );
    office.holderId = '';
    office.appointedTurn = s.week;
    s.court.remove(old);
    old.role = 'Đã hồi hương';
    old.retired = true;
    s.officialsPool.add(old);
    if (old.id == s.heirId) {
      s.heirCondition = 'withdrawn';
      s.successionCertified = false;
    }
    s.stability -= courtOfficeDisruption(office);
    s.factions[old.faction] = s.factions[old.faction]! - 4;
    if (old.influence >= 60) {
      s.obligations.add(
        Obligation(
          id: 'dismiss-${s.revision}',
          kind: 'resentment',
          title: 'Phe ${old.faction} phản ứng việc cho ${old.name} hồi hương',
          remaining: 1,
          nextWeek: s.week + 1,
          effects: {'faction:${old.faction}': -1},
        ),
      );
    }
    s.workThisWeek++;
    s.affairsThisWeek++;
    final penalty = courtVacancyEffects(office);
    s.note(
      'Cho hồi hương ${old.name}',
      '${office.role} đang bỏ trống, không tự bổ nhiệm người thay. '
          '${old.name} hồi hương, giữ phẩm và công trạng. '
          'Chi 1 hành động, không chi ngân khố; ổn định −${courtOfficeDisruption(office)}, phe ${old.faction} −4. '
          '${penalty.isEmpty ? '' : 'Mỗi mùa bỏ trống: $penalty.'}',
      'warning',
    );
  }

  void _promoteCourtier(
    GameState s,
    String id,
    String destination, {
    bool exceptional = false,
  }) {
    final c = courtPerson(s, id);
    if (c == null) throw const GameRuleException('Quan không còn hiện diện.');
    final grade = int.tryParse(destination) ?? 0;
    final blocked = courtPromotionBlocked(
      s,
      c,
      grade,
      exceptional: exceptional,
    );
    if (blocked != null) throw GameRuleException(blocked);
    final quote = CourtPromotion(s, c, grade);
    final before = c.grade;
    final affection = quote.actualAffection(c),
        discontent = quote.actualDiscontent(c);
    _spend(
      s,
      quote.cost,
      title: 'Sắc phong ${c.name}',
      category: 'character',
      detail:
          '${courtGradeName(before)} → ${courtGradeName(grade)}; sử dụng ${quote.merit} công trạng.',
    );
    c.merit -= quote.merit;
    c.meritSpent += quote.merit;
    c.grade = grade;
    c.affection += affection;
    c.discontent -= discontent;
    c.influence = (c.influence + quote.influence).clamp(0, 100);
    s.workThisWeek++;
    s.affairsThisWeek++;
    s.note(
      'Sắc phong ${c.name}',
      '${courtGradeName(before)} → ${courtGradeName(grade)}. '
          'Chi ${moneyText(s, quote.cost)}; dùng ${quote.merit} công trạng, còn ${c.merit}. '
          'Thiện cảm +$affection, bất mãn −$discontent; chức vụ và chuyên môn giữ nguyên.',
      'gold',
    );
  }

  void _appointOffice(
    GameState s,
    String officeId,
    String candidateId, {
    bool swap = false,
    String backfillId = '',
  }) {
    if (!s.hasCourtSystem) {
      throw const GameRuleException('Lượt này dùng bộ luật bổ nhiệm cũ.');
    }
    if (managementPost(officeId) != null) {
      if (swap || backfillId.isNotEmpty) {
        throw const GameRuleException(
          'Vị trí quản lý không đổi chỗ hoặc bổ khuyết kèm theo.',
        );
      }
      _appointManager(s, officeId, candidateId);
      return;
    }
    final office = s.courtOffices.where((o) => o.id == officeId).firstOrNull;
    final candidate = courtPerson(s, candidateId);
    if (office == null || candidate == null) {
      throw const GameRuleException('Vị trí hoặc ứng viên không còn hợp lệ.');
    }
    final blocked = courtAppointmentBlocked(s, candidate, office);
    if (blocked != null) throw GameRuleException(blocked);
    final source = courtOfficeFor(s, candidate.id);
    if (swap && source != null && managementPost(source.id) != null) {
      throw const GameRuleException('Vị trí quản lý không đổi chỗ hai quan.');
    }
    final old = courtOfficeHolder(s, office);
    Courtier? backfill;
    if (backfillId.isNotEmpty) {
      if (source != null && managementPost(source.id) != null) {
        throw const GameRuleException(
          'Hãy bổ nhiệm riêng người quản lý cho vị trí bỏ trống.',
        );
      }
      backfill =
          s.officialsPool
              .where((c) => c.id == backfillId && c.available)
              .firstOrNull;
      if (swap ||
          source == null ||
          backfill == null ||
          backfill.id == candidate.id) {
        throw const GameRuleException(
          'Người bổ khuyết phải ở danh sách chờ và nhận một vị trí khác.',
        );
      }
      final reason = courtAppointmentBlocked(s, backfill, source);
      if (reason != null) throw GameRuleException(reason);
    }
    if (swap) {
      if (source == null || old == null) {
        throw const GameRuleException('Đổi chỗ cần hai quan đang tại chức.');
      }
      final reason = courtAppointmentBlocked(s, old, source);
      if (reason != null) throw GameRuleException(reason);
    }
    final disruption = courtAppointmentDisruption(s, candidate, office);
    final price =
        courtAppointmentCost(s, candidate, office) +
        (swap ? courtAppointmentCost(s, old!, source!) : 0) +
        (backfill != null ? courtAppointmentCost(s, backfill, source!) : 0);
    _spend(
      s,
      price,
      points: swap || backfill != null ? 2 : 1,
      title: '${swap ? 'Đổi chức' : 'Bổ nhiệm'} ${candidate.name}',
      category: 'character',
      detail:
          '${candidate.name} nhận chức ${office.role} (${courtGradeName(office.grade)}).',
    );
    if (source != null) {
      source.holderId = '';
      source.appointedTurn = s.week;
    }
    if (old != null) {
      if (swap) {
        source!.holderId = old.id;
        old.role = source.role;
        old.courtGroup = source.group;
      } else {
        s.court.remove(old);
        old.role = 'Chờ bổ nhiệm';
        s.officialsPool.add(old);
        if (old.id == s.heirId) {
          s.heirCondition = 'withdrawn';
          s.successionCertified = false;
        }
      }
      if (old.influence >= 60 && !swap) {
        s.obligations.add(
          Obligation(
            id: 'dismiss-${s.revision}',
            kind: 'resentment',
            title:
                'Phe ${old.faction} phản ứng việc ${old.name} rời chức ${office.role}',
            remaining: 1,
            nextWeek: s.week + 1,
            effects: {'faction:${old.faction}': -1},
          ),
        );
      }
      if (old.faction != candidate.faction) {
        s.factions[old.faction] = s.factions[old.faction]! - 4;
      }
      if (swap) {
        if (old.faction != candidate.faction) {
          s.factions[candidate.faction] = s.factions[candidate.faction]! - 4;
        }
        _favorFaction(s, old.faction, 5, 2);
      }
    }
    s.officialsPool.remove(candidate);
    if (!s.court.any((c) => c.id == candidate.id)) s.court.add(candidate);
    candidate.role = office.role;
    candidate.courtGroup = office.group;
    office.holderId = candidate.id;
    office.appointedTurn = s.week;
    if (backfill != null) {
      s.officialsPool.remove(backfill);
      s.court.add(backfill);
      backfill.role = source!.role;
      backfill.courtGroup = source.group;
      source.holderId = backfill.id;
      source.appointedTurn = s.week;
      _favorFaction(s, backfill.faction, 5, 2);
    }
    s.stability -= disruption;
    candidate.retired = false;
    if (backfill != null) backfill.retired = false;
    s.authority++;
    s.workThisWeek++;
    s.affairsThisWeek++;
    _favorFaction(s, candidate.faction, 5, 2);
    // Keep a useful minimum supply without deleting dismissed characters.
    while (s.officialsPool.where((c) => c.available && !c.retired).length <
        12) {
      s.officialsPool.add(_newOfficialCandidate(s));
    }
    s.note(
      swap ? 'Điều chuyển hai quan' : 'Bổ nhiệm ${candidate.name}',
      '${candidate.name} giữ chức ${office.role} (${courtGradeName(office.grade)}). '
          '${swap
              ? '${old!.name} nhận chức ${source!.role}.'
              : old == null
              ? 'Bổ khuyết chức đang trống.'
              : '${old.name} về danh sách chờ bổ nhiệm, giữ nguyên phẩm và công trạng.'} '
          '${source != null && !swap
              ? backfill == null
                  ? '${source.role} đang bỏ trống; cần bổ khuyết.'
                  : '${backfill.name} bổ khuyết chức ${source.role}.'
              : ''} '
          'Chi ${moneyText(s, price)}; ổn định −$disruption. Passive của vị trí mới được xét từ ${s.date(s.week + 1)}.',
      'warning',
    );
  }

  void _settleCourtPassives(GameState s) {
    if (!s.hasCourtSystem || !s.seasonal || s.lastCourtPassiveTurn >= s.week) {
      return;
    }
    _clamp(s);
    final effects =
        <
          ({
            CourtOffice office,
            Courtier? holder,
            CourtBenefit benefit,
            int change,
          })
        >[];
    for (final office in s.courtOffices) {
      final direction = courtOfficeDirection(s, office);
      if (direction == 0) continue;
      for (final benefit in courtPassives(office)) {
        effects.add((
          office: office,
          holder: courtOfficeHolder(s, office),
          benefit: benefit,
          change: direction * (benefit == CourtBenefit.fatigue ? -1 : 1),
        ));
      }
    }
    final lines = <String>[];
    // Cancel gains and vacancy losses before applying a stat's bounds. This
    // keeps +1 and -1 neutral even at 0/100, independent of office ordering.
    for (final benefit in CourtBenefit.values) {
      final entries = effects.where((e) => e.benefit == benefit).toList();
      if (entries.isEmpty) continue;
      final requested = entries.fold<int>(0, (sum, e) => sum + e.change);
      final applied = _applyCourtBenefit(s, benefit, requested);
      num positive = entries.where((e) => e.change > 0).length;
      num negative = entries.where((e) => e.change < 0).length;
      if (applied < requested) {
        positive = math.max(0, positive - (requested - applied));
      }
      if (applied > requested) {
        negative = math.max(0, negative - (applied - requested));
      }
      for (final entry in entries) {
        num actual;
        if (entry.change > 0) {
          actual = math.min(1, positive);
          positive -= actual;
        } else {
          actual = -math.min(1, negative);
          negative += actual;
        }
        if (benefit == CourtBenefit.tax) actual *= .75;
        if (actual == 0) actual = 0; // Normalize negative floating-point zero.
        lines.add(
          '${entry.office.role} · ${entry.holder?.name ?? 'Bỏ trống'}: ${benefit.label} ${actual >= 0 ? '+' : ''}$actual${benefit == CourtBenefit.tax ? '%' : ''}.',
        );
      }
    }
    s.lastCourtPassiveTurn = s.week;
    if (lines.isNotEmpty) s.note('Đóng góp bộ máy', lines.join('\n'), 'gold');
  }

  num _applyCourtBenefit(GameState s, CourtBenefit benefit, int change) {
    num delta(num current) => (current + change).clamp(0, 100) - current;
    switch (benefit) {
      case CourtBenefit.stability:
        final actual = delta(s.stability).toInt();
        s.stability += actual;
        return actual;
      case CourtBenefit.authority:
        final actual = delta(s.authority).toInt();
        s.authority += actual;
        return actual;
      case CourtBenefit.morale:
        if (s.population == null) return 0;
        final before = s.population!.morale;
        s.population!.changeMorale(change.toDouble());
        return s.population!.morale - before;
      case CourtBenefit.training:
        if (s.population == null) return 0;
        final before = s.population!.training;
        s.population!.changeTraining(change.toDouble());
        return s.population!.training - before;
      case CourtBenefit.logistics:
        if (s.population == null) return 0;
        final actual = delta(s.population!.logistics);
        s.population!.logistics += actual;
        return actual;
      case CourtBenefit.fatigue:
        final actual = delta(s.fatigue).toInt();
        s.fatigue += actual;
        return actual;
      case CourtBenefit.tax:
        final year = '${courtTaxYear(s)}',
            before = s.courtTaxSeasons['${courtTaxYear(s)}'] ?? 0;
        s.courtTaxSeasons[year] = (before + change).clamp(-4, 4);
        return s.courtTaxSeasons[year]! - before;
      case CourtBenefit.royalMood:
        final actual = delta(s.factions['Hoàng tộc']!).toInt();
        s.factions['Hoàng tộc'] = s.factions['Hoàng tộc']! + actual;
        return actual;
    }
  }
}

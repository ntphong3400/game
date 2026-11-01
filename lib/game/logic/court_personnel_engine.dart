part of 'game_engine.dart';

extension CourtPersonnelEngine on GameEngine {
  void _resolveCourtPersonnel(
    GameState s,
    Petition p,
    String option,
    String nomineeId,
  ) {
    final m = courtMatterForEvent(s, p.definitionId);
    final index = int.tryParse(option);
    if (m == null || index == null) {
      throw const GameRuleException('Tấu nhân sự không còn hợp lệ.');
    }
    final reason = courtPersonnelChoiceBlocked(
      s,
      m,
      index,
      nomineeId: nomineeId,
    );
    if (reason != null) throw GameRuleException(reason);
    if (!courtMatterNeedsNominee(m, index) && nomineeId.isNotEmpty) {
      throw const GameRuleException('Phương án này không chọn ứng viên khác.');
    }
    final e = courtPersonnelEvent(s, m, nomineeId: nomineeId);
    final choice = e.choices[index];
    final sponsor = courtPerson(s, m.sponsorId);
    if (courtMatterAppoints(m, index)) {
      final candidate = courtMatterCandidate(s, m, index, nomineeId)!;
      if (courtMatterFillsVacancy(s, m, index)) {
        _appointVacancyNominee(s, courtMatterOffice(s, m)!, candidate);
      } else {
        _appointOffice(s, m.officeId, candidate.id);
      }
      m.personId = candidate.id;
      m.status = 'watching';
      m.acceptedTurn = s.week;
    } else if (m.kind == 'retire' && index == 0) {
      _dismissOffice(s, m.officeId);
      if (sponsor != null) {
        s.factions[sponsor.faction] = s.factions[sponsor.faction]! + 3;
      }
      m.status = 'completed';
    } else if (['promote', 'patronage'].contains(m.kind) && index == 0) {
      _promoteCourtier(
        s,
        m.personId,
        '${m.targetGrade}',
        exceptional: m.kind == 'patronage',
      );
      _apply(s, choice.effects, title: e.title, detail: choice.label);
      m.status = 'completed';
    } else {
      _spend(
        s,
        choice.cost,
        points: 1,
        title: e.title,
        category: 'event',
        detail: choice.label,
      );
      s.workThisWeek++;
      s.affairsThisWeek++;
      _apply(s, choice.effects, title: e.title, detail: choice.label);
      if (courtMatterTrains(m, index)) {
        m.personId = courtOfficeHolder(s, courtMatterOffice(s, m)!)!.id;
        m.status = 'training';
        m.acceptedTurn = s.week;
      } else if (index == 1 &&
          ['retire', 'recruit'].contains(m.kind) &&
          !m.verified) {
        m.verified = true;
        p.deadline = s.week + 1;
        s.note(
          'Đã đối chiếu hồ sơ',
          '${e.title}: năng lực và chuyên môn đã được đối chiếu. Không kết luận về phẩm chất ẩn hoặc sai phạm. Tấu được giữ tới cuối mùa sau.',
        );
        return;
      } else {
        m.status = index == courtMatterLastChoice(m) ? 'rejected' : 'deferred';
      }
    }
    s.petitions.remove(p);
    s.note(e.title, '${choice.label}. ${choice.hint}');
  }

  void _appointVacancyNominee(GameState s, CourtOffice office, Courtier c) {
    final reason = vacancyNominationBlocked(s, c, office);
    if (reason != null) throw GameRuleException(reason);
    final quote = vacancyPromotion(s, c, office);
    final source = courtOfficeFor(s, c.id);
    final before = c.grade;
    _spend(
      s,
      quote.cost,
      title: 'Bổ khuyết ${office.role}',
      category: 'character',
      detail:
          '${c.name}: ${courtGradeName(before)} → ${courtGradeName(quote.target)}; ${quote.merit} công trạng.',
    );
    if (source != null) {
      source.holderId = '';
      source.appointedTurn = s.week;
    }
    if (c.grade > office.grade) {
      c.grade = office.grade;
      c.merit -= quote.merit;
      c.meritSpent += quote.merit;
      c.affection += quote.actualAffection(c);
      c.discontent -= quote.actualDiscontent(c);
      c.influence = (c.influence + quote.influence).clamp(0, 100);
    }
    s.officialsPool.remove(c);
    if (!s.court.any((p) => p.id == c.id)) s.court.add(c);
    c.role = office.role;
    c.courtGroup = office.group;
    c.retired = false;
    office.holderId = c.id;
    office.appointedTurn = s.week;
    s.workThisWeek++;
    s.affairsThisWeek++;
    s.note(
      'Bổ khuyết ${office.role}',
      '${c.name} nhận chức, giữ ${courtGradeName(c.grade)}. '
          'Chi ${moneyText(s, quote.cost)} và 1 hành động; dùng ${quote.merit} công trạng. '
          'Miễn điều kiện năng lực và thiện cảm khi bổ nhiệm; passive vẫn xét điều kiện thông thường.'
          '${source == null ? '' : ' Chức ${source.role} để trống.'}',
      'gold',
    );
  }

  void _refreshCourtPersonnel(GameState s) {
    if (!s.hasCourtSystem) return;
    for (final m in s.courtPersonnelMatters) {
      String? reason;
      if (m.status == 'open') {
        reason = courtMatterInvalid(s, m);
      } else if (m.status == 'watching' || m.status == 'training') {
        final office = courtMatterOffice(s, m);
        final c = courtPerson(s, m.personId);
        if (office == null || c == null || office.holderId != c.id) {
          reason = 'Người liên quan đã rời vị trí trước khi có kết quả.';
        }
      }
      if (reason == null) continue;
      m.status = 'closed';
      s.petitions.removeWhere((p) => p.definitionId == m.eventId);
      s.note(
        'Khép tấu nhân sự',
        '$reason Không thu thêm chi phí hoặc trao thưởng.',
        'warning',
      );
    }
  }

  void _settleCourtPersonnel(GameState s) {
    _refreshCourtPersonnel(s);
    for (final m in s.courtPersonnelMatters.where(
      (m) =>
          ['watching', 'training'].contains(m.status) &&
          m.acceptedTurn < s.week,
    )) {
      final office = courtMatterOffice(s, m)!;
      final c = courtPerson(s, m.personId)!;
      if (m.status == 'training') {
        c.ability = (c.ability + 2).clamp(0, 100);
        c.affection += 2;
        m.status = 'completed';
        s.note(
          'Hoàn tất bồi dưỡng',
          '${c.name}: năng lực +2, thiện cảm +2; trở lại công vụ. Passive tiếp tục xét đúng ngưỡng của chức ${office.role}.',
          'gold',
        );
      } else {
        // One full season in the same appointment. No reward for moving away
        // and returning, and no duplicate credit for the same person/office.
        final qualified =
            office.appointedTurn < s.week && courtNomineeQualified(c, office);
        m.status = qualified ? 'completed' : 'unqualified';
        if (qualified && s.courtPersonnelRewarded.add(m.rewardKey)) {
          final sponsor = courtPerson(s, m.sponsorId);
          if (sponsor != null && sponsor.id != c.id) {
            _merit(
              s,
              sponsor,
              points: 2,
              title: 'Tiến cử ${c.name} giữ chức ${office.role}',
              eventId: 'nomination:${m.rewardKey}',
            );
          }
          s.authority++;
          s.note(
            'Tiến cử có kết quả',
            '${c.name} giữ chức ${office.role} trọn mùa và đạt yêu cầu. Uy quyền +1${sponsor == null || sponsor.id == c.id ? '' : '; ${sponsor.name} +2 công trạng'}.',
            'gold',
          );
        } else {
          s.note(
            'Đánh giá người được tiến cử',
            qualified
                ? 'Người và vị trí này đã được ghi công trước đó; không thưởng lặp.'
                : '${c.name} chưa đạt yêu cầu của chức ${office.role}; không ghi công tiến cử.',
            'warning',
          );
        }
      }
    }
  }

  void _generateCourtPersonnel(GameState s) {
    if (!s.hasCourtSystem ||
        !s.seasonal ||
        s.ended ||
        s.week < s.nextCourtPersonnelTurn ||
        s.courtPersonnelMatters.any((m) => m.status == 'open')) {
      return;
    }
    final sponsors =
        s.court
            .where((c) => c.available && !c.isConsort && c.age >= 18)
            .toList();
    if (sponsors.isEmpty) return;
    final offers = <CourtPersonnelMatter>[];
    final id = 'personnel-${s.week}-${s.courtPersonnelMatters.length}';
    Courtier sponsorFor(Courtier c, {bool opposing = false}) {
      final pool =
          sponsors
              .where(
                (a) =>
                    a.id != c.id &&
                    (!opposing || a.faction == factionOpponents[c.faction]),
              )
              .toList();
      return (pool.isEmpty ? sponsors : pool)[_next(
        s,
        pool.isEmpty ? sponsors.length : pool.length,
      )];
    }

    CourtPersonnelMatter offer(
      String kind,
      Courtier c, {
      CourtOffice? office,
      int target = 0,
      bool opposing = false,
    }) {
      final sponsor = sponsorFor(c, opposing: opposing);
      return CourtPersonnelMatter(
        id: id,
        kind: kind,
        personId: c.id,
        sponsorId: sponsor.id,
        openedTurn: s.week,
        officeId: office?.id ?? '',
        holderId: office?.holderId ?? '',
        targetGrade: target,
      );
    }

    final people =
        [...s.court, ...s.officialsPool]
            .where(
              (c) => c.available && !c.isConsort && !c.retired && c.age >= 18,
            )
            .toList();
    final vacancies =
        s.courtOffices.where((o) => courtOfficeHolder(s, o) == null).toList();
    for (final office in vacancies) {
      final candidates =
          people
              .where((c) => vacancyNominationBlocked(s, c, office) == null)
              .toList()
            ..sort((a, b) => b.ability.compareTo(a.ability));
      if (candidates.isNotEmpty) {
        offers.add(offer('nominate', candidates.first, office: office));
        offers.add(offer('nominate', candidates.first, office: office));
      }
    }
    for (final office in s.courtOffices) {
      final c = courtOfficeHolder(s, office);
      if (c == null) continue;
      if (courtDismissalBlocked(s, office) == null &&
          sponsors.any((a) => a.faction == factionOpponents[c.faction])) {
        offers.add(offer('retire', c, office: office, opposing: true));
      }
      if (courtPassives(office).isNotEmpty &&
          (c.ability < (office.grade == 1 ? 90 : 80) ||
              c.affection < (office.grade == 1 ? 80 : 70))) {
        final candidates =
            people
                .where(
                  (a) =>
                      a.id != c.id &&
                      courtNomineeQualified(a, office) &&
                      courtAppointmentBlocked(s, a, office) == null,
                )
                .toList()
              ..sort((a, b) => b.ability.compareTo(a.ability));
        // Training remains available even when authority prevents replacement.
        final nominee = candidates.isEmpty ? c : candidates.first;
        if (candidates.isNotEmpty ||
            (!officerBusy(s, c.id) && s.treasury >= money(s, 12))) {
          offers.add(offer('reform', nominee, office: office));
        }
      }
    }
    for (final c in people.where((c) => c.grade > 1)) {
      final target = c.grade - 1;
      if (courtPromotionBlocked(s, c, target) == null) {
        offers.add(offer('promote', c, target: target));
      } else if (c.ability < promotionAbility[target]! &&
          courtPromotionBlocked(s, c, target, exceptional: true) == null) {
        offers.add(offer('patronage', c, target: target));
      }
    }
    // New people enter at a junior office's grade; existing people never get
    // free rank, merit or a new identity. Limit new discoveries to one/year.
    final recruitOffices =
        vacancies.where((o) => !o.royalOnly && o.grade >= 5).toList();
    if (recruitOffices.isNotEmpty &&
        s.lastCourtRecruitYear != s.year &&
        s.treasury >= money(s, 20) &&
        _next(s, 3) == 0) {
      final office = recruitOffices[_next(s, recruitOffices.length)];
      final candidate =
          _newOfficialCandidate(s)
            ..grade = office.grade
            ..ability = 75 + _next(s, 21)
            ..specialty = specialtyForRole(office.role);
      s.officialsPool.add(candidate);
      s.lastCourtRecruitYear = s.year;
      offers.clear();
      offers.add(offer('recruit', candidate, office: office));
    }
    if (offers.isEmpty) return;
    final m = offers[_next(s, offers.length)];
    s.courtPersonnelMatters.add(m);
    s.petitions.add(
      Petition(
        id: m.id,
        definitionId: m.eventId,
        openedWeek: s.week,
        deadline: s.week + 1,
        targetId: m.personId,
      ),
    );
    s.nextCourtPersonnelTurn = s.week + 1 + _next(s, 2);
    s.note('Tấu nhân sự mới', courtPersonnelEvent(s, m).title);
  }
}

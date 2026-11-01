part of 'game_engine.dart';

extension AssignedPetitions on GameEngine {
  PetitionAssignment _startPetitionAssignment(
    GameState s,
    EventDefinition e,
    EventChoice c,
    Courtier? person,
    int chance,
  ) {
    final roll = _next(s, 100);
    final kind =
        c.effects.containsKey('repair') ? 'petitionRepair' : c.followup;
    final margin =
        person == null
            ? 15
            : petitionAssessment(s, e, c, person).personality.severeMargin;
    final n = roll >= chance + margin ? 2 : 1;
    final failure =
        c.laterEffects.isNotEmpty
            ? Map<String, int>.of(c.laterFailureEffects)
            : switch (kind) {
              'petitionRepair' => {
                'levee': -4 * n,
                'people': -2 * n,
                if (n == 2) 'authority': -3,
                if (n == 2) 'treasury': -15,
              },
              'envoy' => {
                'war': n,
                'authority': -2 * n,
                if (n == 2) 'treasury': -20,
              },
              _ => <String, int>{},
            };
    final assignment = PetitionAssignment(
      eventId: e.id,
      meritId: s.hasCourtSystem ? 'petition-${s.revision}-${e.id}' : '',
      assigneeId: person?.id ?? '',
      assigneeName: person?.name ?? '',
      specialty: petitionSpecialty(e, c),
      chance: chance,
      succeeded: roll < chance,
      failureEffects: failure,
      auditRecoveryMinimum: petitionAuditMinimum,
      auditRecoveryMaximum: petitionAuditMaximum,
    );
    if (person != null) _assignOfficer(s, person);
    return assignment;
  }

  void _queuePetitionResult(
    GameState s,
    EventDefinition e,
    EventChoice c,
    PetitionAssignment? assignment,
  ) {
    if (c.followup.isNotEmpty) {
      s.pending.add(
        Consequence(
          kind: c.followup,
          dueWeek: s.week + petitionDelay(s, c) - 1,
          title: e.title,
          detail: c.label,
          assignment: assignment,
        ),
      );
    }
    if (assignment != null && c.effects.containsKey('repair')) {
      s.pending.add(
        Consequence(
          kind: 'petitionRepair',
          dueWeek: s.week + s.workTurns(4) - 1,
          title: e.title,
          detail: c.label,
          assignment: assignment,
        ),
      );
    }
    _scheduleEventOutcome(s, e, c, assignment: assignment);
  }

  String _resolveAssignedPetition(GameState s, Consequence p) {
    final a = p.assignment!;
    final person =
        a.assigneeId.isEmpty
            ? null
            : s.court
                .where(
                  (c) =>
                      c.id == a.assigneeId &&
                      c.available &&
                      c.age >= 18 &&
                      (!c.isConsort || c.inHarem),
                )
                .firstOrNull;
    final interrupted = a.assigneeId.isNotEmpty && person == null;
    final status =
        interrupted
            ? 'interrupted'
            : a.succeeded
            ? 'success'
            : 'failure';
    final intro =
        '${p.detail} · ${a.personLabel} · tỷ lệ đã chốt ${a.chance}%.';
    if (interrupted || !a.succeeded) {
      final effects =
          interrupted && p.kind == 'envoy'
              ? {'authority': -2}
              : a.failureEffects;
      _apply(s, effects, title: p.title, detail: intro, category: 'outcome');
      s.note(
        'Kết quả: ${p.title}',
        '$intro ${interrupted ? 'Người được giao không còn đủ điều kiện, công việc gián đoạn.' : 'Công việc không thành công.'} ${eventEffectText(effects)}. Kinh phí đã cấp không hoàn lại.',
        'warning',
      );
      return status;
    }
    var result = '';
    switch (p.kind) {
      case 'eventOutcome':
        _apply(
          s,
          p.effects,
          title: p.title,
          detail: intro,
          category: 'outcome',
        );
        result = eventEffectText(p.effects);
      case 'audit':
        final recovered = money(
          s,
          a.auditRecoveryMinimum +
              _next(s, a.auditRecoveryMaximum - a.auditRecoveryMinimum + 1),
        );
        _postMoney(
          s,
          recovered,
          title: 'Thu hồi tiền thất thoát',
          detail: intro,
          category: 'outcome',
        );
        s.authority += 2;
        result = 'Ngân khố +$recovered · uy quyền +2';
      case 'security':
        for (final suspect in s.court.where(
          (c) => c.available && (!c.isConsort || c.inHarem),
        )) {
          suspect.plot = math.max(0, suspect.plot - 6);
        }
        _respond(s, 'plot');
        result = 'Mỗi âm mưu đang hoạt động giảm tối đa 6 tiến độ';
      case 'envoy':
      case 'petitionRepair':
        final assessment =
            person == null
                ? null
                : TaskAssessment.forSpecialty(
                  petitionTask(a.specialty),
                  person,
                  a.specialty,
                  s,
                  knownOnly: true,
                );
        final delivery =
            person == null ? 100 : _deliveryPercent(s, person, p.title);
        int reward(int base) =>
            ((assessment?.reward(base) ?? base) * delivery / 100).round();
        if (p.kind == 'envoy') {
          final war = reward(3), authority = reward(2);
          s.war = math.max(0, s.war - war);
          s.siege = 0;
          s.authority += authority;
          _respond(s, 'border');
          result =
              'Áp lực chiến tranh −$war · uy quyền +$authority · giải vây kinh thành';
        } else {
          final levee = reward(30);
          s.levee += levee;
          result = 'Đê điều +$levee';
        }
        if (!s.hasCourtSystem && person != null && !person.isConsort) {
          _merit(s, person);
        }
      default:
        throw StateError('Unknown assigned petition ${p.kind}');
    }
    if (s.hasCourtSystem &&
        person != null &&
        !person.isConsort &&
        a.meritId.isNotEmpty &&
        !s.pending.any((other) => other.assignment?.meritId == a.meritId)) {
      _merit(s, person, title: p.title, eventId: a.meritId);
    }
    s.note('Kết quả: ${p.title}', '$intro Thành công. $result.', 'gold');
    return status;
  }
}

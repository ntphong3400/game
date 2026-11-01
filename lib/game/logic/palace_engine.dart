part of 'game_engine.dart';

extension PalaceEngine on GameEngine {
  void _palaceOrder(GameState s, String personId, String option) {
    final parts = option.split(':');
    final kind = parts.first;
    final duty = palaceDuty(kind);
    if (parts.length > 2 ||
        (kind != 'study' && duty == null) ||
        (kind != 'kinship' && parts.length != 1)) {
      throw const GameRuleException('Học tập hoặc cung vụ không hợp lệ.');
    }
    final c = _person(s, personId);
    final reason =
        palacePersonUnavailable(s, c, duty: duty) ??
        (duty == null ? null : palaceDutyUnavailable(s, duty));
    if (reason != null) throw GameRuleException(reason);
    final faction = parts.length == 2 ? parts[1] : '';
    if (kind == 'kinship' && !factionOpponents.containsKey(faction)) {
      throw const GameRuleException('Hãy chọn gia quyến của một phe.');
    }
    final cost = duty == null ? money(s, 20) : palaceDutyCost(s, duty);
    final duration = duty?.duration ?? 2;
    _spend(
      s,
      cost,
      grain: duty == null ? 0 : palaceDutyFood(s, duty),
      title: '${palaceWorkTitle(kind)}: ${c.name}',
      category: 'palace',
      detail:
          '$cost ${moneyUnit(s)}${duty != null && duty.grain > 0 ? ', ${palaceDutyFood(s, duty)} ${foodUnit(s)}' : ''}; '
          '1 hành động, $duration mùa. Hoàn tất cuối ${s.date(s.week + duration - 1)}. '
          'Trả một lần, không thu phí duy trì riêng.',
    );
    if (duty != null) {
      final discount = palaceEffect(s, 'procurement');
      if (discount != null && discount.uses > 0) discount.uses--;
    }
    s.workThisWeek++;
    s.palaceWorks.add(
      PalaceWork(
        id: '${s.runId}-palace-${s.revision}',
        kind: kind,
        personId: c.id,
        startedTurn: s.week,
        duration: duration,
        faction: faction,
      ),
    );
    s.note(
      '${palaceWorkTitle(kind)}: ${c.name}',
      'Đã chi $cost ${moneyUnit(s)}${duty != null && duty.grain > 0 ? ' và ${palaceDutyFood(s, duty)} ${foodUnit(s)}' : ''}, '
          '1 hành động. Hoàn tất cuối ${s.date(s.week + duration - 1)}. '
          '${duty == null ? 'Khóa học bảo đảm nhận ${studyExperience(c)} kinh nghiệm theo năng lực lúc hoàn tất.' : '${duty.benefit} ${duty.risk}'} '
          'Trong thời gian này không thể học hoặc nhận thêm cung vụ.',
    );
  }

  int _palaceLearn(Courtier c, int xp) {
    final before = c.ability;
    c.palaceExperience += xp;
    while (c.ability < 100 &&
        c.palaceExperience >= palaceExperienceNeeded(c.ability)) {
      c.palaceExperience -= palaceExperienceNeeded(c.ability);
      c.ability++;
    }
    if (c.ability >= 100) c.palaceExperience = 0;
    return c.ability - before;
  }

  void _palaceBuff(
    GameState s,
    Courtier c,
    String kind,
    int amount,
    int duration, {
    int uses = 0,
  }) {
    // A repeated duty refreshes its own effect; it never stacks with itself.
    s.palaceEffects.removeWhere((e) => e.kind == kind);
    s.palaceEffects.add(
      PalaceEffect(
        kind: kind,
        personId: c.id,
        startsTurn: s.week + 1,
        endsTurn: s.week + duration,
        amount: amount,
        uses: uses,
      ),
    );
  }

  void _palaceSeason(GameState s) {
    if (!s.seasonal) return;
    final kitchen = palaceEffect(s, 'kitchen');
    if (kitchen != null) {
      final gain = math.min(kitchen.amount, math.max(0, 100 - s.health));
      s.health += gain;
      s.note('Ngự thiện điều dưỡng', 'Cung vụ hỗ trợ sức khỏe +$gain kỳ này.');
    }
    final staff = palaceEffect(s, 'staff');
    if (staff != null) {
      for (final c in s.court.where(palaceResident)) {
        c.plot = math.max(0, c.plot - staff.amount);
      }
      s.note(
        'Nền nếp nội cung',
        'Cung vụ giảm ${staff.amount} tiến độ âm mưu mỗi người trong hậu cung.',
      );
    }
    for (final work in s.palaceWorks.toList()) {
      final before = _outcomeStats(s);
      final c = s.court.where((c) => c.id == work.personId).firstOrNull;
      final title =
          '${palaceWorkTitle(work.kind)}: ${c?.name ?? 'Người phụ trách'}';
      if (c == null || !palaceResident(c)) {
        s.palaceWorks.remove(work);
        s.note(
          title,
          'Công việc gián đoạn do người phụ trách không còn trong cung. Kinh phí không hoàn lại.',
          'warning',
        );
        _recordOutcome(s, before, title, 'interrupted');
        continue;
      }
      work.progress++;
      if (work.progress < work.duration) continue;
      s.palaceWorks.remove(work);
      if (work.kind == 'study') {
        final xp = studyExperience(c);
        final gain = _palaceLearn(c, xp);
        c.palaceCoursesCompleted++;
        s.note(
          title,
          'Hoàn thành khóa học: +$xp kinh nghiệm · năng lực +$gain (hiện ${c.ability}/100). Không thu thêm học phí.',
          'gold',
        );
        _recordOutcome(s, before, title, 'success');
        continue;
      }
      final duty = palaceDuty(work.kind)!;
      final success = _next(s, 100) < palaceSuccessChance(s, c, duty);
      final partial =
          success &&
          (c.integrity < 60 || c.personalities.contains(Personality.greedy)) &&
          _next(s, 100) < (100 - c.integrity).clamp(15, 85);
      final status =
          !success
              ? 'failure'
              : partial
              ? 'partial'
              : 'success';
      final baseXp = dutyExperience(duty, c);
      final xp =
          !success
              ? baseXp ~/ 4
              : partial
              ? baseXp ~/ 2
              : baseXp;
      final gain = _palaceLearn(c, xp);
      if (!success) {
        if (duty.id == 'ceremony') s.authority--;
        if (duty.id == 'kinship') {
          s.factions[work.faction] = s.factions[work.faction]! - 3;
        }
      } else {
        c.palaceDutiesCompleted++;
        int reward(int amount) => partial ? math.max(1, amount ~/ 2) : amount;
        switch (duty.id) {
          case 'inventory':
            _palaceBuff(s, c, duty.id, reward(8), 3);
          case 'wardrobe':
            _palaceBuff(s, c, duty.id, reward(4), 3);
          case 'procurement':
            _palaceBuff(s, c, duty.id, reward(5), 4, uses: 5);
          case 'kitchen':
            _palaceBuff(s, c, duty.id, reward(2), 3);
          case 'herbs':
            _palaceBuff(s, c, duty.id, reward(10), 6, uses: 3);
          case 'quiet':
            s.stress = math.max(0, s.stress - reward(6));
          case 'ceremony':
            s.authority += reward(3);
          case 'kinship':
            final opponent = factionOpponents[work.faction]!;
            s.factions[work.faction] = s.factions[work.faction]! + reward(6);
            s.factions[opponent] = s.factions[opponent]! - 3;
          case 'harmony':
            s.stability += reward(2);
            final people =
                s.court.where(palaceResident).toList()..sort(
                  (a, b) =>
                      a.affection != b.affection
                          ? a.affection.compareTo(b.affection)
                          : a.id.compareTo(b.id),
                );
            for (final person in people.take(2)) {
              person.affection = math.min(100, person.affection + reward(5));
              person.discontent = math.max(0, person.discontent - reward(5));
              person.plot = math.max(0, person.plot - reward(3));
            }
          case 'staff':
            s.stability += reward(3);
            _palaceBuff(s, c, duty.id, 1, partial ? 1 : 2);
          case 'charity':
            s.people += reward(4);
          case 'school':
            s.people += reward(6);
        }
      }
      final result =
          !success
              ? duty.risk
              : partial
              ? 'Hoàn thành một phần do thất thoát: lợi ích và kinh nghiệm giảm; thời hạn hiệu lực được ghi bên dưới.'
              : duty.benefit;
      final buff =
          s.palaceEffects
              .where((e) => e.kind == duty.id && e.startsTurn == s.week + 1)
              .firstOrNull;
      s.note(
        title,
        '$result '
        '${buff == null ? '' : '${authoredMoneyText(s, palaceEffectDescription(buff))}; từ ${s.date(buff.startsTurn)} đến hết ${s.date(buff.endsTurn)}. '}'
        '+$xp kinh nghiệm · năng lực +$gain (hiện ${c.ability}/100). '
        'Kinh phí đã cấp không trừ lại.',
        success ? 'gold' : 'warning',
      );
      _recordOutcome(s, before, title, status);
    }
    // Keep this turn's effects through settlement; next turn prunes them.
    s.palaceEffects.removeWhere(
      (e) =>
          e.endsTurn <= s.week ||
          (['herbs', 'procurement'].contains(e.kind) && e.uses <= 0),
    );
  }
}

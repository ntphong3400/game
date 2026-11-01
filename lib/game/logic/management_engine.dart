part of 'game_engine.dart';

extension ManagementEngine on GameEngine {
  void _appointManager(GameState s, String officeId, String candidateId) {
    final post = managementPost(officeId);
    final office = s.courtOffices.where((o) => o.id == officeId).firstOrNull;
    final candidate = courtPerson(s, candidateId);
    if (s.managementVersion == 0 ||
        post == null ||
        office == null ||
        candidate == null) {
      throw const GameRuleException('Vị trí hoặc ứng viên không còn hợp lệ.');
    }
    final blocked = managementCandidateBlocked(s, candidate, post);
    if (blocked != null) throw GameRuleException(blocked);
    final old = managementHolder(s, post);
    _spend(
      s,
      1000,
      title: 'Bổ nhiệm ${post.role} · ${post.areaName}',
      category: 'character',
      detail: '${candidate.name} thay ${old?.name ?? 'vị trí bỏ trống'}.',
    );
    final source = courtOfficeFor(s, candidate.id);
    if (source != null) {
      source.holderId = '';
      source.appointedTurn = s.week;
    }
    if (old != null) {
      old.role = 'Chờ bổ nhiệm';
      old.changeManagementAffection(-10);
      // Remain present so changing their posting does not cancel a mission.
    }
    s.officialsPool.remove(candidate);
    if (!s.court.any((c) => c.id == candidate.id)) s.court.add(candidate);
    candidate.role = post.role;
    candidate.courtGroup = post.group;
    candidate.changeManagementAffection(5);
    office.holderId = candidate.id;
    office.appointedTurn = s.week;
    s.workThisWeek++;
    s.affairsThisWeek++;
    s.note(
      'Bổ nhiệm ${post.role} · ${post.areaName}',
      '${candidate.name} tiếp nhận quản lý. Chi 1.000 ngân lượng và 1 hành động; thiện cảm +5.'
          '${old == null ? '' : ' ${old.name} chờ bổ nhiệm, giữ nguyên phẩm vị; thiện cảm −10.'}'
          '${source == null ? '' : ' Chức ${source.role} đang bỏ trống.'}',
      'gold',
    );
  }

  void _settleManagementPassives(GameState s) {
    if (s.managementVersion == 0 || s.lastManagementTurn >= s.week) return;
    final lines = <String>[];
    var population = 0, levee = 0;
    for (final post in managementPosts) {
      final office = managementOffice(s, post);
      if (office == null) continue;
      final direction = managementDirection(s, post);
      if (direction == 0) continue;
      office.passiveProgress += direction;
      final cycles = office.passiveProgress ~/ post.interval;
      office.passiveProgress -= cycles * post.interval;
      final delta = cycles * post.amount;
      if (post.benefit == 'equipment') {
        // Included in the same seasonal production total as the workshops.
        lines.add(
          '${post.role} · ${post.areaName}: ${delta >= 0 ? '+' : ''}$delta sản xuất quân khí.',
        );
        continue;
      }
      if (delta == 0) continue;
      switch (post.benefit) {
        case 'training':
          s.population!.changeTraining(delta.toDouble(), at: post.area);
        case 'morale':
          s.population!.changeMorale(delta.toDouble(), at: post.area);
        case 'population':
          population += delta;
        case 'levee':
          levee += delta;
      }
      lines.add(
        '${post.role} · ${post.areaName}: ${delta >= 0 ? '+' : ''}$delta ${post.benefitLabel}.',
      );
    }
    if (population > 0) {
      s.population!.population += population;
      _populationChange(s, 'Quan lại địa phương', population);
    } else if (population < 0) {
      _losePopulation(
        s,
        -population,
        'Khuyết quan địa phương',
        civiliansOnly: true,
      );
    }
    s.levee = (s.levee + levee).clamp(0, 100);
    s.lastManagementTurn = s.week;
    if (lines.isNotEmpty) s.note('Đóng góp quản lý', lines.join('\n'), 'gold');
  }

  void _growManagers(GameState s) {
    if (s.managementVersion == 0) return;
    for (final post in managementPosts) {
      final person = managementHolder(s, post);
      if (person == null || person.ability >= post.growthCap) continue;
      person.managementGrowthHalf += post.senior ? 1 : 2;
      final gain = person.managementGrowthHalf ~/ 2;
      person.managementGrowthHalf %= 2;
      person.ability = math.min(post.growthCap, person.ability + gain);
    }
  }
}

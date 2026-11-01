part of 'game_engine.dart';

extension RealmDevelopment on GameEngine {
  void _startDevelopment(GameState s, String task, String officerId) {
    final blocked = developmentBlocked(s, task);
    if (blocked != null) throw GameRuleException(blocked);
    if (officerId.isEmpty) {
      throw const GameRuleException('Hãy chọn quan phụ trách nâng cấp.');
    }
    final officer = _person(s, officerId);
    if (officer.isConsort || officerBusy(s, officer.id)) {
      throw const GameRuleException('Cần một triều thần đang rảnh.');
    }
    final reason = developmentOfficerBlocked(s, task, officer);
    if (reason != null) throw GameRuleException(reason);
    final existing = developmentProject(s, task);
    final target = developmentTarget(s, task);
    final actualChance = developmentSuccessChance(s, task, officer);
    final estimate = developmentSuccessChance(s, task, officer, preview: true);
    final cost = developmentCost(s, task);
    _spend(
      s,
      cost,
      title: developmentNames[task]!,
      detail:
          '${existing == null ? 'Cấp vốn' : 'Bổ nhiệm người thay'}: '
          'cấp $target, ${officer.name}, ước tính $estimate% thành công. '
          'Không hoàn vốn nếu thất bại.',
    );
    if (existing == null) {
      s.projects.add(
        WorkOrder(
          id: 'development-${s.revision}',
          kind: task,
          officerId: officer.id,
          startedWeek: s.week,
          duration: developmentDuration(s, target),
          targetLevel: target,
          successChance: actualChance,
          estimatedChance: estimate,
        ),
      );
    } else {
      existing.officerId = officer.id;
      existing.paused = false;
      existing.successChance = actualChance;
      existing.estimatedChance = estimate;
    }
    s.workThisWeek++;
    s.affairsThisWeek++;
    _assignOfficer(s, officer, success: false);
    s.note(
      developmentNames[task]!,
      '${existing == null ? 'Khởi công' : 'Tiếp tục'} cấp $target: '
      '${officer.name} phụ trách, ước tính $estimate% thành công. '
      '${developmentBenefit(s, task, target)} '
      'Xét kết quả khi hoàn tất; cấp mới có hiệu lực từ mùa sau.',
    );
  }

  void _advanceDevelopment(GameState s, WorkOrder p) {
    final officer =
        s.court.where((c) => c.id == p.officerId && c.available).firstOrNull;
    if (officer == null || p.paused) {
      if (!p.paused) {
        p.paused = true;
        s.note(
          'Công trình tạm dừng',
          '${projectTitle(p.kind)} cấp ${p.targetLevel}: người phụ trách đã rời triều. '
              'Giữ tiến độ ${p.progress}/${p.duration}; bổ nhiệm người thay tại Ngân khố, không cấp lại vốn.',
          'warning',
        );
      }
      return;
    }
    p.progress++;
    if (p.progress < p.duration) return;
    final before = _outcomeStats(s);
    s.projects.remove(p);
    final success = _next(s, 100) < p.successChance;
    final title = '${projectTitle(p.kind)} · cấp ${p.targetLevel}';
    if (success) {
      switch (p.kind) {
        case 'upgrade_economy':
          s.economyLevel = p.targetLevel;
        case 'upgrade_farm':
          s.agricultureLevel = p.targetLevel;
        case 'upgrade_levee':
          s.leveeLevel = p.targetLevel;
      }
      _merit(s, officer, points: 2, title: title, eventId: 'project-${p.id}');
    }
    final detail =
        success
            ? '${officer.name} hoàn thành. ${developmentBenefit(s, p.kind, p.targetLevel)} '
                'Lợi ích áp dụng từ mùa sau; tình trạng đê hiện tại không tự phục hồi.'
            : '${officer.name} không hoàn thành nâng cấp. Giữ nguyên cấp '
                '${developmentLevel(s, p.kind)}; vốn đã chi không hoàn lại. Có thể đầu tư lại.';
    s.note(title, detail, success ? 'gold' : 'warning');
    _recordOutcome(
      s,
      before,
      title,
      success ? 'success' : 'failure',
      detail: detail,
    );
  }

  void _settleLeveeSeason(GameState s) {
    if (s.cropYear != s.year) {
      s.cropYear = s.year;
      s.cropBaselineLevee = s.levee.clamp(0, 100);
      s.springLeveePercent = s.summerLeveePercent = null;
    }
    final wear = (leveeWear(s) * 100).round() + s.leveeWearRemainder;
    final lost = wear ~/ 100;
    s.leveeWearRemainder = wear % 100;
    s.levee = (s.levee - lost).clamp(0, 100);
    final factor = leveeYieldPercent(s.levee);
    if (s.season == 'Xuân') s.springLeveePercent = factor;
    if (s.season == 'Hạ') s.summerLeveePercent = factor;
    s.note(
      'Đê điều cuối mùa ${s.season}',
      'Đê cấp ${s.leveeLevel}: hao mòn nền ${seasonalLeveeWear[s.season]}, '
          'giảm ${leveeWearReductions[s.leveeLevel]}%, kỳ này −$lost; '
          'tình trạng ${s.levee}/100, hệ số mùa ${factor.toStringAsFixed(1)}%. '
          '${s.season == 'Đông' ? 'Tình trạng được giữ sang vụ năm sau.' : 'Đã ghi nhận cho vụ Thu năm ${s.year}.'}',
    );
  }
}
